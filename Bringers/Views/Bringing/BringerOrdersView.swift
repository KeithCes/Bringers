//
//  BringerOrdersView.swift
//  Bringers
//
//  Created by Keith C on 12/26/21.
//

import Foundation
import MapKit
import SwiftUI
import FirebaseDatabase
import FirebaseAuth
import Mapper
import SafariServices

struct BringerOrdersView: View {
    
    @State private var isShowingOrder: Bool = false
    @State private var acceptPressed: Bool = false
    @State private var isShowingBringerConfirm: Bool = false
    @State private var confirmPressed: Bool = false
    @State private var isShowingBringerMap: Bool = false
    
    @State private var orders: [OrderModel] = []
    @State private var currentOrder: OrderModel = OrderModel(id: "", title: "", description: "", pickupBuy: "", maxPrice: 0, deliveryFee: 0, dateSent: "", dateCompleted: "", status: "", userID: "", location: CLLocationCoordinate2D(latitude: 0, longitude: -122.009015))
    
    @State private var isProgressViewHidden: Bool = false
    
    @StateObject private var viewModel = BringerOrderLocationViewModel()
    
    @State private var currentCoords: CLLocationCoordinate2D = DefaultCoords.coords
    @State private var lowestDistance: CLLocationCoordinate2D = DefaultCoords.coords
    @State private var alphaIncrementValDistance: CGFloat = 0.1
    @State private var lowestShipping: CGFloat = 0
    @State private var alphaIncrementValShipping: CGFloat = 0.1
    
    @Binding var givenOrder: OrderModel
    
    @State private var userInfo: UserInfoModel = UserInfoModel()
    
    // TODO: change to custom URL when wesbite setup
    @State var stripeURLString = "https://example.com"
    @State var stripeAccountID = ""
    @State var isShowingSafari: Bool = false
    
    init(givenOrder: Binding<OrderModel>) {
        UITableView.appearance().separatorStyle = .none
        UITableViewCell.appearance().backgroundColor = .red
        UITableView.appearance().backgroundColor = .clear
        
        self._givenOrder = givenOrder
    }
    
    var body: some View {
        
        ZStack {
            if self.userInfo.stripeAccountID == "" {
                
                VStack {
                    CustomTitleText(labelText: "TO BECOME A BRINGER AND PICK UP ORDERS, WE NEED TO CONFIRM A FEW DETAILS:")
                    
                    Link(destination: URL(string: self.stripeURLString)!, label: {
                        Button("CONFIRM ACCOUNT") {
                            
                            self.isProgressViewHidden = false
                            
                            ProgressView()
                                .isHidden(self.isProgressViewHidden)
                                .scaleEffect(x: 2, y: 2, anchor: .center)
                                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center)
                                .background(RoundedRectangle(cornerRadius: 3)
                                                .fill(CustomColors.seafoamGreen))
                                .progressViewStyle(CircularProgressViewStyle(tint: CustomColors.darkGray))

                            
                            didSelectConnectWithStripe { url in
                                
                                self.stripeURLString = url ?? ""
                                
                                DispatchQueue.main.async {
                                    self.isProgressViewHidden = true
                                    self.isShowingSafari = true
                                }
                            }
                        }
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(Color.white)
                        .background(Rectangle()
                                        .fill(CustomColors.blueGray.opacity(0.6))
                                        .frame(width: CustomDimensions.width, height: 70)
                                        .cornerRadius(15))
                        .padding(EdgeInsets(top: 30, leading: 20, bottom: 10, trailing: 20))
                    })
                }
            }
            else {
                List(orders) { order in
                    OrderListButton(
                        isShowingOrder: $isShowingOrder,
                        order: order,
                        currentOrder: $currentOrder,
                        distance: self.currentCoords.distance(from: order.location),
                        distanceAlpha: ((self.currentCoords.distance(from: order.location) - self.currentCoords.distance(from: self.lowestDistance)) * self.alphaIncrementValDistance) + 0.4,
                        shippingAlpha: ((order.deliveryFee - self.lowestShipping) * self.alphaIncrementValShipping) + 0.4
                    )
                }
                
                .frame(width: CustomDimensions.width + 20, height: CustomDimensions.height550)
            }
            ProgressView()
                .scaleEffect(x: 2, y: 2, anchor: .center)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3)
                                .fill(CustomColors.seafoamGreen))
                .progressViewStyle(CircularProgressViewStyle(tint: CustomColors.darkGray))
                .isHidden(self.isProgressViewHidden)
        }
        .frame(width: CustomDimensions.width + 20, height: CustomDimensions.height550)
        .onAppear {
            viewModel.checkIfLocationServicesEnabled()
            getActiveOrders { (orders) in
                self.getYourProfile()
                self.orders = orders
            }
        }
        .background(Rectangle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: CustomDimensions.width, height: CustomDimensions.height550)
                        .cornerRadius(15)
                        .isHidden(self.userInfo.stripeAccountID == ""))
        .tabItem {
            Image(systemName: "bag")
            Text("Bring")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
        
        .sheet(isPresented: $isShowingOrder, onDismiss: {
            if !isShowingOrder && acceptPressed {
                acceptPressed = false
                isShowingBringerConfirm.toggle()
            }
        }) {
            BringerSelectedOrderView(
                isShowingOrder: $isShowingOrder,
                acceptPressed: $acceptPressed,
                order: $currentOrder,
                currentCoords: self.currentCoords
            )
        }
        
        .sheet(isPresented: $isShowingBringerConfirm, onDismiss: {
            if !isShowingBringerConfirm && confirmPressed {
                self.setOrderInProgress()
                confirmPressed = false
                isShowingBringerMap.toggle()
            }
        }) {
            BringerConfirmOrderBuyView(
                isShowingBringerConfirm: $isShowingBringerConfirm,
                confirmPressed: $confirmPressed,
                currentOrder: $currentOrder
            )
        }
        
        .fullScreenCover(isPresented: $isShowingBringerMap) {
            BringerOrderMapView(
                isShowingBringerMap: $isShowingBringerMap,
                currentOrder: self.givenOrder.status == "inprogress" ? $givenOrder : $currentOrder,
                currentCoords: self.$currentCoords
            )
        }
        
        .sheet(isPresented: $isShowingSafari) {
            SafariView(url: URL(string: self.stripeURLString)!)
        }
        
        .onChange(of: isShowingSafari) { isShowingSafari in
            if !isShowingSafari {
                fetchUserDetails { chargesEnabled in
                    if chargesEnabled! {
                        self.updateUserProfileStripeAccountID()
                    }
                    else {
                        print("ERROR USER NOT CREATED")
                    }
                }
            }
        }
        
        .onAppear {
            if self.givenOrder.status == "inprogress" {
                isShowingBringerMap = true
            }
        }
    }
    
    func getActiveOrders(completion: @escaping ([OrderModel]) -> ()) {
        let ref = Database.database().reference()
        let userID = Auth.auth().currentUser!.uid
        
        var allActiveOrders: [OrderModel] = []
        
        ref.child("activeOrders").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let activeOrders = (snapshot.value as? NSDictionary)?.allValues else {
                self.isProgressViewHidden = true
                return
            }
            for activeOrder in activeOrders {
                let activeOrderMap = Order.from(activeOrder as! NSDictionary)
                
                guard let activeOrderMap = activeOrderMap else {
                    self.isProgressViewHidden = true
                    continue
                }
                
                let order = OrderModel(
                    id: activeOrderMap.id,
                    title: activeOrderMap.title,
                    description: activeOrderMap.description,
                    pickupBuy: activeOrderMap.pickupBuy,
                    maxPrice: activeOrderMap.maxPrice,
                    deliveryFee: activeOrderMap.deliveryFee,
                    dateSent: activeOrderMap.dateSent,
                    dateCompleted: activeOrderMap.dateCompleted,
                    status: activeOrderMap.status,
                    userID: activeOrderMap.userID,
                    location: activeOrderMap.location
                )
                
                allActiveOrders.append(order)
            }
            
            DispatchQueue.main.async {
                
                self.currentCoords = viewModel.getCurrentCoords()
                
                // calc lowest/highest location
                self.lowestDistance = allActiveOrders.min(by: { a, b in self.currentCoords.distance(from: a.location) < self.currentCoords.distance(from: b.location) })?.location ?? DefaultCoords.coords
                let highestDistance = allActiveOrders.max(by: { a, b in self.currentCoords.distance(from: a.location) < self.currentCoords.distance(from: b.location) })?.location ?? DefaultCoords.coords
                // distance gap from lowest/highest
                let distanceGap: CGFloat = self.currentCoords.distance(from: highestDistance) - self.currentCoords.distance(from: self.lowestDistance)
                // gets alpha
                self.alphaIncrementValDistance = distanceGap != 0 ? 0.7/distanceGap : 0.4
                
                // delivery calcs
                self.lowestShipping = allActiveOrders.min(by: { a, b in a.deliveryFee < b.deliveryFee })?.deliveryFee ?? 0
                let highestShipping: CGFloat = allActiveOrders.max(by: { a, b in a.deliveryFee < b.deliveryFee })?.deliveryFee ?? 0
                let shippingGap: CGFloat = highestShipping - self.lowestShipping
                self.alphaIncrementValShipping = shippingGap != 0 ? 0.7/shippingGap : 0.4
                
                // filters only waiting orders (not in progress) and not your own
                let filteredActiveOrders: [OrderModel] = allActiveOrders.filter({ a in a.status == "waiting" && a.userID != userID })
                
                // sorts orders on distance
                let sortedOrders: [OrderModel] = filteredActiveOrders.sorted(by: { a, b in self.currentCoords.distance(from: a.location) < self.currentCoords.distance(from: b.location) })
                
                completion(sortedOrders)
            }
        })
    }
    
    func setOrderInProgress() {
        let ref = Database.database().reference()
        let userID = Auth.auth().currentUser!.uid
        
        ref.child("activeOrders").child(self.currentOrder.id).updateChildValues(["status" : "inprogress"])
        ref.child("activeOrders").child(self.currentOrder.id).updateChildValues(["bringerID" : userID])
        ref.child("activeOrders").child(self.currentOrder.id).updateChildValues(["bringerLocation" : [self.currentCoords.latitude, self.currentCoords.longitude]])
        
        ref.child("users").child(userID).child("activeBringers").updateChildValues(["activeBringer" : self.currentOrder.id])
    }
    
    func getYourProfile() {
        
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference()
        
        ref.child("users").child(userID).child("userInfo").observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let activeUserInfo = snapshot.value as? NSDictionary else {
                return
            }
            
            guard let activeUserInfoMap = UserInfo.from(activeUserInfo) else {
                return
            }
            
            let userInfo = UserInfoModel(
                dateOfBirth: activeUserInfoMap.dateOfBirth,
                dateOfCreation: activeUserInfoMap.dateOfCreation,
                email: activeUserInfoMap.email,
                firstName: activeUserInfoMap.firstName,
                lastName: activeUserInfoMap.lastName,
                ordersCompleted: activeUserInfoMap.ordersCompleted,
                ordersPlaced: activeUserInfoMap.ordersPlaced,
                phoneNumber: activeUserInfoMap.phoneNumber,
                profilePictureURL: activeUserInfoMap.profilePictureURL,
                rating: activeUserInfoMap.rating,
                stripeAccountID: activeUserInfoMap.stripeAccountID,
                stripeCustomerID: activeUserInfoMap.stripeCustomerID,
                address: activeUserInfoMap.address,
                state: activeUserInfoMap.state,
                city: activeUserInfoMap.city,
                country: activeUserInfoMap.country,
                zipcode: activeUserInfoMap.zipcode
            )
            
            self.isProgressViewHidden = true
            self.userInfo = userInfo
        })
    }
    
    func didSelectConnectWithStripe(completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://bringers-nodejs.vercel.app/onboard-user")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data,
                  error == nil,
                  (response as? HTTPURLResponse)?.statusCode == 200,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                  let accountURLString = json["url"] as? String,
                  let accountID = json["userID"] as? String else {
                      completion(nil)
                      return
                  }
            DispatchQueue.main.async {
                self.stripeAccountID = accountID
            }
            completion(accountURLString)
        }.resume()
    }
    
    func fetchUserDetails(completion: @escaping (Bool?) -> Void) {
        let url = URL(string: "https://bringers-nodejs.vercel.app/get-user-details")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(["userID" : self.stripeAccountID])
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data,
                  error == nil,
                  (response as? HTTPURLResponse)?.statusCode == 200,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                  let chargesEnabled = json["chargesEnabled"] as? Bool else {
                      completion(nil)
                      return
                  }
            completion(chargesEnabled)
        }.resume()
    }
    
    func updateUserProfileStripeAccountID() {
        
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference()
        
        
        ref.child("users").child(userID).child("userInfo").updateChildValues(["stripeAccountID" : self.stripeAccountID])
    }
}


// TODO: probably should put this in its own file at some point
final class BringerOrderLocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    
    private var currentCoords: CLLocationCoordinate2D = DefaultCoords.coords
    
    @Published private(set) var orderID: String = ""
    
    @Published var region = MKCoordinateRegion(
        center: MapDetails.defaultCoords,
        span: MapDetails.defaultSpan)
    
    func checkIfLocationServicesEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.delegate = self
            locationManager?.startUpdatingLocation()
        }
        else {
            // TODO: (turn on location services) alert
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else {
            return
        }
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // TODO: show alert restricted (likely parental controls)
            print("ass res")
        case .denied:
            // TODO: show alert denied (go settings and change)
            print("ass denied")
        case .authorizedAlways, .authorizedWhenInUse:
            guard let location = locationManager.location else {
                break
            }
            self.currentCoords = location.coordinate
        @unknown default:
            break
        }
    }
    
    func getCurrentCoords() -> CLLocationCoordinate2D {
        return self.currentCoords
    }
}

// TODO: probably should put this in its own file at some point
struct SafariView: UIViewControllerRepresentable {
    
    let url: URL
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
        
    }
}

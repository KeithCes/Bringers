//
//  OrderComingMapView.swift
//  Bringers
//
//  Created by Keith C on 12/23/21.
//

import Foundation
import SwiftUI
import MapKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

struct OrderComingMapView: View {
    
    @StateObject private var viewModel = LocationViewModel()
    
    @Binding var isShowingOrderComing: Bool
    @Binding var isOrderCancelledMap: Bool
    
    @Binding var order: OrderModel
    
    @State private var isShowingReceipt = false
    @State private var isShowingUserProfile = false
    
    @State private var isShowingOrderCompleted = false
    
    @State private var receiptInputImage: UIImage?
    @State private var receiptImage: Image = Image("placeholder")
    
    @State private var profileInputImage: UIImage?
    @State private var profileImage: Image = Image("placeholder")
    @State private var profileImageUploaded: Bool = false
    
    @State private var bringerInfo: UserInfoModel = UserInfoModel()
    
    @State private var paymentIntentID: String = ""
    
    @State private var timer: Timer?
    
    @State private var bringerLocation: CLLocationCoordinate2D = MapDetails.defaultCoords
    @State private var bringerAnotations: [AnnotatedItem] = [AnnotatedItem(name: "bringerLocation", coordinate: MapDetails.defaultCoords)]
    
    init(isShowingOrderComing: Binding<Bool>, isOrderCancelledMap: Binding<Bool>, order: Binding<OrderModel>) {
        
        self._isShowingOrderComing = isShowingOrderComing
        self._order = order
        self._isOrderCancelledMap = isOrderCancelledMap
    }
    
    var body: some View {
        VStack {
            CustomTitleText(labelText: (self.bringerInfo.firstName == "" ? "A BRINGER" : self.bringerInfo.firstName) + " IS COMING WITH YOUR ORDER!")
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: bringerAnotations) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    Rectangle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(CustomColors.lightRed.opacity(1))
                        .clipShape(Circle())
                }
            }
            .allowsHitTesting(false)
            .frame(width: 400, height: 300)
            .accentColor(CustomColors.seafoamGreen)
            .onAppear {
                viewModel.checkIfLocationServicesEnabled()
            }
            HStack {
                
                Button(action: {
                    isShowingUserProfile.toggle()
                }) {
                    self.profileImage
                        .resizable()
                        .frame(width: 74, height: 74)
                }
                .sheet(isPresented: $isShowingUserProfile, content: {
                    UserProfileView(
                        image: self.$profileImage,
                        firstName: self.bringerInfo.firstName,
                        lastName: self.bringerInfo.lastName,
                        rating: self.bringerInfo.rating
                    )
                })
                
                VStack {
                    
                    Button {
                        let sms = "sms:" + self.bringerInfo.phoneNumber
                        let formattedString = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                        guard let url = URL(string: formattedString) else {
                            return
                        }
                        UIApplication.shared.open(url)
                    } label: {
                        Image(systemName: "message.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(CustomColors.darkGray)
                    }
                    .frame(width: 49, height: 28)
                    .background(CustomColors.seafoamGreen)
                    .cornerRadius(15)
                    .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
                    
                    Button {
                        let telephone = "tel://"
                        let formattedString = telephone + self.bringerInfo.phoneNumber
                        guard let url = URL(string: formattedString) else {
                            return
                        }
                        UIApplication.shared.open(url)
                    } label: {
                        Image(systemName: "phone.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(CustomColors.darkGray)
                    }
                    .frame(width: 49, height: 28)
                    .background(CustomColors.seafoamGreen)
                    .cornerRadius(15)
                    .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
                }
                
                if self.order.pickupBuy == "Buy" {
                    Button(action: {
                        isShowingReceipt.toggle()
                    }) {
                        self.receiptImage
                            .resizable()
                            .frame(width: 74, height: 74)
                    }
                    .sheet(isPresented: $isShowingReceipt, content: {
                        ReceiptView(receiptImage: $receiptImage)
                    })
                }
            }
            .background(CustomColors.blueGray.opacity(0.6))
            .cornerRadius(15)
            .frame(width: CustomDimensions.width, height: 108, alignment: .center)
            
            Button("CANCEL ORDER") {
                // TODO: confirmation screen
                deactivateOrder()
            }
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundColor(Color.white)
            .background(Rectangle()
                            .fill(CustomColors.lightRed)
                            .frame(width: CustomDimensions.width, height: 35)
                            .cornerRadius(15))
            .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
        }
        .edgesIgnoringSafeArea(.bottom)
        .tabItem {
            Image(systemName: "cart")
            Text("Order")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
        .onAppear() {
            viewModel.setOrderID(id: order.id)
            viewModel.checkIfLocationServicesEnabled()
            viewModel.setViewParentType(type: MapViewParent.order)
            
            getBringerInfo()
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                checkOrderCancelled()
                sendUserLocation()
                getBringerLocation()
                getReceipt()
            }
        }
        
        .sheet(isPresented: $isShowingOrderCompleted, content: {
            OrderCompleteView(isShowingOrderCompleted: $isShowingOrderCompleted)
        })
        
        .onChange(of: isShowingOrderCompleted) { _ in
            if !isShowingOrderCompleted {
                isShowingOrderComing = false
            }
        }
    }
    
    func checkOrderCancelled() {
        let ref = Database.database().reference()
        
        ref.child("activeOrders").child(self.order.id).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshotDict = (snapshot.value as? NSDictionary) else {
                orderEnded()
                return
            }
            
            guard let _ = snapshotDict["id"] else {
                orderEnded()
                return
            }
            
            if snapshot.value == nil {
                orderEnded()
            }
        })
    }
    
    func orderEnded() {
        let userID = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        
        ref.child("activeOrders").child(order.id).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // removes from active
            ref.child("activeOrders").child(order.id).removeValue()
            
            self.timer?.invalidate()
            
            // checks if order completed
            DispatchQueue.main.async {
                ref.child("users").child(userID).child("pastOrders").child(self.order.id).observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let snapshotDict = (snapshot.value as? NSDictionary) else {
                        return
                    }
                    guard let orderStatus = snapshotDict["status"] as? String else {
                        return
                    }
                    
                    if orderStatus == "completed" {
                        isShowingOrderCompleted = true
                    }
                    else {
                        isShowingOrderComing = false
                    }
                })
            }
        })
    }
    
    func deactivateOrder() {
        let userID = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        
        // TODO: show toast if order fails to be canceled
        sendCancelOrder { success in
            guard let success = success, success == true else {
                return
            }
            
            // moves order from active to past, closes view
            ref.child("activeOrders").child(order.id).observeSingleEvent(of: .value, with: { (snapshot) in
                
                // adds to past
                ref.child("users").child(userID).child("pastOrders").child(order.id).updateChildValues(snapshot.value as! [AnyHashable : Any])
                
                // adds to past FOR BRINGER
                let bringerID = (snapshot.value as! [AnyHashable : Any])["bringerID"] as! String
                ref.child("users").child(bringerID).child("pastBringers").child(order.id).updateChildValues(snapshot.value as! [AnyHashable : Any])
                
                // sets date completed
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/YYYY"
                let currentDateString = dateFormatter.string(from: Date())
                
                ref.child("users").child(userID).child("pastOrders").child(order.id).updateChildValues(["dateCompleted" : currentDateString])
                ref.child("users").child(bringerID).child("pastBringers").child(order.id).updateChildValues(["dateCompleted" : currentDateString])
                
                // sets order cancelled
                ref.child("users").child(userID).child("pastOrders").child(order.id).updateChildValues(["status" : "cancelled"])
                ref.child("users").child(bringerID).child("pastBringers").child(order.id).updateChildValues(["status" : "cancelled"])
                
                
                // removes from active
                ref.child("activeOrders").child(order.id).removeValue()
                ref.child("users").child(bringerID).child("activeBringers").removeValue()
                ref.child("users").child(userID).child("activeOrders").removeValue()
                
                self.timer?.invalidate()
                isShowingOrderComing = false
                isOrderCancelledMap = true
            })
        }
    }
    
    func sendUserLocation() {
        let ref = Database.database().reference()
        guard let locationManager = viewModel.getLocation() else {
            return
        }
        ref.child("activeOrders").child(self.order.id).updateChildValues(["location":[locationManager.location?.coordinate.latitude, locationManager.location?.coordinate.longitude]])
    }
    
    func getBringerLocation() {
        let ref = Database.database().reference()
        ref.child("activeOrders").child(self.order.id).child("bringerLocation").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshotCoords = snapshot.value as? NSArray else {
                orderEnded()
                return
            }
            let bringerLat = snapshotCoords[0] as! CGFloat
            let bringerLong = snapshotCoords[1] as! CGFloat
            
            self.bringerLocation = CLLocationCoordinate2D(latitude: bringerLat, longitude: bringerLong)
            let newAnnotation = AnnotatedItem(name: "bringerLocation", coordinate: self.bringerLocation)
            self.bringerAnotations = [newAnnotation]
            
            let positions = [self.bringerLocation, self.viewModel.getLocation()?.location?.coordinate ?? MapDetails.defaultCoords]
            
            var minLat = 91.0
            var maxLat = -91.0
            var minLon = 181.0
            var maxLon = -181.0
            
            for i in positions {
                maxLat = max(maxLat, i.latitude)
                minLat = min(minLat, i.latitude)
                maxLon = max(maxLon, i.longitude)
                minLon = min(minLon, i.longitude)
            }
            
            let center = CLLocationCoordinate2D(latitude: (maxLat + minLat) / 2,
                                                longitude: (maxLon + minLon) / 2)
            
            let span = MKCoordinateSpan(latitudeDelta: abs(maxLat - minLat) * 1.3,
                                        longitudeDelta: abs(maxLon - minLon) * 1.3)
            
            self.viewModel.region.span = span
            self.viewModel.region.center = center
        })
    }
    
    func getReceipt() {
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let receiptRef = storageRef.child("orderReceipts/" + order.id + "/" + "receipt.png")
        
        receiptRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let _ = error {
                // error occurred
            } else {
                self.receiptInputImage = UIImage(data: data!)
                
                guard let inputImage = receiptInputImage else { return }
                self.receiptImage = Image(uiImage: inputImage)
            }
        }
    }
    
    func getProfilePicture(bringerID: String) {
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let profilePictureRef = storageRef.child("profilePictures/" + bringerID + "/" + "profilePicture.png")
        
        profilePictureRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let _ = error {
                // error occurred
            } else {
                self.profileInputImage = UIImage(data: data!)
                
                guard let inputImage = profileInputImage else { return }
                self.profileImage = Image(uiImage: inputImage)
            }
        }
    }
    
    func getBringerInfo() {
        let ref = Database.database().reference()
        
        ref.child("activeOrders").child(self.order.id).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshotDict = (snapshot.value as? NSDictionary),
                  let bringerID = snapshotDict["bringerID"] as? String else {
                      return
                  }
            ref.child("users").child(bringerID).child("userInfo").observeSingleEvent(of: .value, with: { (snapshotUserDetails) in
                guard let activeUserInfo = snapshotUserDetails.value as? NSDictionary else {
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
                
                self.bringerInfo = userInfo
                
                getProfilePicture(bringerID: bringerID)
            })
        })
    }
    
    func sendCancelOrder(completion: @escaping (Bool?) -> Void) {
        let url = URL(string: "https://bringers-nodejs.vercel.app/cancel-order")!

        getOrderPaymentIntent { _ in
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try! JSONEncoder().encode([
                "paymentIntentID" : self.paymentIntentID,
            ])
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let _ = data, error == nil,
                      (response as? HTTPURLResponse)?.statusCode == 200 else {
                          completion(nil)
                          return
                      }
                completion(true)
            }.resume()
        }
    }
    
    func getOrderPaymentIntent(completion: @escaping (Bool?) -> Void) {
        let ref = Database.database().reference()
        
        ref.child("activeOrders").child(self.order.id).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let activeUser = (snapshot.value as? [AnyHashable : Any]) else {
                completion(nil)
                return
            }
            
            guard let paymentIntentID = (activeUser["paymentIntentID"] as? String) else {
                completion(nil)
                return
            }

            self.paymentIntentID = paymentIntentID
            completion(true)
        })
    }
}


// TODO: probably should move to own class or at least more relevant class
struct AnnotatedItem: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
}

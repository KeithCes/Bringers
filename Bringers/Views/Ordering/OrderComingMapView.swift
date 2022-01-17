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
    
    @State private var receiptInputImage: UIImage?
    @State private var receiptImage: Image = Image("placeholderReceipt")
    
    @State private var bringerFirstname: String = "A Bringer"
    
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
            CustomTitleText(labelText: bringerFirstname.uppercased() + " IS COMING WITH YOUR ORDER!")
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
                    Image("scarra")
                        .resizable()
                        .frame(width: 74, height: 74)
                }
                .sheet(isPresented: $isShowingUserProfile, content: {
                    UserProfileView()
                })
                
                VStack {
                    
                    Button {
                        // TODO: implement texting
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
                        // TODO: implement calling
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
            
            getBringerUsername()
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                checkOrderCancelled()
                sendUserLocation()
                getBringerLocation()
                getReceipt()
            }
        }
    }
    
    func checkOrderCancelled() {
        let ref = Database.database().reference()
        ref.child("activeOrders").child(self.order.id).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshotDict = (snapshot.value as? NSDictionary) else {
                orderCancelled()
                return
            }
            
            guard let _ = snapshotDict["id"] else {
                orderCancelled()
                return
            }
            
            if snapshot.value == nil {
                orderCancelled()
            }
        })
    }
    
    func orderCancelled() {
        let ref = Database.database().reference()
        
        ref.child("activeOrders").child(order.id).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // removes from active
            ref.child("activeOrders").child(order.id).removeValue()
            
            self.timer?.invalidate()
            isShowingOrderComing = false
        })
    }
    
    func deactivateOrder() {
        let userID = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        
        
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
                orderCancelled()
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
        let receiptRef = storageRef.child(order.id + "/" + "receipt.png")
        
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
    
    func getBringerUsername() {
        let ref = Database.database().reference()
        ref.child("activeOrders").child(self.order.id).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshotDict = (snapshot.value as? NSDictionary),
                  let bringerID = snapshotDict["bringerID"] as? String else {
                      return
                  }
            ref.child("users").child(bringerID).child("userInfo").observeSingleEvent(of: .value, with: { (snapshotUserDetails) in
                guard let snapshotUserDetailsDict = (snapshotUserDetails.value as? NSDictionary),
                      let bringerFirstname = snapshotUserDetailsDict["firstName"] as? String else {
                          return
                      }
                self.bringerFirstname = bringerFirstname
            })
        })
    }
}


// TODO: probably should move to own class or at least more relevant class
struct AnnotatedItem: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
}

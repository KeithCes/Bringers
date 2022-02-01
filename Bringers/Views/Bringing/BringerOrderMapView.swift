//
//  BringerOrderMapView.swift
//  Bringers
//
//  Created by Keith C on 1/2/22.
//

import Foundation
import SwiftUI
import MapKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

struct BringerOrderMapView: View {
    
    @StateObject var viewModel = LocationViewModel()
    
    @Binding var isShowingBringerMap: Bool
    @Binding var currentOrder: OrderModel
    @Binding var currentCoords: CLLocationCoordinate2D
    
    @State private var isShowingUserProfile = false
    @State private var isShowingInstructions = false
    @State private var isShowingImagePicker = false
    @State private var receiptInputImage: UIImage?
    @State private var receiptImage: Image = Image("placeholder")
    @State private var receiptImageUploaded: Bool = false
    
    @State private var timer: Timer?
    
    @State private var orderLocation: CLLocationCoordinate2D = MapDetails.defaultCoords
    @State private var orderAnotations: [AnnotatedItem] = [AnnotatedItem(name: "orderLocation", coordinate: MapDetails.defaultCoords)]
    
    var body: some View {
        VStack {
            CustomTitleText(labelText: "DELIVER ITEM!")
            
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: orderAnotations) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    Rectangle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(CustomColors.lightRed.opacity(1))
                        .clipShape(Circle())
                }
            }
            .frame(width: 400, height: 300)
            .accentColor(CustomColors.seafoamGreen)
            .allowsHitTesting(false)
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
                
                Button {
                    isShowingInstructions.toggle()
                } label: {
                    Image(systemName: "note.text")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(CustomColors.darkGray)
                }
                .sheet(isPresented: $isShowingInstructions, content: {
                    BringerInstructionsView(
                        currentOrder: $currentOrder,
                        currentCoords: $currentCoords
                    )
                })
                .frame(width: 50, height: 50)
                .background(Color.white.opacity(0.5))
                .cornerRadius(15)
                .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
                
                if self.currentOrder.pickupBuy == "Buy" {
                    Button(action: {
                        isShowingImagePicker.toggle()
                    }) {
                        self.receiptImage
                            .resizable()
                            .frame(width: 74, height: 74)
                    }
                }
            }
            .background(CustomColors.blueGray.opacity(0.6))
            .cornerRadius(15)
            .frame(width: CustomDimensions.width, height: 108, alignment: .center)
            
            VStack {
                if ((self.currentOrder.pickupBuy == "Buy" && self.receiptImageUploaded) || self.currentOrder.pickupBuy == "Pick-up") && self.currentOrder.location.distance(from: viewModel.getLocation()?.location?.coordinate ?? self.currentOrder.location) < 0.25
                {
                    Button("COMPLETE ORDER") {
                        // TODO: confirmation screen
                        deactivateOrder(isCompleted: true)
                    }
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(Color.white)
                    .background(Rectangle()
                                    .fill(CustomColors.blueGray.opacity(0.6))
                                    .frame(width: CustomDimensions.width, height: 35)
                                    .cornerRadius(15))
                }
                
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
        .onAppear {
            viewModel.checkIfLocationServicesEnabled()
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                checkOrderCancelled()
                sendBringerLocation()
                getOrderLocation()
            }
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(image: $receiptInputImage)
        }
        .onChange(of: receiptInputImage) { _ in
            loadImage()
            uploadReceipt()
        }
    }
    
    func checkOrderCancelled() {
        let ref = Database.database().reference()
        ref.child("activeOrders").child(self.currentOrder.id).observeSingleEvent(of: .value, with: { (snapshot) in
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
        
        ref.child("activeOrders").child(currentOrder.id).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // removes from active
            ref.child("activeOrders").child(currentOrder.id).removeValue()
            
            
            self.timer?.invalidate()
            isShowingBringerMap = false
        })
    }
    
    func deactivateOrder(isCompleted: Bool = false) {
        let userID = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        
        
        // moves order from active to past, closes view
        ref.child("activeOrders").child(currentOrder.id).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // adds to past FOR ORDER
            let orderID = (snapshot.value as! [AnyHashable : Any])["userID"] as! String
            ref.child("users").child(orderID).child("pastOrders").child(currentOrder.id).updateChildValues(snapshot.value as! [AnyHashable : Any])
            
            // adds to past
            ref.child("users").child(userID).child("pastBringers").child(currentOrder.id).updateChildValues(snapshot.value as! [AnyHashable : Any])
            
            // sets date completed
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/YYYY"
            let currentDateString = dateFormatter.string(from: Date())
            
            ref.child("users").child(orderID).child("pastOrders").child(currentOrder.id).updateChildValues(["dateCompleted" : currentDateString])
            ref.child("users").child(userID).child("pastBringers").child(currentOrder.id).updateChildValues(["dateCompleted" : currentDateString])
            
            // sets order completed/cancelled
            let status = isCompleted ? "completed" : "cancelled"
            ref.child("users").child(orderID).child("pastOrders").child(currentOrder.id).updateChildValues(["status" : status])
            ref.child("users").child(userID).child("pastBringers").child(currentOrder.id).updateChildValues(["status" : status])
            
            
            // removes from active
            ref.child("activeOrders").child(currentOrder.id).removeValue()
            ref.child("users").child(userID).child("activeBringers").removeValue()
            ref.child("users").child(orderID).child("activeOrders").removeValue()
            
            self.timer?.invalidate()
            isShowingBringerMap = false
        })
    }
    
    func sendBringerLocation() {
        let ref = Database.database().reference()
        guard let locationManager = viewModel.getLocation() else {
            return
        }
        ref.child("activeOrders").child(self.currentOrder.id).updateChildValues(["bringerLocation":[locationManager.location?.coordinate.latitude, locationManager.location?.coordinate.longitude]])
    }
    
    func getOrderLocation() {
        let ref = Database.database().reference()
        ref.child("activeOrders").child(self.currentOrder.id).child("location").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshotCoords = snapshot.value as? NSArray else {
                orderCancelled()
                return
            }
            let bringerLat = snapshotCoords[0] as! CGFloat
            let bringerLong = snapshotCoords[1] as! CGFloat
            
            self.orderLocation = CLLocationCoordinate2D(latitude: bringerLat, longitude: bringerLong)
            let newAnnotation = AnnotatedItem(name: "orderLocation", coordinate: self.orderLocation)
            self.orderAnotations = [newAnnotation]
            
            let positions = [self.orderLocation, self.viewModel.getLocation()?.location?.coordinate ?? MapDetails.defaultCoords]
            
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
    
    func uploadReceipt() {
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let receiptRef = storageRef.child("orderReceipts/" + currentOrder.id + "/" + "receipt.png")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        guard let data: Data = self.receiptInputImage?.jpegData(compressionQuality: 0.20) else {
            return
        }
        
        receiptRef.putData(data, metadata: nil) { (metadata, error) in
            guard let _ = metadata else {
                // error occurred
                return
            }
            self.receiptImageUploaded = true
        }
    }
    
    func loadImage() {
        guard let inputImage = receiptInputImage else { return }
        self.receiptImage = Image(uiImage: inputImage)
    }
}

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

struct BringerOrderMapView: View {
    
    @StateObject var viewModel = LocationViewModel()
    
    @Binding var isShowingBringerMap: Bool
    @Binding var currentOrder: OrderModel
    @Binding var currentCoords: CLLocationCoordinate2D
    
    @State private var isShowingReceipt = false
    @State private var isShowingUserProfile = false
    @State private var isShowingInstructions = false
    
    @State private var timer: Timer?
    
    @State private var orderLocation: CLLocationCoordinate2D = MapDetails.defaultCoords
    @State private var orderAnotations: [AnnotatedItem] = [AnnotatedItem(name: "orderLocation", coordinate: MapDetails.defaultCoords)]
    
    var receiptImageName = "receipt"
    
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
                    // TODO: replace dummy values
                    BringerInstructionsView(
                        currentOrder: $currentOrder,
                        currentCoords: $currentCoords
                    )
                })
                .frame(width: 50, height: 50)
                .background(Color.white.opacity(0.5))
                .cornerRadius(15)
                .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
                
                if receiptImageName != "" {
                    Button(action: {
                        isShowingReceipt.toggle()
                    }) {
                        Image(receiptImageName)
                            .resizable()
                            .frame(width: 74, height: 74)
                    }
                    .sheet(isPresented: $isShowingReceipt, content: {
                        ReceiptView()
                    })
                }
            }
            .background(CustomColors.blueGray.opacity(0.6))
            .cornerRadius(15)
            .frame(width: CustomDimensions.width, height: 108, alignment: .center)
            
            Button {
                // TODO: confirmation screen/backend call to cancel order
                isShowingBringerMap = false
            } label: {
                Image(systemName: "x.circle")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(CustomColors.darkGray)
            }
            .frame(width: 49, height: 28)
            .background(CustomColors.lightRed)
            .cornerRadius(15)
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
                sendBringerLocation()
                getOrderLocation()
            }
        }
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
            let snapshotCoords = snapshot.value as! NSArray
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
}

//
//  BringerOrderMapView.swift
//  Bringers
//
//  Created by Keith C on 1/2/22.
//

import Foundation
import SwiftUI
import MapKit

struct BringerOrderMapView: View {
    
    @StateObject var viewModel = BringerOrderMapViewModel()
    
    @Binding var isShowingBringerMap: Bool
    @Binding var isOrderCancelledMap: Bool
    @Binding var currentOrder: OrderModel
    @Binding var currentCoords: CLLocationCoordinate2D
    
    
    var body: some View {
        VStack {
            CustomTitleText(labelText: "DELIVER ITEM!")
            
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: viewModel.orderAnotations) { item in
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
                    viewModel.isShowingUserProfile.toggle()
                }) {
                    viewModel.profileImage
                        .resizable()
                        .frame(width: 74, height: 74)
                }
                .sheet(isPresented: $viewModel.isShowingUserProfile, content: {
                    UserProfileView(
                        image: $viewModel.profileImage,
                        firstName: viewModel.ordererInfo.firstName,
                        lastName: viewModel.ordererInfo.lastName,
                        rating: viewModel.ordererInfo.rating
                    )
                })
                
                VStack {
                    Button {
                        let sms = "sms:" + viewModel.ordererInfo.phoneNumber
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
                        let formattedString = telephone + viewModel.ordererInfo.phoneNumber
                        guard let url = URL(string: formattedString) else { return }
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
                
                Button {
                    viewModel.isShowingInstructions.toggle()
                } label: {
                    Image(systemName: "note.text")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(CustomColors.darkGray)
                }
                .sheet(isPresented: $viewModel.isShowingInstructions, content: {
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
                        viewModel.isShowingImagePicker.toggle()
                    }) {
                        viewModel.receiptImage
                            .resizable()
                            .frame(width: 74, height: 74)
                    }
                }
            }
            .background(CustomColors.blueGray.opacity(0.6))
            .cornerRadius(15)
            .frame(width: CustomDimensions.width, height: 108, alignment: .center)
            
            VStack {
                if ((self.currentOrder.pickupBuy == "Buy" && viewModel.receiptImageUploaded) || self.currentOrder.pickupBuy == "Pick-up") && self.currentOrder.location.distance(from: viewModel.getLocation()?.location?.coordinate ?? self.currentOrder.location) < 0.25
                {
                    Button("COMPLETE ORDER") {
                        viewModel.isShowingBringerCompleteConfirmation.toggle()
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
                    viewModel.deactivateOrder(orderID: self.currentOrder.id)
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
            
            viewModel.getOrdererDetails(userID: self.currentOrder.userID)
            
            viewModel.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                viewModel.checkOrderCancelled(orderID: self.currentOrder.id)
                viewModel.sendBringerLocation(orderID: self.currentOrder.id)
                viewModel.getOrderLocation(orderID: self.currentOrder.id)
            }
        }
        .sheet(isPresented: $viewModel.isShowingImagePicker) {
            ImagePicker(image: $viewModel.receiptInputImage)
        }
        .onChange(of: viewModel.receiptInputImage) { _ in
            viewModel.loadImage()
            viewModel.uploadReceipt(orderID: self.currentOrder.id)
        }
        .onChange(of: viewModel.isShowingBringerMap) { _ in
            self.isShowingBringerMap = false
        }
        .onChange(of: viewModel.isOrderCancelledMap) { _ in
            self.isOrderCancelledMap = true
            self.isShowingBringerMap = false
        }
        .sheet(isPresented: $viewModel.isShowingBringerCompleteConfirmation, onDismiss: {
            if !viewModel.isShowingBringerCompleteConfirmation && viewModel.isOrderSuccessfullyCompleted {
                viewModel.deactivateOrder(orderID: self.currentOrder.id, isCompleted: true)
            }
        }) {
            BringerOrderCompleteConfirmation(
                isShowingBringerCompleteConfirmation: $viewModel.isShowingBringerCompleteConfirmation,
                isOrderSuccessfullyCompleted: $viewModel.isOrderSuccessfullyCompleted,
                currentOrder: $currentOrder
            )
        }
    }
}

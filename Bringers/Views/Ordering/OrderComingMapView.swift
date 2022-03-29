//
//  OrderComingMapView.swift
//  Bringers
//
//  Created by Keith C on 12/23/21.
//

import Foundation
import SwiftUI
import MapKit

struct OrderComingMapView: View {
    
    @StateObject private var viewModel = OrderComingMapViewModel()
    
    @Binding var isShowingOrderComing: Bool
    @Binding var isOrderCancelledMap: Bool
    
    @Binding var order: OrderModel
    
    
    var body: some View {
        VStack {
            CustomTitleText(labelText: (viewModel.bringerInfo.firstName == "" ? "A BRINGER" : viewModel.bringerInfo.firstName) + " IS COMING WITH YOUR ORDER!")
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: viewModel.bringerAnotations) { item in
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
                    viewModel.isShowingUserProfile.toggle()
                }) {
                    viewModel.profileImage
                        .resizable()
                        .frame(width: 74, height: 74)
                }
                .sheet(isPresented: $viewModel.isShowingUserProfile, content: {
                    UserProfileView(
                        image: $viewModel.profileImage,
                        firstName: viewModel.bringerInfo.firstName,
                        lastName: viewModel.bringerInfo.lastName,
                        rating: viewModel.bringerInfo.rating
                    )
                })
                
                VStack {
                    
                    Button {
                        let sms = "sms:" + viewModel.bringerInfo.phoneNumber
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
                        let formattedString = telephone + viewModel.bringerInfo.phoneNumber
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
                        viewModel.isShowingReceipt.toggle()
                    }) {
                        viewModel.receiptImage
                            .resizable()
                            .frame(width: 74, height: 74)
                    }
                    .sheet(isPresented: $viewModel.isShowingReceipt, content: {
                        ReceiptView(receiptImage: $viewModel.receiptImage)
                    })
                }
            }
            .background(CustomColors.blueGray.opacity(0.6))
            .cornerRadius(15)
            .frame(width: CustomDimensions.width, height: 108, alignment: .center)
            
            Button("CANCEL ORDER") {
                // TODO: confirmation screen
                viewModel.deactivateOrder(orderID: self.order.id)
            }
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundColor(Color.white)
            .background(Rectangle()
                            .fill(CustomColors.lightRed)
                            .frame(width: CustomDimensions.width, height: 35)
                            .cornerRadius(15))
            .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
        }
        .toast(message: viewModel.toastMessage,
               isShowing: $viewModel.isShowingToast,
               duration: Toast.long
        )
        .edgesIgnoringSafeArea(.bottom)
        .tabItem {
            Image(systemName: "cart")
            Text("Order")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
        .onAppear() {
            viewModel.checkIfLocationServicesEnabled()
            
            viewModel.getBringerInfo(orderID: self.order.id)
            
            viewModel.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                viewModel.checkOrderCancelled(orderID: self.order.id)
                viewModel.sendUserLocation(orderID: self.order.id)
                viewModel.getBringerLocation(orderID: self.order.id)
                viewModel.getReceipt(orderID: self.order.id)
            }
        }
        
        .sheet(isPresented: $viewModel.isShowingOrderCompleted, content: {
            OrderCompleteView(
                isShowingOrderCompleted: $viewModel.isShowingOrderCompleted,
                newRating: $viewModel.newRating
            )
        })
        
        .onChange(of: viewModel.isShowingOrderCompleted) { _ in
            if !viewModel.isShowingOrderCompleted {
                viewModel.timer?.invalidate()
                viewModel.isShowingOrderComing = false
                viewModel.isOrderCancelledMap = false
            }
        }
        .onChange(of: viewModel.isOrderCancelledMap) { _ in
            self.isShowingOrderComing = false
            self.isOrderCancelledMap = true
        }
        .onChange(of: viewModel.isShowingOrderComing) { _ in
            self.isShowingOrderComing = false
        }
        .onChange(of: viewModel.newRating) { _ in
            viewModel.sendRating(
                orderID: self.order.id,
                bringerRating: viewModel.bringerInfo.rating,
                bringerTotalRatings: viewModel.bringerInfo.totalRatings
            )
        }
    }
}

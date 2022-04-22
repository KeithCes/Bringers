//
//  WaitingForBringerView.swift
//  Bringers
//
//  Created by Keith C on 12/24/21.
//

import Foundation
import SwiftUI
import Mapper

struct WaitingForBringerView: View {
    
    @StateObject private var viewModel = WaitingForBringerViewModel()
    
    @Binding var isShowingWaitingForBringer: Bool
    @Binding var isOrderCancelledWaiting: Bool
    
    @Binding var order: OrderModel
    
    
    var body: some View {
        VStack {
            CustomTitleText(labelText: "WAITING FOR A BRINGER TO ACCEPT YOUR ORDER...")
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 15, trailing: 20))
            
            Rectangle()
                .frame(width: 100, height: 100)
                .background(CustomColors.midGray.opacity(0.5))
                .foregroundColor(CustomColors.midGray.opacity(0.5))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(CustomColors.midGray.opacity(0.5))
                        .scaleEffect(viewModel.animationAmount)
                        .opacity(Double(2 - viewModel.animationAmount))
                        .animation(
                            .easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: false),
                            value: viewModel.animationAmount
                        )
                )
                .overlay(
                    Image(systemName: "person")
                        .frame(width: 100, height: 100)
                        .scaleEffect(viewModel.animationAmount + 2)
                        .opacity(Double(2 - viewModel.animationAmount))
                        .animation(
                            .easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: false),
                            value: viewModel.animationAmount
                        )
                        .foregroundColor(Color.gray)
                )
                .onAppear {
                    viewModel.animationAmount = 2
                }
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 40, trailing: 20))
            
            List(viewModel.offers) { offer in
                OfferListButton(
                    isShowingOfferConfirm: $viewModel.isShowingOfferConfirm,
                    currentOffer: $viewModel.currentOffer,
                    distance: self.order.location.distance(from: offer.bringerLocation),
                    offer: offer
                )
            }
            .background(Rectangle()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: CustomDimensions.width, height: CustomDimensions.height200)
                            .cornerRadius(15))
            .frame(width: CustomDimensions.width + 20, height: CustomDimensions.height200)
            
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
        .onAppear {
            viewModel.checkIfLocationServicesEnabled()
            
            viewModel.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                viewModel.sendUserLocation(orderID: self.order.id)
                viewModel.checkIfOrderInProgress(orderID: self.order.id)
                viewModel.getOffers(orderID: self.order.id) { (offers) in
                    viewModel.offers = offers
                }
            }
        }
        .onChange(of: viewModel.isOrderCancelledWaiting, perform: { _ in
            self.isOrderCancelledWaiting = true
            self.isShowingWaitingForBringer = false
        })
        .onChange(of: viewModel.isShowingWaitingForBringer, perform: { _ in
            self.isShowingWaitingForBringer = false
        })
        .onChange(of: viewModel.isOfferAccepted, perform: { _ in
            viewModel.setOrderInProgress(order: self.order)
        })
        .sheet(isPresented: $viewModel.isShowingOfferConfirm) {
            AcceptOfferView(
                isShowingAcceptOffer: $viewModel.isShowingOfferConfirm,
                isOfferAccepted: $viewModel.isOfferAccepted,
                originalPrice: self.order.deliveryFee,
                offerPrice: viewModel.currentOffer.offerAmount
            )
        }
    }
}

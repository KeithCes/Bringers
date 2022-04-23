//
//  BringerWaitingOfferView.swift
//  Bringers
//
//  Created by Keith C on 4/11/22.
//

import Foundation
import SwiftUI

struct BringerWaitingOfferView: View {
    
    @StateObject private var viewModel = BringerWaitingOfferViewModel()
    
    @Binding var isShowingBringerWaitingOffer: Bool
    @Binding var isOfferAccepted: Bool
    @Binding var currentOrder: OrderModel
    @Binding var currentOffer: OfferModel
    
    var body: some View {
        VStack {
            CustomTitleText(labelText: "WAITING FOR THE ORDERER TO ACCEPT YOUR OFFER...")
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
            
            Button("CANCEL OFFER") {
                // TODO: confirmation screen
                viewModel.deactivateOffer(orderID: self.currentOrder.id)
                self.isShowingBringerWaitingOffer.toggle()
            }
            .onChange(of: viewModel.isShowingWaitingForBringer) { _ in
                self.isShowingBringerWaitingOffer = false
            }
            .onChange(of: viewModel.isOfferAccepted) { _ in
                self.isOfferAccepted = true
            }
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundColor(Color.white)
            .background(Rectangle()
                            .fill(CustomColors.lightRed)
                            .frame(width: CustomDimensions.width, height: 35)
                            .cornerRadius(15))
            .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
        }
        .onAppear {
            viewModel.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                viewModel.checkOfferAccepted(orderID: self.currentOrder.id)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
    }
}

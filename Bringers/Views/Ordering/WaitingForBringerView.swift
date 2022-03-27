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
                .frame(width: 200, height: 200)
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
                        .frame(width: 200, height: 200)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
        .onAppear {
            viewModel.checkIfLocationServicesEnabled()
            
            viewModel.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                viewModel.sendUserLocation(orderID: self.order.id)
                viewModel.checkIfOrderInProgress(orderID: self.order.id)
            }
        }
        .onChange(of: viewModel.isOrderCancelledWaiting, perform: { _ in
            self.isOrderCancelledWaiting = true
            self.isShowingWaitingForBringer = false
        })
        .onChange(of: viewModel.isShowingWaitingForBringer, perform: { _ in
            self.isShowingWaitingForBringer = false
        })
    }
}

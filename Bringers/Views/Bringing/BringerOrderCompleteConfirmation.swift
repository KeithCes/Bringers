//
//  BringerOrderCompleteConfirmation.swift
//  Bringers
//
//  Created by Keith C on 2/16/22.
//

import Foundation
import SwiftUI
import Combine

struct BringerOrderCompleteConfirmation: View {
    
    @StateObject private var viewModel = BringerOrderCompleteConfirmationViewModel()
    
    @Binding var isShowingBringerCompleteConfirmation: Bool
    @Binding var isOrderSuccessfullyCompleted: Bool
    
    @Binding var currentOrder: OrderModel
    
    
    var body: some View {
        VStack {
            CustomTitleText(labelText: "IS THE ORDER COMPLETED?")
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
            
            // if buy
            if currentOrder.pickupBuy == "Buy" {
                CustomLabel(labelText: "How much did the item ACTUALLY cost?", height: 75, fontSize: 14)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 25, trailing: 20))
                
                if viewModel.actualItemPrice.currencyAsCGFloat() > currentOrder.maxPrice {
                    CustomLabel(labelText: "THE ACTUAL PRICE CANNOT EXCEED THE MAX PRICE REQUESTED BY THE ORDERER", height: 75, fontSize: 14, backgroundColor: CustomColors.lightRed)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 25, trailing: 20))
                }
                
                CustomTextboxCurrencyDecimal(field: $viewModel.actualItemPrice, placeholderText: "Actual Item Price")
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 25, trailing: 20))
                    .keyboardType(.numberPad)
                
                if viewModel.actualItemPrice.currencyAsCGFloat() <= currentOrder.maxPrice && viewModel.actualItemPrice.count > 0 {
                    Button("COMPLETE ORDER") {
                        
                        viewModel.isCompleteButtonEnabled = false
                        
                        let actualItemPrice = viewModel.actualItemPrice.currencyAsCGFloat()

                        if actualItemPrice == self.currentOrder.maxPrice {
                            viewModel.completeOrderNoRefund(currentOrder: self.currentOrder) { success in
                                guard let success = success else {
                                    return
                                }
                                if success {
                                    self.isShowingBringerCompleteConfirmation.toggle()
                                    self.isOrderSuccessfullyCompleted = true
                                }
                            }
                        }
                        else {
                            viewModel.completeOrder(currentOrder: self.currentOrder) { success in
                                guard let success = success else {
                                    return
                                }
                                if success {
                                    self.isShowingBringerCompleteConfirmation.toggle()
                                    self.isOrderSuccessfullyCompleted = true
                                }
                            }
                        }
                    }
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(Color.white)
                    .background(Rectangle()
                                    .fill(CustomColors.blueGray.opacity(0.6))
                                    .frame(width: CustomDimensions.width, height: 70)
                                    .cornerRadius(15))
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20))
                    .disabled(!viewModel.isCompleteButtonEnabled)
                }
            }
            // if pickup
            else {
                Button("COMPLETE ORDER") {
                    
                    viewModel.isCompleteButtonEnabled = false
                    
                    let actualItemPrice = viewModel.actualItemPrice.currencyAsCGFloat()
                            
                    if actualItemPrice == self.currentOrder.maxPrice {
                        viewModel.completeOrderNoRefund(currentOrder: self.currentOrder) { success in
                            guard let success = success else {
                                return
                            }
                            if success {
                                self.isShowingBringerCompleteConfirmation.toggle()
                                self.isOrderSuccessfullyCompleted = true
                            }
                        }
                    }
                    else {
                        viewModel.completeOrder(currentOrder: self.currentOrder) { success in
                            guard let success = success else {
                                return
                            }
                            if success {
                                self.isShowingBringerCompleteConfirmation.toggle()
                                self.isOrderSuccessfullyCompleted = true
                            }
                        }
                    }
                }
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(Color.white)
                .background(Rectangle()
                                .fill(CustomColors.blueGray.opacity(0.6))
                                .frame(width: CustomDimensions.width, height: 70)
                                .cornerRadius(15))
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 250, trailing: 0))
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
        .onAppear {
            viewModel.getBringerDetails(userID: self.currentOrder.userID)
        }
    }
}

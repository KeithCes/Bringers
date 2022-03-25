//
//  ConfirmOrderView.swift
//  Bringers
//
//  Created by Keith C on 12/20/21.
//

import Foundation
import SwiftUI
import Stripe

struct ConfirmOrderView: View {
    
    @StateObject private var viewModel = ConfirmOrderViewModel()
    
    @Binding var isShowingConfirm: Bool
    @Binding var confirmPressed: Bool
    @Binding var order: OrderModel
    
    
    var body: some View {
        VStack {
            if viewModel.isShowingPaymentSheet {
                VStack {
                    CustomTitleText(labelText: "CONFIRM PAYMENT METHOD")
                    
                    CustomLabel(labelText: "On confirmation of payment type you will be charged and the order will be placed", height: 75, fontSize: 14)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 25, trailing: 20))
                    
                    if let paymentSheet = viewModel.paymentSheet {
                        PaymentSheet.PaymentButton(
                            paymentSheet: paymentSheet,
                            onCompletion: viewModel.onPaymentCompletion
                        ) {
                            Text("CONFIRM PAYMENT")
                            .padding(EdgeInsets(top: 35, leading: 20, bottom: 35, trailing: 20))
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(Color.white)
                            .background(Rectangle()
                                            .fill(CustomColors.blueGray.opacity(0.6))
                                            .frame(width: CustomDimensions.width, height: 70)
                                            .cornerRadius(15))
                        }
                    }
                    else {
                        Text("Loading…")
                    }
                }
            }
            else {
                CustomTitleText(labelText: "CONFIRM THE FOLLOWING:")
                
                if order.pickupBuy == "Buy" {
                    CustomLabel(labelText: "ESTIMATED MAXIMUM COST:", isBold: true)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 15, trailing: 20))
                    
                    // TODO: calc tax based on location (change 0.0625 to be dynamic)
                    let estTax = round(CGFloat(order.maxPrice) * 0.0625 * 100) / 100.0
                    
                    CustomLabel(labelText: "MAX ITEM PRICE = $" + String(format:"%.02f", order.maxPrice) + "\nDELIVERY FEE = $" + String(format:"%.02f", order.deliveryFee) + "\nESTIMATED SALES TAX = $" + "\(estTax)", height: 100)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 5, trailing: 20))
                    
                    CustomLabel(labelText: "TOTAL ESTIMATED MAXIMUM COST = $" + String(format:"%.02f", (estTax + order.maxPrice + order.deliveryFee)), height: 75, isBold: true)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 15, trailing: 20))
                    
                    CustomLabel(labelText: "Note: If the actual item price is cheaper than the max item price, you will be refunded the difference when the order is complete", height: 75, fontSize: 14)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 25, trailing: 20))
                }
                else {
                    CustomLabel(labelText: "DELIVERY FEE = $" + String(format:"%.02f", order.deliveryFee))
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 5, trailing: 20))
                    
                    CustomLabel(labelText: "TOTAL COST = $" + String(format:"%.02f", order.deliveryFee), isBold: true)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 15, trailing: 20))
                }
                
                Text("By pressing “PLACE ORDER” you agree to the terms and conditions of the Bringers app")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(CustomColors.midGray)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minWidth: 0, maxWidth: CustomDimensions.width, minHeight: 0, maxHeight: 10)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 15, trailing: 20))
                
                Button("CONFIRM DETAILS") {
                    viewModel.passOrder(order: self.order)
                    viewModel.preparePaymentSheet { _ in
                        DispatchQueue.main.async {
                            viewModel.isShowingPaymentSheet.toggle()
                        }
                    }
                }
                .padding(EdgeInsets(top: 35, leading: 20, bottom: 35, trailing: 20))
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(Color.white)
                .background(Rectangle()
                                .fill(CustomColors.blueGray.opacity(0.6))
                                .frame(width: CustomDimensions.width, height: 70)
                                .cornerRadius(15))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
        .onAppear {
            viewModel.getYourProfile(userID: self.order.userID)
        }
        .onChange(of: viewModel.confirmPressed, perform: { _ in
            self.confirmPressed = true
            self.isShowingConfirm = false
        })
    }
}

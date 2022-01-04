//
//  BringerInstructionsView.swift
//  Bringers
//
//  Created by Keith C on 1/2/22.
//

import Foundation
import SwiftUI
import Combine

struct BringerInstructionsView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    private var pickupBuy: String
    private var maxItemPrice: CGFloat
    private var orderTitle: String
    private var description: String
    private var distance: CGFloat
    private var yourProfit: CGFloat
    
    @ObservedObject private var keyboard = KeyboardResponder()
    
    init(pickupBuy: String, maxItemPrice: CGFloat, orderTitle: String, description: String, distance: CGFloat, yourProfit: CGFloat) {
        self.pickupBuy = pickupBuy
        self.maxItemPrice = maxItemPrice
        self.orderTitle = orderTitle
        self.description = description
        self.distance = distance
        self.yourProfit = yourProfit
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    CustomLabel(labelText: self.pickupBuy, width: (CustomDimensions.width - 20) * 0.265, isBold: true)
                        .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
                    
                    CustomLabel(labelText: self.orderTitle, width: (CustomDimensions.width - 20) * 0.715)
                        .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 0))
                }
                
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .frame(width: CustomDimensions.width - 20, height: 100)
                .fixedSize(horizontal: true, vertical: true)
                
                
                Text(self.description)
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(CustomColors.midGray)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
                    .frame(width: CustomDimensions.width - 20, height: 220, alignment: .top)
                    .background(Rectangle()
                                    .fill(Color.white.opacity(0.5))
                                    .cornerRadius(15))
                    .multilineTextAlignment(.leading)
                
                CustomLabelWithTab(labelText: "Current Distance Away", tabText: String(format:"%.01f", self.distance) + "mi")
                
                if pickupBuy == "Buy" {
                    CustomLabelWithTab(labelText: "Maximum Item Cost", tabText: "$" + String(format:"%.0f", self.maxItemPrice))
                }
                
                CustomLabelWithTab(labelText: "Your Profit", tabText: "$" + String(format:"%.0f", self.yourProfit), isBold: true)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 40, trailing: 0))
            }
            .background(Rectangle()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: CustomDimensions.width, height: CustomDimensions.height500)
                            .cornerRadius(15))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
        .onTapGesture {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

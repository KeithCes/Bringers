//
//  BringerConfirmOrderBuyView.swift
//  Bringers
//
//  Created by Keith C on 12/28/21.
//

import Foundation
import SwiftUI

struct BringerConfirmOrderBuyView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var isShowingBringerConfirm: Bool
    
    var maxItemPrice: CGFloat
    var yourProfit: CGFloat
    
    init(isShowingBringerConfirm: Binding<Bool>, maxItemPrice: CGFloat = 0, yourProfit: CGFloat) {
        self._isShowingBringerConfirm = isShowingBringerConfirm
        self.maxItemPrice = maxItemPrice
        self.yourProfit = yourProfit
    }
    
    var body: some View {
        VStack {
            CustomTitleText(labelText: "CONFIRM THE FOLLOWING:")
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 15, trailing: 20))
           
            if maxItemPrice != 0 {
                CustomLabel(labelText: "MAX ITEM PRICE = $" + String(format:"%.02f", maxItemPrice), height: 75)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 5, trailing: 20))
            }
            
            CustomLabel(labelText: "YOUR PROFIT = $" + String(format:"%.02f", yourProfit), isBold: true)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
            
            CustomLabel(labelText: "REMEMBER: DO NOT spend more than the max item price on the requested item. Cancel the order or contact the orderer if the price of the item you find exceeds it", height: 90, fontSize: 14)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 5, trailing: 20))
            
            CustomLabel(labelText: "Note: Make sure to ask for a receipt! You’ll need to attach it to your order later to complete it!", height: 65, fontSize: 14)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 25, trailing: 20))
            
            Text("By pressing “ACCEPT ORDER” you agree to the terms and conditions of the Bringers app")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(CustomColors.midGray)
                .fixedSize(horizontal: false, vertical: true)
                .frame(minWidth: 0, maxWidth: CustomDimensions.width, minHeight: 0, maxHeight: 10)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 15, trailing: 20))
            
            Button("ACCEPT ORDER") {
                isShowingBringerConfirm = false
            }
            .padding(EdgeInsets(top: 35, leading: 20, bottom: 35, trailing: 20))
            .font(.system(size: 30, weight: .bold, design: .rounded))
            .foregroundColor(Color.white)
            .background(Rectangle()
                            .fill(CustomColors.blueGray.opacity(0.6))
                            .frame(width: CustomDimensions.width, height: 70)
                            .cornerRadius(15))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
    }
}

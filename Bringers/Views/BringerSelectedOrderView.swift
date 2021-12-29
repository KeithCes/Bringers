//
//  BringerSelectedOrderView.swift
//  Bringers
//
//  Created by Keith C on 12/26/21.
//

import Foundation
import SwiftUI
import Combine

struct BringerSelectedOrderView: View {
    
    @Binding var isShowingOrder: Bool
    
    var pickupBuy: String
    var maxItemPrice: CGFloat
    var itemName: String
    var description: String
    var distance: CGFloat
    var yourPayout: CGFloat
    
    @ObservedObject private var keyboard = KeyboardResponder()
    
    init(isShowingOrder: Binding<Bool>, pickupBuy: String, maxItemPrice: CGFloat, itemName: String, description: String, distance: CGFloat, yourPayout: CGFloat) {
        self._isShowingOrder = isShowingOrder
        self.pickupBuy = pickupBuy
        self.maxItemPrice = maxItemPrice
        self.itemName = itemName
        self.description = description
        self.distance = distance
        self.yourPayout = yourPayout
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    CustomLabel(labelText: self.pickupBuy, width: 80, isBold: true)
                        .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
                    
                    CustomLabel(labelText: "OOOOO", width: 216)
                        .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 0))
                }
                
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .frame(width: 302, height: 100)
                .fixedSize(horizontal: true, vertical: true)
                
                
                Text("gkerthgwherighiowerhgioerwhgoiwerhgioerjhioghewirohgiowerhiogherihlsierhgisehgluishg luihrliughluiershguiserl qjojoprjwpjqwfpoeg roejhgpiwejghioerhgiowe geurbgiouerhgoiwehrioghinelgrhklahiovhioreagerg")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(CustomColors.midGray)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
                    .frame(width: 302, height: 220, alignment: .top)
                    .background(Rectangle()
                                    .fill(Color.white.opacity(0.5))
                                    .cornerRadius(15))
                    .multilineTextAlignment(.leading)
                
                CustomLabelWithTab(labelText: "Current Distance Away", tabText: "1.0mi")
                
                if pickupBuy == "Buy" {
                    CustomLabelWithTab(labelText: "Maximum Item Cost", tabText: "$50")
                }
                
                CustomLabelWithTab(labelText: "Your Payout", tabText: "$5", isBold: true)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 40, trailing: 0))
            }
            .background(Rectangle()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: 322, height: 500)
                            .cornerRadius(15))
            
            Button("ACCEPT ORDER") {
                isShowingOrder = false
            }
            .padding(EdgeInsets(top: 35, leading: 20, bottom: 35, trailing: 20))
            .font(.system(size: 30, weight: .bold, design: .rounded))
            .foregroundColor(Color.white)
            .background(Rectangle()
                            .fill(CustomColors.blueGray.opacity(0.6))
                            .frame(width: 322, height: 70)
                            .cornerRadius(15))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
    }
}

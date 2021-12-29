//
//  OrderListButton.swift
//  Bringers
//
//  Created by Keith C on 12/26/21.
//

import Foundation
import SwiftUI

struct OrderListButton: View {
    
    @State private var isShowingOrder: Bool = false
    @State private var isShowingBringerConfirm: Bool = false
    
    private var orderTitle: String
    private var distance: CGFloat
    private var shippingCost: CGFloat
    private var distanceAlpha: CGFloat
    private var shippingAlpha: CGFloat
    
    init(orderTitle: String, distance: CGFloat, shippingCost: CGFloat, distanceAlpha: CGFloat, shippingAlpha: CGFloat) {
        self.orderTitle = orderTitle
        self.distance = distance
        self.shippingCost = shippingCost
        self.distanceAlpha = distanceAlpha
        self.shippingAlpha = shippingAlpha
    }
    
    var body: some View {
        ZStack {
            Button(action: {
                isShowingOrder.toggle()
            }) {
                Text(self.orderTitle)
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(CustomColors.midGray)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 302, height: 50)
            .background(Rectangle()
                            .fill(Color.white.opacity(0.5))
                            .cornerRadius(15))
            .popover(isPresented: $isShowingOrder, content: {
//                BringerSelectedOrderView(isShowingOrder: $isShowingOrder)
            })
            
            Rectangle()
                .foregroundColor(CustomColors.veryDarkGray.opacity(self.distanceAlpha))
                .frame(width: 60, height: 50)
                .overlay(
                    Text("\(self.distance)" + "mi")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(CustomColors.seafoamGreen)
                )
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 241))
                .cornerRadius(15)
            
            Rectangle()
                .foregroundColor(CustomColors.veryDarkGray.opacity(self.shippingAlpha))
                .frame(width: 60, height: 50)
                .overlay(
                    Text("$" + String(format:"%.0f", self.shippingCost))
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(CustomColors.seafoamGreen)
                )
                .padding(EdgeInsets(top: 0, leading: 241, bottom: 0, trailing: 0))
                .cornerRadius(15)
        }
        .onChange(of: isShowingOrder) { value in
            if !value {
                isShowingBringerConfirm.toggle()
            }
        }
        .fullScreenCover(isPresented: $isShowingBringerConfirm) {
            BringerConfirmOrderBuyView(isShowingBringerConfirm: $isShowingBringerConfirm, deliveryFee: 69, maxItemPrice: 88)
        }
    }
}

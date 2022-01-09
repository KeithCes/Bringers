//
//  OrderListButton.swift
//  Bringers
//
//  Created by Keith C on 12/26/21.
//

import Foundation
import SwiftUI

struct OrderListButton: View {
    
    @Binding private var isShowingOrder: Bool
    
    // TODO: change to activeOrder as state once backend connected (pull properties out of here)
    @Binding private var orderTitleState: String
    
    private var order: OrderModel
    @Binding private var currentOrder: OrderModel
    
    private var orderTitle: String
    private var distance: CGFloat
    private var shippingCost: CGFloat
    private var distanceAlpha: CGFloat
    private var shippingAlpha: CGFloat
    
    init(orderTitleState: Binding<String>, isShowingOrder: Binding<Bool>, order: OrderModel, currentOrder: Binding<OrderModel>, orderTitle: String, distance: CGFloat, shippingCost: CGFloat, distanceAlpha: CGFloat, shippingAlpha: CGFloat) {
        self._isShowingOrder = isShowingOrder
        self._orderTitleState = orderTitleState
        self.order = order
        self._currentOrder = currentOrder
        self.orderTitle = orderTitle
        self.distance = distance
        self.shippingCost = shippingCost
        self.distanceAlpha = distanceAlpha
        self.shippingAlpha = shippingAlpha
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                Button(action: {
                    isShowingOrder.toggle()
                    orderTitleState = self.orderTitle
                    currentOrder = self.order
                }) {
                    Text(self.orderTitle)
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(CustomColors.midGray)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                }
                .frame(width: CustomDimensions.width, height: 50)
                .background(Rectangle()
                                .fill(Color.white.opacity(0.5))
                                .frame(width: CustomDimensions.width - 20, height: 50)
                                .cornerRadius(15))
                
                Rectangle()
                    .foregroundColor(CustomColors.veryDarkGray.opacity(self.distanceAlpha))
                    .frame(width: (CustomDimensions.width - 20) * 0.199, height: 50)
                    .overlay(
                        Text("\(self.distance)" + "mi")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(CustomColors.seafoamGreen)
                    )
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: (CustomDimensions.width - 20) * 0.798))
                    .cornerRadius(15)
                
                Rectangle()
                    .foregroundColor(CustomColors.veryDarkGray.opacity(self.shippingAlpha))
                    .frame(width: (CustomDimensions.width - 20) * 0.199, height: 50)
                    .overlay(
                        Text("$" + String(format:"%.0f", self.shippingCost))
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(CustomColors.seafoamGreen)
                    )
                    .padding(EdgeInsets(top: 0, leading: (CustomDimensions.width - 20) * 0.798, bottom: 0, trailing: 0))
                    .cornerRadius(15)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .padding()
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

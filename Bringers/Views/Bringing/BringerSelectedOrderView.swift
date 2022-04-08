//
//  BringerSelectedOrderView.swift
//  Bringers
//
//  Created by Keith C on 12/26/21.
//

import Foundation
import SwiftUI
import Combine
import MapKit

struct BringerSelectedOrderView: View {
    
    @Binding var isShowingOrder: Bool
    @Binding var acceptPressed: Bool
    @Binding var offerPressed: Bool
    
    @Binding var order: OrderModel
    
    @Binding var currentCoords: CLLocationCoordinate2D
    
    @ObservedObject private var keyboard = KeyboardResponder()
    
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    CustomLabel(labelText: self.order.pickupBuy, width: (CustomDimensions.width - 20) * 0.265, isBold: true)
                        .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
                    
                    CustomLabel(labelText: self.order.title, width: (CustomDimensions.width - 20) * 0.715)
                        .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 0))
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .frame(width: CustomDimensions.width - 20, height: 100)
                .fixedSize(horizontal: true, vertical: true)
                
                
                Text(self.order.description)
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(CustomColors.midGray)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
                    .frame(width: CustomDimensions.width - 20, height: 220, alignment: .top)
                    .background(Rectangle()
                                    .fill(Color.white.opacity(0.5))
                                    .cornerRadius(15))
                    .multilineTextAlignment(.leading)
                
                CustomLabelWithTab(labelText: "Current Distance Away", tabText: String(format:"%.01f", self.currentCoords.distance(from: self.order.location)) + "mi")
                
                if self.order.pickupBuy == "Buy" {
                    CustomLabelWithTab(labelText: "Maximum Item Cost", tabText: "$" + String(format:"%.0f", self.order.maxPrice))
                }
                
                CustomLabelWithTab(labelText: "Your Profit", tabText: "$" + String(format:"%.02f", self.order.deliveryFee * 0.75), isBold: true)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 40, trailing: 0))
            }
            .background(Rectangle()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: CustomDimensions.width, height: 500)
                            .cornerRadius(15)
                            .padding())
            
            HStack {
                Button("CANCEL") {
                    isShowingOrder = false
                }
                .padding(EdgeInsets(top: 35, leading: 10, bottom: 35, trailing: 10))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Color.white)
                .background(Rectangle()
                                .fill(CustomColors.blueGray.opacity(0.6))
                                .frame(width: CustomDimensions.width / 3, height: 70)
                                .cornerRadius(15))
                
                Button("OFFER") {
                    isShowingOrder = false
                    offerPressed = true
                }
                .padding(EdgeInsets(top: 35, leading: 10, bottom: 35, trailing: 10))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Color.white)
                .background(Rectangle()
                                .fill(CustomColors.blueGray.opacity(0.6))
                                .frame(width: CustomDimensions.width / 3, height: 70)
                                .cornerRadius(15))
                
                Button("ACCEPT") {
                    isShowingOrder = false
                    acceptPressed = true
                }
                .padding(EdgeInsets(top: 35, leading: 10, bottom: 35, trailing: 10))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Color.white)
                .background(Rectangle()
                                .fill(CustomColors.blueGray.opacity(0.6))
                                .frame(width: CustomDimensions.width / 3, height: 70)
                                .cornerRadius(15))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
    }
}

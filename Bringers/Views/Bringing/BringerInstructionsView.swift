//
//  BringerInstructionsView.swift
//  Bringers
//
//  Created by Keith C on 1/2/22.
//

import Foundation
import SwiftUI
import Combine
import MapKit

struct BringerInstructionsView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @Binding var currentOrder: OrderModel
    @Binding var currentCoords: CLLocationCoordinate2D
    
    @ObservedObject private var keyboard = KeyboardResponder()
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    CustomLabel(labelText: self.currentOrder.pickupBuy, width: (CustomDimensions.width - 20) * 0.265, isBold: true)
                        .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
                    
                    CustomLabel(labelText: self.currentOrder.title, width: (CustomDimensions.width - 20) * 0.715)
                        .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 0))
                }
                
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .frame(width: CustomDimensions.width - 20, height: 100)
                .fixedSize(horizontal: true, vertical: true)
                
                
                Text(self.currentOrder.description)
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(CustomColors.midGray)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
                    .frame(width: CustomDimensions.width - 20, height: 220, alignment: .top)
                    .background(Rectangle()
                                    .fill(Color.white.opacity(0.5))
                                    .cornerRadius(15))
                    .multilineTextAlignment(.leading)
                
                CustomLabelWithTab(labelText: "Current Distance Away", tabText: String(format:"%.01f", self.currentCoords.distance(from: self.currentOrder.location)) + "mi")
                
                if self.currentOrder.pickupBuy == "Buy" {
                    CustomLabelWithTab(labelText: "Maximum Item Cost", tabText: "$" + String(format:"%.0f", self.currentOrder.maxPrice))
                }
                
                CustomLabelWithTab(labelText: "Your Profit", tabText: "$" + String(format:"%.0f", self.currentOrder.deliveryFee * 0.75), isBold: true)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 40, trailing: 0))
            }
            .background(Rectangle()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: CustomDimensions.width, height: CustomDimensions.height550)
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

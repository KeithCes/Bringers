//
//  BringerOfferOrderView.swift
//  Bringers
//
//  Created by Keith C on 4/8/22.
//

import Foundation
import SwiftUI
import MapKit

struct BringerOfferOrderView: View {
    
    @StateObject private var viewModel = BringerOfferOrderViewModel()
    
    @Binding var isShowingBringerOffer: Bool
    @Binding var confirmPressed: Bool
    @Binding var currentOrder: OrderModel
    @Binding var bringerCoords: CLLocationCoordinate2D
    @Binding var currentOffer: OfferModel
    
    
    var body: some View {
        VStack {
            CustomTitleText(labelText: "HOW MUCH WOULD YOU LIKE TO DELIVER THIS ITEM?")
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 15, trailing: 20))
            
            if self.currentOrder.deliveryFee >= viewModel.offerAmount && viewModel.offerAmount > 0 {
                CustomLabel(labelText: "YOUR OFFER MUST BE MORE THAN THE EXISTING DELIVERY FEE", height: 75, fontSize: 14, backgroundColor: CustomColors.lightRed)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 25, trailing: 20))
            }
            
            CustomTextboxCurrency(field: $viewModel.offerAmount, placeholderText: "Offer Amount")
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 15, trailing: 20))
            
            CustomLabel(labelText: "YOUR PROFIT = $" + String(format:"%.02f", viewModel.offerAmount * 0.75), isBold: true)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
            
            CustomLabel(labelText: "If your offer is accepted you will be notified and obligated to deliver the item at the offered price.", fontSize: 14)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 5, trailing: 20))
            
            Button("OFFER") {
                self.currentOffer = viewModel.createOffer(orderID: self.currentOffer.id, bringerCoords: self.bringerCoords)
                confirmPressed = true
                isShowingBringerOffer = false
            }
            .padding(EdgeInsets(top: 35, leading: 20, bottom: 35, trailing: 20))
            .font(.system(size: 30, weight: .bold, design: .rounded))
            .foregroundColor(Color.white)
            .background(Rectangle()
                            .fill(CustomColors.blueGray.opacity(0.6))
                            .frame(width: CustomDimensions.width, height: 70)
                            .cornerRadius(15))
            .isHidden(self.currentOrder.deliveryFee > viewModel.offerAmount)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
        .onTapGesture {
            self.hideKeyboard()
        }
    }
}

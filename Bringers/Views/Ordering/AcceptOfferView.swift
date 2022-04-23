//
//  AcceptOfferView.swift
//  Bringers
//
//  Created by Keith C on 4/2/22.
//


import Foundation
import SwiftUI
import Stripe

struct AcceptOfferView: View {
    
    @Binding var isShowingAcceptOffer: Bool
    @Binding var isOfferAccepted: Bool
    
    private var originalPrice: CGFloat
    private var offerPrice: CGFloat
    
    init(isShowingAcceptOffer: Binding<Bool>, isOfferAccepted: Binding<Bool>, originalPrice: CGFloat, offerPrice: CGFloat) {
        self._isShowingAcceptOffer = isShowingAcceptOffer
        self._isOfferAccepted = isOfferAccepted
        self.originalPrice = originalPrice
        self.offerPrice = offerPrice
    }
    
    var body: some View {
        VStack {
            CustomTitleText(labelText: "CONFIRM THE FOLLOWING:")
            
            HStack {
                CustomTitleText(labelText: "ORIGINAL DELIVERY COST\n$" + "\(Int(originalPrice))", fontSize: 20)
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                    .multilineTextAlignment(.center)
                
                CustomTitleText(labelText: "OFFERED DELIVERY COST\n$" + "\(Int(offerPrice))", fontSize: 20)
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                    .multilineTextAlignment(.center)
            }
            
            CustomLabel(labelText: "Accepting this offer will cost you $" + "\(Int(offerPrice - originalPrice))" + " more than what you requested\n\nIs that ok?", height: 100)
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                .multilineTextAlignment(.center)
            
            HStack {
                Button("CANCEL") {
                    isShowingAcceptOffer.toggle()
                }
                .padding(EdgeInsets(top: 35, leading: 20, bottom: 35, trailing: 20))
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(Color.white)
                .background(Rectangle()
                                .fill(CustomColors.blueGray.opacity(0.6))
                                .frame(width: CustomDimensions.width / 2, height: 70)
                                .cornerRadius(15))
                
                Button("ACCEPT") {
                    isShowingAcceptOffer.toggle()
                    isOfferAccepted = true
                }
                .padding(EdgeInsets(top: 35, leading: 20, bottom: 35, trailing: 20))
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(Color.white)
                .background(Rectangle()
                                .fill(CustomColors.blueGray.opacity(0.6))
                                .frame(width: CustomDimensions.width / 2, height: 70)
                                .cornerRadius(15))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
    }
}

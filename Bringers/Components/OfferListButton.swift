//
//  OfferListButton.swift
//  Bringers
//
//  Created by Keith C on 4/1/22.
//

import Foundation
import SwiftUI

struct OfferListButton: View {
    
    @Binding var isShowingOfferConfirm: Bool
    @Binding var currentOffer: OfferModel
    
    private var distance: CGFloat
    private var offer: OfferModel
    
    init(isShowingOfferConfirm: Binding<Bool>, currentOffer: Binding<OfferModel>, distance: CGFloat, offer: OfferModel) {
        self._isShowingOfferConfirm = isShowingOfferConfirm
        self._currentOffer = currentOffer
        self.distance = distance
        self.offer = offer
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                Button(action: {
                    self.currentOffer = self.offer
                    isShowingOfferConfirm.toggle()
                }) {
                    Rectangle()
                        .foregroundColor(CustomColors.veryDarkGray.opacity(0.5))
                        .frame(width: CustomDimensions.width * 0.4, height: 50)
                        .overlay(
                            Text("ACCEPT")
                                .font(.system(size: 18, weight: .regular, design: .rounded))
                                .foregroundColor(CustomColors.seafoamGreen)
                        )
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .cornerRadius(15)
                }
                .frame(width: CustomDimensions.width, height: 50)
                .background(Rectangle()
                                .fill(Color.white.opacity(0.5))
                                .frame(width: CustomDimensions.width - 20, height: 50)
                                .cornerRadius(15))
                
                Rectangle()
                    .foregroundColor(CustomColors.veryDarkGray.opacity(0.5))
                    .frame(width: (CustomDimensions.width - 20) * 0.199, height: 50)
                    .overlay(
                        Text("\(self.distance)" + "mi")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(CustomColors.seafoamGreen)
                    )
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: (CustomDimensions.width - 20) * 0.798))
                    .cornerRadius(15)
                
                Rectangle()
                    .foregroundColor(CustomColors.veryDarkGray.opacity(0.5))
                    .frame(width: (CustomDimensions.width - 20) * 0.199, height: 50)
                    .overlay(
                        Text("$" + String(format:"%.0f", self.offer.offerAmount))
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

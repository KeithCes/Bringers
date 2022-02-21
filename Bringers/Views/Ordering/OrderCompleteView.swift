//
//  OrderCompleteView.swift
//  Bringers
//
//  Created by Keith C on 2/21/22.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct OrderCompleteView: View {
    
    @Binding var isShowingOrderCompleted: Bool
    
    var body: some View {
        VStack {
            CustomTitleText(labelText: "YOUR ORDER HAS BEEN DELIVERED, ENJOY!")
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 15, trailing: 20))
            
            Button("DISMISS") {
                self.isShowingOrderCompleted.toggle()
            }
            .font(.system(size: 30, weight: .bold, design: .rounded))
            .foregroundColor(Color.white)
            .background(Rectangle()
                            .fill(CustomColors.blueGray.opacity(0.6))
                            .frame(width: CustomDimensions.width, height: 70)
                            .cornerRadius(15))
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
    }
}

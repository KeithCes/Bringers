//
//  ConfirmOrderPickupView.swift
//  Bringers
//
//  Created by Keith C on 12/23/21.
//

import Foundation
import SwiftUI

struct ConfirmOrderPickupView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("CONFIRM THE FOLLOWING:")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 15, trailing: 20))
                .fixedSize(horizontal: false, vertical: true)
            
            CustomLabel(labelText: "DELIVERY FEE = $5")
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 5, trailing: 20))
            
            CustomLabel(labelText: "TOTAL COST = $5", isBold: true)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 15, trailing: 20))
            
            Text("By pressing “PLACE ORDER” you agree to the terms and conditions of the Bringers app")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(CustomColors.midGray)
                .fixedSize(horizontal: false, vertical: true)
                .frame(minWidth: 0, maxWidth: 322, minHeight: 0, maxHeight: 10)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 15, trailing: 20))
            
            Button("PLACE ORDER") {
                presentationMode.wrappedValue.dismiss()
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
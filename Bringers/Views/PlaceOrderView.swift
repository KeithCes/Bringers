//
//  PlaceOrderView.swift
//  Bringers
//
//  Created by Keith C on 12/20/21.
//

import Foundation
import SwiftUI

struct PlaceOrderView: View {
    
    @State private var pickupBuy: String = ""
    @State private var deliveryFee: String = ""
    @State private var maxItemPrice: String = ""
    @State private var itemName: String = ""
    @State private var description: String = ""
    
    @ObservedObject private var keyboard = KeyboardResponder()
    
    var body: some View {
    VStack {
        Text("LOOKING FOR SOMETHING?")
            .font(.system(size: 48, weight: .bold, design: .rounded))
        
        CustomTextbox(field: $pickupBuy, placeholderText: "Pick-up or buy?")
            .padding(EdgeInsets(top: 30, leading: 20, bottom: 15, trailing: 20))
        
        HStack {
            CustomTextbox(field: $deliveryFee, placeholderText: "Delivery Fee", width: 153)
            CustomTextbox(field: $maxItemPrice, placeholderText: "Max Item Price", width: 153)
        }
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 5, trailing: 20))
        
        CustomTextbox(field: $itemName, placeholderText: "Name of Item")
            .padding(EdgeInsets(top: 30, leading: 20, bottom: 30, trailing: 20))
        
        TextEditor(text: $description)
            .padding()
            .font(.system(size: 18, weight: .regular, design: .rounded))
            .foregroundColor(CustomColors.midGray)
            .background(Rectangle()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: 322, height: 153)
                            .cornerRadius(15))
            .frame(minWidth: 0, maxWidth: 300, minHeight: 0, maxHeight: 140)
            .placeholderTopLeft(when: self.description.isEmpty) {
                Text("Description").foregroundColor(CustomColors.midGray.opacity(0.6))
                // makes placeholder even with text in box, not sure why we need this padding
                    .padding(.top, 24)
                    .padding(.leading, 20)
            }
            .onReceive(self.description.publisher.collect()) {
                self.description = String($0.prefix(200))
            }
        
        Button("PLACE ORDER") {
            print("Button tapped!")
        }
        .padding(EdgeInsets(top: 35, leading: 20, bottom: 35, trailing: 20))
        .font(.system(size: 30, weight: .bold, design: .rounded))
        .foregroundColor(Color.white)
        .background(Rectangle()
                        .fill(CustomColors.blueGray.opacity(0.6))
                        .frame(width: 322, height: 70)
                        .cornerRadius(15))
        
    }
    .padding(.bottom, keyboard.currentHeight)
    .edgesIgnoringSafeArea(.bottom)
    .animation(.easeOut(duration: 0.16))
    .tabItem {
        Image(systemName: "house.fill")
        Text("Home")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(CustomColors.seafoamGreen)
    .ignoresSafeArea()
    .gesture(DragGesture().onChanged{_ in UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)})
}
}

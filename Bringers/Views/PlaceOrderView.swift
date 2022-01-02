//
//  PlaceOrderView.swift
//  Bringers
//
//  Created by Keith C on 12/20/21.
//

import Foundation
import SwiftUI
import Combine

struct PlaceOrderView: View {
    
    @State private var pickupBuy: String = "Pick-up or buy?"
    @State private var pickupBuyColor: SwiftUI.Color = CustomColors.midGray.opacity(0.5)
    @State private var pickupBuyImageName: String = ""
    @State private var deliveryFee: CGFloat = 0
    @State private var maxItemPrice: CGFloat = 0
    @State private var itemName: String = ""
    @State private var description: String = ""
    
    @State private var isShowingConfirm = false
    @State private var confirmPressed: Bool = false
    @State private var isShowingWaitingForBringer = false
    @State private var isShowingOrderComing = false
    
    @ObservedObject private var keyboard = KeyboardResponder()
    
    var body: some View {
        VStack {
            Text("LOOKING FOR SOMETHING?")
                .font(.system(size: 48, weight: .bold, design: .rounded))
            
            Menu {
                Button {
                    pickupBuy = "Buy"
                    pickupBuyColor = CustomColors.midGray
                    pickupBuyImageName = "tag"
                } label: {
                    Text("Buy")
                    Image(systemName: "tag")
                }
                Button {
                    pickupBuy = "Pick-up"
                    pickupBuyColor = CustomColors.midGray
                    pickupBuyImageName = "bag"
                } label: {
                    Text("Pick-up")
                    Image(systemName: "bag")
                }
            } label: {
                Text(pickupBuy)
                Image(systemName: pickupBuyImageName)
            }
            .font(.system(size: 18, weight: .regular, design: .rounded))
            .foregroundColor(pickupBuyColor)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
            .background(Rectangle()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: 322, height: 50)
                            .cornerRadius(15))
            .padding(EdgeInsets(top: 30, leading: 20, bottom: 15, trailing: 20))
            
            HStack {
                CustomTextboxCurrency(field: $deliveryFee, placeholderText: "Delivery Fee")
                if pickupBuy != "Pick-up" {
                    CustomTextboxCurrency(field: $maxItemPrice, placeholderText: "Max Item Price")
                }
            }
            .padding(EdgeInsets(top: 20, leading: 20, bottom: 5, trailing: 20))
            
            CustomTextbox(field: $itemName, placeholderText: "Name of Item")
                .padding(EdgeInsets(top: 30, leading: 20, bottom: 30, trailing: 20))
            
            TextEditor(text: $description)
                .padding()
                .placeholderTopLeft(when: self.description.isEmpty) {
                    Text("Description").foregroundColor(CustomColors.midGray.opacity(0.5))
                    // makes placeholder even with text in box, not sure why we need this padding
                        .padding(.top, 24)
                        .padding(.leading, 20)
                }
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(CustomColors.midGray)
                .background(Rectangle()
                                .fill(Color.white.opacity(0.5))
                                .frame(width: 322, height: 153)
                                .cornerRadius(15))
                .frame(minWidth: 0, maxWidth: 300, minHeight: 0, maxHeight: 140)
                .onReceive(self.description.publisher.collect()) {
                    self.description = String($0.prefix(200))
                }
            
            Button("PLACE ORDER") {
                self.showConfirmScreen()
            }
            .popover(isPresented: $isShowingConfirm) {
                if self.pickupBuy == "Buy" {
                    ConfirmOrderBuyView(isShowingConfirm: $isShowingConfirm, confirmPressed: $confirmPressed, deliveryFee: deliveryFee, maxItemPrice: maxItemPrice)
                }
                else if self.pickupBuy == "Pick-up" {
                    ConfirmOrderPickupView(isShowingConfirm: $isShowingConfirm, confirmPressed: $confirmPressed, deliveryFee: deliveryFee)
                }
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
            Image(systemName: "cart")
            Text("Order")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
        .gesture(DragGesture().onChanged{_ in UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)})
        .onChange(of: isShowingConfirm) { value in
            if !value && confirmPressed {
                confirmPressed = false
                isShowingWaitingForBringer.toggle()
            }
        }
        .onChange(of: isShowingWaitingForBringer) { value in
            if !value {
                isShowingOrderComing.toggle()
            }
        }
        .fullScreenCover(isPresented: $isShowingWaitingForBringer) {
            WaitingForBringerView(isShowingWaitingForBringer: $isShowingWaitingForBringer)
        }
        .fullScreenCover(isPresented: $isShowingOrderComing) {
            OrderComingMapView(isShowingOrderComing: $isShowingOrderComing)
        }
    }
    
    
    func showConfirmScreen() {
        if (self.pickupBuy == "Buy" || self.pickupBuy == "Pick-up") 
//            self.deliveryFee > 0 &&
//            self.maxItemPrice > 0 &&
//            self.itemName.count > 0 &&
//            self.description.count > 0
        {
            isShowingConfirm.toggle()
        }
    }
}

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
    
    @StateObject private var viewModel = PlaceOrderViewModel()
    
    @Binding var givenOrder: OrderModel
    
    @ObservedObject private var keyboard = KeyboardResponder()
    
    
    var body: some View {
        VStack {
            if !viewModel.hasSavedCreditCard {
                
                CustomTitleText(labelText: "ADD A CREDIT CARD TO GET STARTED!")

                CustomTextbox(field: $viewModel.creditCardNumber, placeholderText: "Credit Card Number", charLimit: 16)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                    .onReceive(Just(viewModel.creditCardNumber)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            viewModel.creditCardNumber = filtered
                        }
                    }
                    .keyboardType(.numberPad)

                CustomTextbox(field: $viewModel.cardholderName, placeholderText: "Cardholder Name")
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))

                CustomTextbox(field: $viewModel.expMonth, placeholderText: "Exp Month", charLimit: 2)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                    .onReceive(Just(viewModel.expMonth)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            viewModel.expMonth = filtered
                        }
                    }
                    .keyboardType(.numberPad)

                CustomTextbox(field: $viewModel.expYear, placeholderText: "Exp Year", charLimit: 2)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                    .onReceive(Just(viewModel.expYear)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            viewModel.expYear = filtered
                        }
                    }
                    .keyboardType(.numberPad)

                CustomTextbox(field: $viewModel.cvcNumber, placeholderText: "CVC", charLimit: 4)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                    .onReceive(Just(viewModel.cvcNumber)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            viewModel.cvcNumber = filtered
                        }
                    }
                    .keyboardType(.numberPad)

                Button("ADD CARD") {
                    viewModel.addCreditCard()
                }
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(Color.white)
                .background(Rectangle()
                                .fill(CustomColors.blueGray.opacity(0.6))
                                .frame(width: CustomDimensions.width, height: 70)
                                .cornerRadius(15))
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20))
            }
            else {
                CustomTitleText(labelText: "LOOKING FOR SOMETHING?")
                
                Menu {
                    Button {
                        viewModel.pickupBuy = "Buy"
                        viewModel.pickupBuyColor = CustomColors.midGray
                        viewModel.pickupBuyImageName = "tag"
                    } label: {
                        Text("Buy")
                        Image(systemName: "tag")
                    }
                    Button {
                        viewModel.pickupBuy = "Pick-up"
                        viewModel.pickupBuyColor = CustomColors.midGray
                        viewModel.pickupBuyImageName = "bag"
                    } label: {
                        Text("Pick-up")
                        Image(systemName: "bag")
                    }
                } label: {
                    Text(viewModel.pickupBuy)
                    Image(systemName: viewModel.pickupBuyImageName)
                }
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(viewModel.pickupBuyColor)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .background(Rectangle()
                                .fill(Color.white.opacity(0.5))
                                .frame(width: CustomDimensions.width, height: 50)
                                .cornerRadius(15))
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
                
                HStack {
                    CustomTextboxCurrency(field: $viewModel.deliveryFee, placeholderText: "Delivery Fee")
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                    if viewModel.pickupBuy != "Pick-up" {
                        CustomTextboxCurrency(field: $viewModel.maxItemPrice, placeholderText: "Max Item Price")
                            .padding(EdgeInsets(top: 0, leading: 26, bottom: 0, trailing: 0))
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .frame(width: CustomDimensions.width, height: 100)
                .fixedSize(horizontal: false, vertical: true)
                
                CustomTextbox(field: $viewModel.itemName, placeholderText: "Name of Item")
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 15, trailing: 20))
                
                CustomMultilineTextbox(field: $viewModel.description, placeholderText: "Description")
                    .padding(EdgeInsets(top: 24, leading: 20, bottom: 30, trailing: 20))
                
                Button("PLACE ORDER") {
                    viewModel.showConfirmScreen()
                }
                
                .sheet(isPresented: $viewModel.isShowingConfirm, onDismiss: {
                    
                    viewModel.getYourProfile()
                    
                    if !viewModel.isShowingConfirm && viewModel.confirmPressed {
                        viewModel.confirmPressed = false
                        viewModel.incrementOrdersPlaced()
                        viewModel.isShowingWaitingForBringer.toggle()
                    }
                }) {
                    ConfirmOrderView(isShowingConfirm: $viewModel.isShowingConfirm, confirmPressed: $viewModel.confirmPressed, order: $viewModel.order)
                }
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(Color.white)
                .background(Rectangle()
                                .fill(CustomColors.blueGray.opacity(0.6))
                                .frame(width: CustomDimensions.width, height: 70)
                                .cornerRadius(15))
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20))
                .accessibility(identifier: "Place Order Place Order Button")
            }
            
        }
        .toast(message: viewModel.toastMessage,
               isShowing: $viewModel.isShowingToast,
               duration: Toast.long
        )
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
        .overlay(
            ProgressView()
                .scaleEffect(x: 2, y: 2, anchor: .center)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3)
                                .fill(CustomColors.seafoamGreen))
                .progressViewStyle(CircularProgressViewStyle(tint: CustomColors.darkGray))
                .isHidden(viewModel.isProgressViewHidden)
        )
        
        .fullScreenCover(isPresented: $viewModel.isShowingWaitingForBringer, onDismiss: {
            if (!viewModel.isShowingWaitingForBringer && !viewModel.isOrderCancelledWaiting) {
                viewModel.isShowingOrderComing.toggle()
                self.givenOrder = OrderModel()
            }
            else if viewModel.isOrderCancelledWaiting {
                viewModel.incrementOrdersCanceled()
            }
            viewModel.isOrderCancelledWaiting = false
        }) {
            WaitingForBringerView(
                isShowingWaitingForBringer: $viewModel.isShowingWaitingForBringer,
                isOrderCancelledWaiting: $viewModel.isOrderCancelledWaiting,
                order: self.givenOrder.status == "waiting" ? $givenOrder : $viewModel.order
            )
        }
        
        .fullScreenCover(isPresented: $viewModel.isShowingOrderComing, onDismiss: {
            if !viewModel.isShowingOrderComing && !viewModel.isOrderCancelledMap {
                viewModel.incrementOrdersCompleted()
            }
            else {
                viewModel.incrementOrdersCanceled()
            }
            viewModel.isOrderCancelledMap = false
            
            self.givenOrder = OrderModel()
        }) {
            OrderComingMapView(
                isShowingOrderComing: $viewModel.isShowingOrderComing,
                isOrderCancelledMap: $viewModel.isOrderCancelledMap,
                order: self.givenOrder.status == "inprogress" ? $givenOrder : $viewModel.order
            )
        }
        .onAppear {
            DispatchQueue.main.async {
                viewModel.getYourProfile()
            }
            
            if self.givenOrder.status == "waiting" && self.givenOrder.id != "" {
                viewModel.isShowingWaitingForBringer = true
            }
            if self.givenOrder.status == "inprogress" && self.givenOrder.id != "" {
                viewModel.isShowingOrderComing = true
            }
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
    }
}

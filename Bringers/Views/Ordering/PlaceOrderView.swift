//
//  PlaceOrderView.swift
//  Bringers
//
//  Created by Keith C on 12/20/21.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import MapKit
import FirebaseDatabase

struct PlaceOrderView: View {
    
    @State private var pickupBuy: String = "Pick-up or buy?"
    @State private var pickupBuyColor: SwiftUI.Color = CustomColors.midGray.opacity(0.5)
    @State private var pickupBuyImageName: String = ""
    @State private var deliveryFee: CGFloat = 0
    @State private var maxItemPrice: CGFloat = 0
    @State private var itemName: String = ""
    @State private var description: String = ""
    
    @State private var order: OrderModel = OrderModel()
    
    @State private var isShowingConfirm: Bool = false
    @State private var confirmPressed: Bool = false
    @State private var confirmDismissed: Bool = false
    @State private var isShowingWaitingForBringer: Bool = false
    @State private var isOrderCancelledWaiting: Bool = false
    @State private var isShowingOrderComing: Bool = false
    @State private var isOrderCancelledMap: Bool = false
    
    @State private var userInfo: UserInfoModel = UserInfoModel()
    
    @State private var hasSavedCreditCard: Bool = true
    
    @State private var creditCardNumber: String = ""
    @State private var cardholderName: String = ""
    @State private var expMonth: String = ""
    @State private var expYear: String = ""
    @State private var cvcNumber: String = ""
    
    @State private var isProgressViewHidden: Bool = false
    
    @Binding var givenOrder: OrderModel
    
    @ObservedObject private var keyboard = KeyboardResponder()
    
    init(givenOrder: Binding<OrderModel>) {
        UITextView.appearance().textContainerInset = UIEdgeInsets(top: 24, left: 17, bottom: 0, right: 0)
        
        self._givenOrder = givenOrder
    }
    
    var body: some View {
        VStack {
            if !self.hasSavedCreditCard {
                CustomTitleText(labelText: "ADD A CREDIT CARD TO GET STARTED!")
                
                // TODO: make exp/creditcardnum number only
                CustomTextbox(field: $creditCardNumber, placeholderText: "Credit Card Number", charLimit: 16)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                    .onReceive(Just(creditCardNumber)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.creditCardNumber = filtered
                        }
                    }
                    .keyboardType(.numberPad)
                
                CustomTextbox(field: $cardholderName, placeholderText: "Cardholder Name")
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                
                CustomTextbox(field: $expMonth, placeholderText: "Exp Month", charLimit: 2)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                    .onReceive(Just(expMonth)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.expMonth = filtered
                        }
                    }
                    .keyboardType(.numberPad)
                
                CustomTextbox(field: $expYear, placeholderText: "Exp Year", charLimit: 2)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                    .onReceive(Just(expYear)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.expYear = filtered
                        }
                    }
                    .keyboardType(.numberPad)
                
                CustomTextbox(field: $cvcNumber, placeholderText: "CVC", charLimit: 4)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                    .onReceive(Just(cvcNumber)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.cvcNumber = filtered
                        }
                    }
                    .keyboardType(.numberPad)
                
                Button("ADD CARD") {
                    self.addCreditCard()
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
                                .frame(width: CustomDimensions.width, height: 50)
                                .cornerRadius(15))
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
                
                HStack {
                    CustomTextboxCurrency(field: $deliveryFee, placeholderText: "Delivery Fee")
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                    if pickupBuy != "Pick-up" {
                        CustomTextboxCurrency(field: $maxItemPrice, placeholderText: "Max Item Price")
                            .padding(EdgeInsets(top: 0, leading: 26, bottom: 0, trailing: 0))
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .frame(width: CustomDimensions.width, height: 100)
                .fixedSize(horizontal: false, vertical: true)
                
                CustomTextbox(field: $itemName, placeholderText: "Name of Item")
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 15, trailing: 20))
                
                TextEditor(text: $description)
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
                                    .frame(width: CustomDimensions.width, height: 153)
                                    .cornerRadius(15))
                    .frame(minWidth: 0, maxWidth: 300, minHeight: 0, maxHeight: 140)
                    .onReceive(self.description.publisher.collect()) {
                        self.description = String($0.prefix(200))
                    }
                    .padding(EdgeInsets(top: 24, leading: 20, bottom: 30, trailing: 20))
                
                Button("PLACE ORDER") {
                    self.showConfirmScreen()
                }
                
                .sheet(isPresented: $isShowingConfirm, onDismiss: {
                    if !isShowingConfirm && confirmPressed {
                        confirmPressed = false
                        isShowingWaitingForBringer.toggle()
                    }
                }) {
                    ConfirmOrderView(isShowingConfirm: $isShowingConfirm, confirmPressed: $confirmPressed, order: $order)
                }
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(Color.white)
                .background(Rectangle()
                                .fill(CustomColors.blueGray.opacity(0.6))
                                .frame(width: CustomDimensions.width, height: 70)
                                .cornerRadius(15))
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20))
            }
            
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
        .overlay(
            ProgressView()
                .scaleEffect(x: 2, y: 2, anchor: .center)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3)
                                .fill(CustomColors.seafoamGreen))
                .progressViewStyle(CircularProgressViewStyle(tint: CustomColors.darkGray))
                .isHidden(self.isProgressViewHidden)
        )
        
        .fullScreenCover(isPresented: $isShowingWaitingForBringer, onDismiss: {
            if (!isShowingWaitingForBringer && !isOrderCancelledWaiting) {
                isShowingOrderComing.toggle()
                givenOrder = OrderModel()
            }
        }) {
            WaitingForBringerView(
                isShowingWaitingForBringer: $isShowingWaitingForBringer,
                isOrderCancelledWaiting: $isOrderCancelledWaiting,
                order: self.givenOrder.status == "waiting" ? $givenOrder : $order
            )
        }
        
        .fullScreenCover(isPresented: $isShowingOrderComing) {
            OrderComingMapView(
                isShowingOrderComing: $isShowingOrderComing,
                isOrderCancelledMap: $isOrderCancelledMap,
                order: self.givenOrder.status == "inprogress" ? $givenOrder : $order
            )
        }
        .onAppear {
            DispatchQueue.main.async {
                getYourProfile()
            }
            
            if self.givenOrder.status == "waiting" {
                isShowingWaitingForBringer = true
            }
            if self.givenOrder.status == "inprogress" {
                isShowingOrderComing = true
            }
        }
        
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
    }
    
    
    func showConfirmScreen() {
        
        if self.deliveryFee > 0 &&
            self.itemName.count > 0 &&
            self.description.count > 0
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/YYYY"
            let currentDateString = dateFormatter.string(from: Date())
            
            let userID = Auth.auth().currentUser!.uid
            
            self.order = OrderModel(
                id: UUID().uuidString,
                title: self.itemName,
                description: self.description,
                pickupBuy: self.pickupBuy,
                maxPrice: self.pickupBuy == "Buy" && self.maxItemPrice > 0 ? self.maxItemPrice : 0,
                deliveryFee: self.deliveryFee,
                dateSent: currentDateString,
                dateCompleted: "",
                status: "waiting",
                userID: userID,
                location: DefaultCoords.coords
            )
            
            isShowingConfirm.toggle()
        }
        else {
            print("error")
        }
    }
    
    func getYourProfile() {
        
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference()
        
        ref.child("users").child(userID).child("userInfo").observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let activeUserInfo = snapshot.value as? NSDictionary else {
                return
            }
            
            guard let activeUserInfoMap = UserInfo.from(activeUserInfo) else {
                return
            }
            
            let userInfo = UserInfoModel(
                dateOfBirth: activeUserInfoMap.dateOfBirth,
                dateOfCreation: activeUserInfoMap.dateOfCreation,
                email: activeUserInfoMap.email,
                firstName: activeUserInfoMap.firstName,
                lastName: activeUserInfoMap.lastName,
                ordersCompleted: activeUserInfoMap.ordersCompleted,
                ordersPlaced: activeUserInfoMap.ordersPlaced,
                phoneNumber: activeUserInfoMap.phoneNumber,
                profilePictureURL: activeUserInfoMap.profilePictureURL,
                rating: activeUserInfoMap.rating,
                stripeAccountID: activeUserInfoMap.stripeAccountID,
                stripeCustomerID: activeUserInfoMap.stripeCustomerID,
                address: activeUserInfoMap.address,
                state: activeUserInfoMap.state,
                city: activeUserInfoMap.city,
                country: activeUserInfoMap.country,
                zipcode: activeUserInfoMap.zipcode
            )
            
            self.userInfo = userInfo
            
            fetchCustomerDetails()
        })
    }
    
    func fetchCustomerDetails() {
        let url = URL(string: "https://bringers-nodejs.vercel.app/get-customer-details")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(["customerID" : self.userInfo.stripeCustomerID])
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data,
                  error == nil,
                  (response as? HTTPURLResponse)?.statusCode == 200,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                  let _ = json["defaultSource"] as? String else {
                      self.hasSavedCreditCard = false
                      self.isProgressViewHidden = true
                      return
                  }
            self.hasSavedCreditCard = true
            self.isProgressViewHidden = true
        }.resume()
    }
    
    // TODO: show error toasts if credit card not valid/not added
    func addCreditCard() {
        let url = URL(string: "https://bringers-nodejs.vercel.app/add-credit-card")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode([
            "customerID" : self.userInfo.stripeCustomerID,
            "ccNumber" : self.creditCardNumber,
            "expMonth" : self.expMonth,
            "expYear" : self.expYear,
            "cvc" : self.cvcNumber
        ])
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data,
                  error == nil,
                  (response as? HTTPURLResponse)?.statusCode == 200,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                  let _ = json["defaultSource"] as? String else {
                      self.hasSavedCreditCard = false
                      return
                  }
            self.hasSavedCreditCard = true
        }.resume()
    }
}

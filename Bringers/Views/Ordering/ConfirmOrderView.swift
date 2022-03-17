//
//  ConfirmOrderView.swift
//  Bringers
//
//  Created by Keith C on 12/20/21.
//

import Foundation
import SwiftUI
import FirebaseDatabase
import FirebaseAuth
import Stripe

struct ConfirmOrderView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @Binding private var isShowingConfirm: Bool
    @Binding private var confirmPressed: Bool
    @Binding private var order: OrderModel
    
    @State private var isShowingPaymentSheet: Bool = false
    
    @State private var ordererInfo: UserInfoModel = UserInfoModel()
    
    @State private var paymentIntentID: String = ""
    
    @State private var paymentSheet: PaymentSheet?
    @State private var paymentResult: PaymentSheetResult?
    
    // TODO: i dont think this init is needed but im in the middle of something; delete and test later
    init(isShowingConfirm: Binding<Bool>, confirmPressed: Binding<Bool>, order: Binding<OrderModel>) {
        self._isShowingConfirm = isShowingConfirm
        self._confirmPressed = confirmPressed
        self._order = order
    }
    
    var body: some View {
        VStack {
            if isShowingPaymentSheet {
                VStack {
                    CustomTitleText(labelText: "CONFIRM PAYMENT METHOD")
                    
                    CustomLabel(labelText: "On confirmation of payment type you will be charged and the order will be placed", height: 75, fontSize: 14)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 25, trailing: 20))
                    
                    if let paymentSheet = self.paymentSheet {
                        PaymentSheet.PaymentButton(
                            paymentSheet: paymentSheet,
                            onCompletion: self.onPaymentCompletion
                        ) {
                            Text("CONFIRM PAYMENT")
                            .padding(EdgeInsets(top: 35, leading: 20, bottom: 35, trailing: 20))
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(Color.white)
                            .background(Rectangle()
                                            .fill(CustomColors.blueGray.opacity(0.6))
                                            .frame(width: CustomDimensions.width, height: 70)
                                            .cornerRadius(15))
                        }
                    } else {
                        Text("Loading…")
                    }
                }
            }
            else {
                CustomTitleText(labelText: "CONFIRM THE FOLLOWING:")
                
                if order.pickupBuy == "Buy" {
                    CustomLabel(labelText: "ESTIMATED MAXIMUM COST:", isBold: true)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 15, trailing: 20))
                    
                    // TODO: calc tax based on location (change 0.0625 to be dynamic)
                    let estTax = round(CGFloat(order.maxPrice) * 0.0625 * 100) / 100.0
                    
                    CustomLabel(labelText: "MAX ITEM PRICE = $" + String(format:"%.02f", order.maxPrice) + "\nDELIVERY FEE = $" + String(format:"%.02f", order.deliveryFee) + "\nESTIMATED SALES TAX = $" + "\(estTax)", height: 100)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 5, trailing: 20))
                    
                    CustomLabel(labelText: "TOTAL ESTIMATED MAXIMUM COST = $" + String(format:"%.02f", (estTax + order.maxPrice + order.deliveryFee)), height: 75, isBold: true)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 15, trailing: 20))
                    
                    CustomLabel(labelText: "Note: If the actual item price is cheaper than the max item price, you will be refunded the difference when the order is complete", height: 75, fontSize: 14)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 25, trailing: 20))
                }
                else {
                    CustomLabel(labelText: "DELIVERY FEE = $" + String(format:"%.02f", order.deliveryFee))
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 5, trailing: 20))
                    
                    CustomLabel(labelText: "TOTAL COST = $" + String(format:"%.02f", order.deliveryFee), isBold: true)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 15, trailing: 20))
                }
                
                Text("By pressing “PLACE ORDER” you agree to the terms and conditions of the Bringers app")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(CustomColors.midGray)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minWidth: 0, maxWidth: CustomDimensions.width, minHeight: 0, maxHeight: 10)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 15, trailing: 20))
                
                Button("CONFIRM DETAILS") {
                    preparePaymentSheet { _ in
                        self.isShowingPaymentSheet.toggle()
                    }
                }
                .padding(EdgeInsets(top: 35, leading: 20, bottom: 35, trailing: 20))
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(Color.white)
                .background(Rectangle()
                                .fill(CustomColors.blueGray.opacity(0.6))
                                .frame(width: CustomDimensions.width, height: 70)
                                .cornerRadius(15))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
        .onAppear {
            self.getYourProfile()
        }
    }
    
    func sendOrder() {
        let ref = Database.database().reference()
        let userID = Auth.auth().currentUser!.uid
        
        let orderJson = [
            "id": order.id,
            "title": order.title,
            "description": order.description,
            "pickupBuy": order.pickupBuy,
            "dateSent": order.dateSent,
            "dateCompleted": order.dateCompleted,
            "maxPrice": order.maxPrice,
            "deliveryFee": order.deliveryFee,
            "status": order.status,
            "userID": order.userID,
            "paymentIntentID": self.paymentIntentID
        ] as [String : Any]
        
        ref.child("activeOrders").updateChildValues([order.id : orderJson])
        ref.child("users").child(userID).child("activeOrders").updateChildValues(["activeOrder" : order.id])
        
        confirmPressed = true
        isShowingConfirm = false
    }
    
    func getYourProfile() {
        
        let ref = Database.database().reference()
        
        ref.child("users").child(self.order.userID).child("userInfo").observeSingleEvent(of: .value, with: { (snapshot) in
            
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
                ordersCanceled: activeUserInfoMap.ordersCanceled,
                bringersCompleted: activeUserInfoMap.bringersCompleted,
                bringersAccepted: activeUserInfoMap.bringersAccepted,
                bringersCanceled: activeUserInfoMap.bringersCanceled,
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
            
            self.ordererInfo = userInfo
        })
    }
    
    func preparePaymentSheet(completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://bringers-nodejs.vercel.app/payment-sheet")!
        
        // TODO: calc tax based on location (change 0.0625 to be dynamic)
        let estTax = round(CGFloat(self.order.maxPrice) * 0.0625 * 100)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode([
            "customerID" : self.ordererInfo.stripeCustomerID,
            "deliveryFee" : "\(Int((self.order.deliveryFee * 100) + (self.order.maxPrice * 100) + estTax))"
        ])
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data,
                  error == nil,
                  (response as? HTTPURLResponse)?.statusCode == 200,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                  let customerId = json["customer"] as? String,
                  let customerEphemeralKeySecret = json["ephemeralKey"] as? String,
                  let intentClientSecret = json["paymentIntent"] as? String,
                  let paymentIntentID = json["paymentIntentID"] as? String,
                  let publishableKey = json["publishableKey"] as? String else {
                      completion(nil)
                      return
                  }
            
            self.paymentIntentID = paymentIntentID
            
            STPAPIClient.shared.publishableKey = publishableKey
            // MARK: Create a PaymentSheet instance
            var configuration = PaymentSheet.Configuration()
            configuration.merchantDisplayName = "Bringers"
            configuration.customer = .init(id: customerId, ephemeralKeySecret: customerEphemeralKeySecret)
            // Set `allowsDelayedPaymentMethods` to true if your business can handle payment
            // methods that complete payment after a delay, like SEPA Debit and Sofort.
            configuration.allowsDelayedPaymentMethods = true
            
            DispatchQueue.main.async {
                self.paymentSheet = PaymentSheet(paymentIntentClientSecret: intentClientSecret, configuration: configuration)
            }
            
            completion(intentClientSecret)
        }.resume()
    }
    
    func onPaymentCompletion(result: PaymentSheetResult) {
        self.paymentResult = result
        
        switch self.paymentResult {
        case .completed:
            sendOrder()
            print("Payment complete")
        case .failed(let error):
            print("Payment failed: \(error.localizedDescription)")
        case .canceled:
            print("Payment canceled.")
        case .none:
            print("None?")
        }
    }
}

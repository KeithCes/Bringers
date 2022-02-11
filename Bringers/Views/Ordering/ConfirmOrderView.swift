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
    
    @State private var paymentMethodParams: STPPaymentMethodParams?
    
    @State private var isActive: Bool = false
    
    let paymentGatewayController = PaymentGatewayController()
    
    init(isShowingConfirm: Binding<Bool>, confirmPressed: Binding<Bool>, order: Binding<OrderModel>) {
        self._isShowingConfirm = isShowingConfirm
        self._confirmPressed = confirmPressed
        self._order = order
    }
    
    var body: some View {
        VStack {
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
                
                CustomLabel(labelText: "Note: Final costs may be slightly different than estimates due to actual item prices", height: 75, fontSize: 14)
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
            
            Button("PLACE ORDER") {
                startCheckout { clientSecret in
                
                    PaymentConfig.shared.paymentIntentClientSecret = clientSecret
                    
                    DispatchQueue.main.async {
                        isActive = true
                    }
                }
            }
            .fullScreenCover(isPresented: $isActive) {
                CheckoutView()
            }
            .padding(EdgeInsets(top: 35, leading: 20, bottom: 35, trailing: 20))
            .font(.system(size: 30, weight: .bold, design: .rounded))
            .foregroundColor(Color.white)
            .background(Rectangle()
                            .fill(CustomColors.blueGray.opacity(0.6))
                            .frame(width: CustomDimensions.width, height: 70)
                            .cornerRadius(15))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
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
            "userID": order.userID
        ] as [String : Any]
        
        ref.child("activeOrders").updateChildValues([order.id : orderJson])
        ref.child("users").child(userID).child("activeOrders").updateChildValues(["activeOrder" : order.id])
        
        confirmPressed = true
        isShowingConfirm = false
        
        pay()
    }
    
    private func startCheckout(completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://bringers-nodejs.vercel.app/create-payment-intent")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(["poo" : "ass"])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil,
                    (response as? HTTPURLResponse)?.statusCode == 200 else {
                completion(nil)
                return
            }
            let checkoutIntentResponse = try? JSONDecoder().decode(CheckoutIntentResponse.self, from: data)
            completion(checkoutIntentResponse?.clientSecret)
        }.resume()
    }
    
    private func pay() {
        guard let clientSecret = PaymentConfig.shared.paymentIntentClientSecret else {
            return
        }
        
        let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
        paymentIntentParams.paymentMethodParams = paymentMethodParams
        
        paymentGatewayController.submitPayment(intent: paymentIntentParams) { status, intent, error in
            switch status {
            case .failed:
                print("failed")
                break
            case .canceled:
                print("cancelled")
                break
            case .succeeded:
                print("succeeded")
                break
            }
        }
    }
}

//
//  ConfirmOrderViewModel.swift
//  Bringers
//
//  Created by Keith C on 3/25/22.
//

import Foundation
import Stripe
import FirebaseAuth
import FirebaseDatabase
import SwiftUI

final class ConfirmOrderViewModel: ObservableObject {
    
    @Published var isShowingPaymentSheet: Bool = false
    
    @Published var ordererInfo: UserInfoModel = UserInfoModel()
    
    @Published var paymentIntentID: String = ""
    
    @Published var paymentSheet: PaymentSheet?
    @Published var paymentResult: PaymentSheetResult?
    
    @Published var order: OrderModel = OrderModel()
    
    @Published var confirmPressed: Bool = false
    
    
    private func sendOrder() {
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
    }
    
    func getYourProfile(userID: String) {
        
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
                ordersCanceled: activeUserInfoMap.ordersCanceled,
                bringersCompleted: activeUserInfoMap.bringersCompleted,
                bringersAccepted: activeUserInfoMap.bringersAccepted,
                bringersCanceled: activeUserInfoMap.bringersCanceled,
                phoneNumber: activeUserInfoMap.phoneNumber,
                profilePictureURL: activeUserInfoMap.profilePictureURL,
                rating: activeUserInfoMap.rating,
                totalRatings: activeUserInfoMap.totalRatings,
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
            
            DispatchQueue.main.async {
                self.paymentIntentID = paymentIntentID
            }
            
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
    
    func passOrder(order: OrderModel) {
        self.order = order
    }
}

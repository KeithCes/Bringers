//
//  BringerOrderCompleteConfirmationViewModel.swift
//  Bringers
//
//  Created by Keith C on 3/27/22.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

final class BringerOrderCompleteConfirmationViewModel: ObservableObject {
    
    @Published var ordererInfo: UserInfoModel = UserInfoModel()
    @Published var bringerInfo: UserInfoModel = UserInfoModel()
    
    @Published var actualItemPrice: String = ""
    
    @Published var chargeID: String = ""
    
    @Published var isCompleteButtonEnabled: Bool = true
    
    private var userProfitPercent = 0.75
    
    
    func getOrdererDetails(userID: String) {
        
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
    
    func getBringerDetails(userID: String) {
        
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
            
            self.bringerInfo = userInfo
            
            self.getOrdererDetails(userID: userID)
        })
    }
    
    func completeOrder(currentOrder: OrderModel, completion: @escaping (Bool?) -> Void) {
        let url = URL(string: "https://bringers-nodejs.vercel.app/complete-order")!
        
        let actualItemPrice = actualItemPrice.currencyAsCGFloat()
        
        getOrderChargeID(orderID: currentOrder.id) { _ in
            // TODO: calc tax based on location (change 0.0625 to be dynamic)
            let itemPriceDiff = round(currentOrder.maxPrice * 100 * 1.0625) - round(actualItemPrice * 100 * 1.0625)
            
            let bringerProfits = currentOrder.deliveryFee * 100 * self.userProfitPercent
            
            // TODO: calc tax based on location (change 0.0625 to be dynamic)
            let actualItemPriceWithTax = round(actualItemPrice * 100 * 1.0625)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try! JSONEncoder().encode([
                "amount" : "\(Int(bringerProfits + actualItemPriceWithTax))",
                "accountID" : self.bringerInfo.stripeAccountID,
                "refundAmount" : "\(Int(itemPriceDiff))",
                "chargeID" : self.chargeID,
            ])
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let _ = data, error == nil,
                      (response as? HTTPURLResponse)?.statusCode == 200 else {
                          self.isCompleteButtonEnabled = true
                          completion(nil)
                          return
                      }
                completion(true)
            }.resume()
        }
    }
    
    func completeOrderNoRefund(currentOrder: OrderModel, completion: @escaping (Bool?) -> Void) {
        let url = URL(string: "https://bringers-nodejs.vercel.app/complete-order-norefund")!
        
        let actualItemPrice = actualItemPrice.currencyAsCGFloat()
        
        let bringerProfits = currentOrder.deliveryFee * 100 * self.userProfitPercent
        
        // TODO: calc tax based on location (change 0.0625 to be dynamic)
        let actualItemPriceWithTax = round(actualItemPrice * 100 * 1.0625)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode([
            "amount" : "\(Int(bringerProfits + actualItemPriceWithTax))",
            "accountID" : self.bringerInfo.stripeAccountID,
        ])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil,
                  (response as? HTTPURLResponse)?.statusCode == 200 else {
                      self.isCompleteButtonEnabled = true
                      completion(nil)
                      return
                  }
            completion(true)
        }.resume()
    }
    
    func getOrderChargeID(orderID: String, completion: @escaping (Bool?) -> Void) {
        let ref = Database.database().reference()
        
        ref.child("activeOrders").child(orderID).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let activeUser = (snapshot.value as? [AnyHashable : Any]) else {
                self.isCompleteButtonEnabled = true
                completion(nil)
                return
            }
            
            guard let chargeID = (activeUser["chargeID"] as? String) else {
                self.isCompleteButtonEnabled = true
                completion(nil)
                return
            }

            self.chargeID = chargeID
            completion(true)
        })
    }
}

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
    
    @Published var ordererInfo: UserInfoModel = UserInfoModel()
    
    @Published var order: OrderModel = OrderModel()
    
    @Published var confirmPressed: Bool = false
    
    
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
    
    func passOrder(order: OrderModel) {
        self.order = order
    }
}

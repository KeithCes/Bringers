//
//  BringerOrderCompleteConfirmation.swift
//  Bringers
//
//  Created by Keith C on 2/16/22.
//

import Foundation
import SwiftUI
import MapKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

struct BringerOrderCompleteConfirmation: View {
    
    @Binding var isShowingBringerCompleteConfirmation: Bool
    @Binding var isOrderSuccessfullyCompleted: Bool
    @Binding var currentOrder: OrderModel
    
    @State private var ordererInfo: UserInfoModel = UserInfoModel()
    @State private var bringerInfo: UserInfoModel = UserInfoModel()
    
    @State private var actualItemPrice: String = ""
    
    var body: some View {
        VStack {
            CustomTitleText(labelText: "IS THE ORDER COMPLETED?")
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
            
            if currentOrder.pickupBuy == "Buy" {
                CustomLabel(labelText: "How much did the item ACTUALLY cost?", height: 75, fontSize: 14)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 25, trailing: 20))
                
                if CGFloat(Int(actualItemPrice) ?? 0) > currentOrder.maxPrice {
                    CustomLabel(labelText: "THE ACTUAL PRICE CANNOT EXCEED THE MAX PRICE REQUESTED BY THE ORDERER", height: 75, fontSize: 14, backgroundColor: CustomColors.lightRed)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 25, trailing: 20))
                }
                
                // TODO: make number/currency only for textfield
                CustomTextbox(field: $actualItemPrice, placeholderText: "Actual Item Price")
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 25, trailing: 20))
                
                if CGFloat(Int(actualItemPrice) ?? 0) < currentOrder.maxPrice && actualItemPrice.count > 0 {
                    Button("COMPLETE ORDER") {
                        self.isShowingBringerCompleteConfirmation.toggle()
                        self.isOrderSuccessfullyCompleted = true
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
            else {
                Button("COMPLETE ORDER") {
                    self.isShowingBringerCompleteConfirmation.toggle()
                    self.isOrderSuccessfullyCompleted = true
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 250, trailing: 0))
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
        .onAppear {
            getBringerDetails()
        }
    }
    
    func getOrdererDetails() {
        
        let ref = Database.database().reference()
        
        ref.child("users").child(self.currentOrder.userID).child("userInfo").observeSingleEvent(of: .value, with: { (snapshot) in
            
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
            
            self.ordererInfo = userInfo
        })
    }
    
    func getBringerDetails() {
        
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
            
            self.bringerInfo = userInfo
            
            getOrdererDetails()
        })
    }
}

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
    
    // amount we payout to user
    var userProfitPercent = 0.75
    
    var body: some View {
        VStack {
            CustomTitleText(labelText: "IS THE ORDER COMPLETED?")
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
            
            // if buy
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
                        payoutBringer { success in
                            guard let success = success else {
                                return
                            }
                            if success {
                                self.isShowingBringerCompleteConfirmation.toggle()
                                self.isOrderSuccessfullyCompleted = true
                            }
                        }
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
            // if pickup
            else {
                Button("COMPLETE ORDER") {
                    payoutBringer { success in
                        guard let success = success else {
                            return
                        }
                        if success {
                            self.isShowingBringerCompleteConfirmation.toggle()
                            self.isOrderSuccessfullyCompleted = true
                        }
                    }
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
    
    private func payoutBringer(completion: @escaping (Bool?) -> Void) {
        let url = URL(string: "https://bringers-nodejs.vercel.app/payout-account")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode([
            "amount" : "\(Int(self.currentOrder.deliveryFee * 100 * self.userProfitPercent))",
            "accountID" : self.bringerInfo.stripeAccountID,
        ])
        
        print("\(Int(self.currentOrder.deliveryFee * 100 * self.userProfitPercent))")
        print(self.bringerInfo.stripeAccountID)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil,
                  (response as? HTTPURLResponse)?.statusCode == 200 else {
                      completion(nil)
                      return
                  }
            completion(true)
        }.resume()
    }
}

//
//  PlaceOrderViewModel.swift
//  Bringers
//
//  Created by Keith C on 3/25/22.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseDatabase

final class PlaceOrderViewModel: ObservableObject {
    
    @Published var pickupBuy: String = "Pick-up or buy?"
    @Published var pickupBuyColor: SwiftUI.Color = CustomColors.midGray.opacity(0.5)
    @Published var pickupBuyImageName: String = ""
    @Published var deliveryFee: CGFloat = 0
    @Published var maxItemPrice: CGFloat = 0
    @Published var itemName: String = ""
    @Published var description: String = ""
    
    @Published var order: OrderModel = OrderModel()
    
    @Published var isShowingConfirm: Bool = false
    @Published var confirmPressed: Bool = false
    @Published var confirmDismissed: Bool = false
    @Published var isShowingWaitingForBringer: Bool = false
    @Published var isOrderCancelledWaiting: Bool = false
    @Published var isShowingOrderComing: Bool = false
    @Published var isOrderCancelledMap: Bool = false
    
    @Published var userInfo: UserInfoModel = UserInfoModel()
    
    @Published var hasSavedCreditCard: Bool = true
    
    @Published var creditCardNumber: String = ""
    @Published var cardholderName: String = ""
    @Published var expMonth: String = ""
    @Published var expYear: String = ""
    @Published var cvcNumber: String = ""
    
    @Published var isShowingToast: Bool = false
    @Published var toastMessage: String = "Error"
    
    @Published var isProgressViewHidden: Bool = false
    
    
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
            
            self.userInfo = userInfo
            
            self.fetchCustomerDetails()
        })
    }
    
    func fetchCustomerDetails() {
        let url = URL(string: BuildConfigURL.url + "get-customer-details")!
        
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
            DispatchQueue.main.async {
                self.hasSavedCreditCard = true
                self.isProgressViewHidden = true
            }
        }.resume()
    }
    
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
                      DispatchQueue.main.async {
                          self.hasSavedCreditCard = false
                          self.toastMessage = "Error: credit card invalid"
                          self.isShowingToast.toggle()
                      }
                      return
                  }
            self.hasSavedCreditCard = true
        }.resume()
    }
    
    func incrementOrdersPlaced() {
        let ref = Database.database().reference()
        let userID = Auth.auth().currentUser!.uid
        
        ref.child("users").child(userID).child("userInfo").updateChildValues(["ordersPlaced" : self.userInfo.ordersPlaced + 1])
    }
    
    func incrementOrdersCanceled() {
        let ref = Database.database().reference()
        let userID = Auth.auth().currentUser!.uid
        
        ref.child("users").child(userID).child("userInfo").updateChildValues(["ordersCanceled" : self.userInfo.ordersCanceled + 1])
    }
    
    func incrementOrdersCompleted() {
        let ref = Database.database().reference()
        let userID = Auth.auth().currentUser!.uid
        
        ref.child("users").child(userID).child("userInfo").updateChildValues(["ordersCompleted" : self.userInfo.ordersCompleted + 1])
    }
}

//
//  UserInfoModel.swift
//  Bringers
//
//  Created by Keith C on 1/28/22.
//

import Foundation
import SwiftUI

struct UserInfoModel {
    var dateOfBirth: String = ""
    var dateOfCreation: String = ""
    var email: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var ordersCompleted: CGFloat = 0
    var ordersPlaced: CGFloat = 0
    var ordersCanceled: CGFloat = 0
    var bringersCompleted: CGFloat = 0
    var bringersAccepted: CGFloat = 0
    var bringersCanceled: CGFloat = 0
    var phoneNumber: String = ""
    var profilePictureURL: String = ""
    var rating: CGFloat = 0
    var totalRatings: CGFloat = 0
    var stripeAccountID: String = ""
    var stripeCustomerID: String = ""
    var address: String = ""
    var state: String = ""
    var city: String = ""
    var country: String = ""
    var zipcode: String = ""
    
    init(){}
    
    init(dateOfBirth: String, dateOfCreation: String, email: String, firstName: String, lastName: String, ordersCompleted: CGFloat, ordersPlaced: CGFloat, ordersCanceled: CGFloat, bringersCompleted: CGFloat, bringersAccepted: CGFloat, bringersCanceled: CGFloat, phoneNumber: String, profilePictureURL: String, rating: CGFloat, totalRatings: CGFloat, stripeAccountID: String, stripeCustomerID: String, address: String, state: String, city: String, country: String, zipcode: String) {
        self.dateOfBirth = dateOfBirth
        self.dateOfCreation = dateOfCreation
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.ordersCompleted = ordersCompleted
        self.ordersPlaced = ordersPlaced
        self.ordersCanceled = ordersCanceled
        self.bringersCompleted = bringersCompleted
        self.bringersAccepted = bringersAccepted
        self.bringersCanceled = bringersCanceled
        self.phoneNumber = phoneNumber
        self.profilePictureURL = profilePictureURL
        self.rating = rating
        self.totalRatings = totalRatings
        self.stripeAccountID = stripeAccountID
        self.stripeCustomerID = stripeCustomerID
        self.address = address
        self.state = state
        self.city = city
        self.country = country
        self.zipcode = zipcode
    }
}

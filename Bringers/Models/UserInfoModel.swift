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
    var phoneNumber: String = ""
    
    init(){}
    
    init(dateOfBirth: String, dateOfCreation: String, email: String, firstName: String, lastName: String, ordersCompleted: CGFloat, ordersPlaced: CGFloat, phoneNumber: String) {
        self.dateOfBirth = dateOfBirth
        self.dateOfCreation = dateOfCreation
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.ordersCompleted = ordersCompleted
        self.ordersPlaced = ordersPlaced
        self.phoneNumber = phoneNumber
    }
}

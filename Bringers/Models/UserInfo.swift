//
//  UserInfo.swift
//  Bringers
//
//  Created by Keith C on 1/28/22.
//

import Foundation
import Mapper
import SwiftUI

struct UserInfo: Mappable {
    let dateOfBirth: String
    let dateOfCreation: String
    let email: String
    let firstName: String
    let lastName: String
    let ordersCompleted: CGFloat
    let ordersPlaced: CGFloat
    let phoneNumber: String
    let profilePictureURL: String
    let rating: CGFloat
    let stripeAccountID: String
    
    init(map: Mapper) throws {
        try dateOfBirth = map.from("dateOfBirth")
        try dateOfCreation = map.from("dateOfCreation")
        try email = map.from("email")
        try firstName = map.from("firstName")
        try lastName = map.from("lastName")
        try ordersCompleted = map.from("ordersCompleted")
        try ordersPlaced = map.from("ordersPlaced")
        try phoneNumber = map.from("phoneNumber")
        try profilePictureURL = map.from("profilePictureURL")
        try rating = map.from("rating")
        try stripeAccountID = map.from("stripeAccountID")
    }
}

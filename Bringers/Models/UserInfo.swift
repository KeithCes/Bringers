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
    let stripeCustomerID: String
    let address: String
    let state: String
    let city: String
    let country: String
    let zipcode: String
    
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
        try stripeCustomerID = map.from("stripeCustomerID")
        try address = map.from("address")
        try state = map.from("state")
        try city = map.from("city")
        try country = map.from("country")
        try zipcode = map.from("zipcode")
    }
}

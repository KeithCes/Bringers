//
//  OrderModel.swift
//  Bringers
//
//  Created by Keith C on 1/6/22.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct OrderModel: Identifiable {
    var id: String = ""
    var title: String = ""
    var description: String = ""
    var pickupBuy: String = ""
    var dateSent: String = ""
    var dateCompleted: String = ""
    var maxPrice: CGFloat = 0
    var deliveryFee: CGFloat = 0
    var status: String = ""
    var userID: String = ""
    // TODO: add location?
    
    init(){}
    
    init(id: String, title: String, description: String, pickupBuy: String, maxPrice: CGFloat, deliveryFee: CGFloat, dateSent: String, dateCompleted: String, status: String, userID: String) {
        self.id = id
        self.title = title
        self.description = description
        self.pickupBuy = pickupBuy
        self.dateSent = dateSent
        self.dateCompleted = dateCompleted
        self.maxPrice = maxPrice
        self.deliveryFee = deliveryFee
        self.status = status
        self.userID = userID
    }
}

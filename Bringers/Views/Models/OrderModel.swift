//
//  OrderModel.swift
//  Bringers
//
//  Created by Keith C on 1/6/22.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct OrderModel {
    var id: UUID = UUID()
    var title: String = ""
    var description: String = ""
    var pickupBuy: String = ""
    var dateSent: String = ""
    var dateCompleted: String = ""
    var maxPrice: CGFloat = 0
    var deliveryFee: CGFloat = 0
    var status: String = "active"
    var userID: String = ""
    // TODO: add location?
    
    init(){}
    
    init(title: String, description: String, pickupBuy: String, maxPrice: CGFloat, deliveryFee: CGFloat) {
        self.title = title
        self.description = description
        self.pickupBuy = pickupBuy
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YYYY"
        let currentDateString = dateFormatter.string(from: Date())
        self.dateSent = currentDateString
        
        self.maxPrice = maxPrice
        self.deliveryFee = deliveryFee
        
        let userID = Auth.auth().currentUser!.uid
        self.userID = userID
    }
}

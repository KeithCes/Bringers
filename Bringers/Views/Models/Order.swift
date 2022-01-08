//
//  Order.swift
//  Bringers
//
//  Created by Keith C on 1/7/22.
//

import Foundation
import Mapper
import SwiftUI

struct Order: Mappable {
    let id: String
    let description: String
    let dateSent: String
    let dateCompleted: String
    let deliveryFee: CGFloat
    let maxPrice: CGFloat
    let title: String
    let pickupBuy: String
    let status: String
    let userID: String
    
    init(map: Mapper) throws {
        try id = map.from("id")
        try description = map.from("description")
        try dateSent = map.from("dateSent")
        try dateCompleted = map.from("dateCompleted")
        try deliveryFee = map.from("deliveryFee")
        try maxPrice = map.from("maxPrice")
        try title = map.from("title")
        try pickupBuy = map.from("pickupBuy")
        try status = map.from("status")
        try userID = map.from("userID")
    }
}

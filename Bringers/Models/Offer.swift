//
//  Offer.swift
//  Bringers
//
//  Created by Keith C on 4/1/22.
//

import Foundation
import Mapper
import SwiftUI
import MapKit

struct Offer: Mappable {
    let id: String
    let bringerID: String
    let offerAmount: CGFloat
    let bringerLocation: CLLocationCoordinate2D
    
    init(map: Mapper) throws {
        try id = map.from("id")
        try bringerID = map.from("bringerID")
        try offerAmount = map.from("offerAmount")
        try bringerLocation = map.from("bringerLocation")
    }
}

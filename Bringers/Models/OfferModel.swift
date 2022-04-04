//
//  OfferModel.swift
//  Bringers
//
//  Created by Keith C on 4/1/22.
//

import Foundation
import SwiftUI
import MapKit

struct OfferModel: Identifiable {
    var id: String = ""
    var bringerID: String = ""
    var bringerLocation: CLLocationCoordinate2D = DefaultCoords.coords
    var offerAmount: CGFloat = 0
    
    init(){}
    
    init(id: String, bringerID: String, bringerLocation: CLLocationCoordinate2D, offerAmount: CGFloat) {
        self.id = id
        self.bringerID = bringerID
        self.bringerLocation = bringerLocation
        self.offerAmount = offerAmount
    }
}

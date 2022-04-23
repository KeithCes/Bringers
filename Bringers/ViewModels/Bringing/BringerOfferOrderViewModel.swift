//
//  BringerOfferOrderViewModel.swift
//  Bringers
//
//  Created by Keith C on 4/8/22.
//

import Foundation
import SwiftUI
import FirebaseAuth
import MapKit

final class BringerOfferOrderViewModel: ObservableObject {
    
    @Published var offerAmount: CGFloat = 0
    
    
    func createOffer(orderID: String, bringerCoords: CLLocationCoordinate2D) -> OfferModel {
        let userID = Auth.auth().currentUser!.uid
        
        let offer = OfferModel(
            id: UUID().uuidString,
            bringerID: userID,
            bringerLocation: bringerCoords,
            offerAmount: self.offerAmount
        )
        
        return offer
    }
}

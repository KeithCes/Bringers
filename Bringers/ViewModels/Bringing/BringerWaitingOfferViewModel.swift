//
//  BringerWaitingOfferViewModel.swift
//  Bringers
//
//  Created by Keith C on 4/11/22.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import MapKit

final class BringerWaitingOfferViewModel: ObservableObject {
    
    @Published var isOfferAccepted: Bool = false
    @Published var isShowingWaitingForBringer: Bool = false
    
    @Published var animationAmount: CGFloat = 1
    
    @Published var timer: Timer?
    
    
    func deactivateOffer(orderID: String) {
        
        let userID = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        
        ref.child("activeOrders").child(orderID).child("offers").child(userID).removeValue()
        
        self.isShowingWaitingForBringer.toggle()
    }
    
    func checkOfferAccepted(orderID: String) {
        
        let userID = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        
        ref.child("activeOrders").child(orderID).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshotDict = (snapshot.value as? NSDictionary) else {
                return
            }
            
            guard let bringerID = snapshotDict["bringerID"] as? String else {
                return
            }
            
            if bringerID == userID {
                self.isOfferAccepted = true
                self.isShowingWaitingForBringer.toggle()
            }
        })
    }
}

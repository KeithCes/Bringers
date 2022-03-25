//
//  PrelogViewModel.swift
//  Bringers
//
//  Created by Keith C on 3/25/22.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

final class PrelogViewModel: ObservableObject {
    
    @Published var tabSelection = 2
    
    @Published var isShowingLogin: Bool = false
    @Published var isShowingCreate: Bool = false
    @Published var isCreateSuccessful: Bool = false
    
    @Published var isOrderFetched: Bool = false
    @Published var isOrderNotFetched: Bool = false
    
    @Published var isBringerFetched: Bool = false
    @Published var isBringerNotFetched: Bool = false
    
    @Published var actualItemPrice: String = ""
    
    @Published var activeOrder: OrderModel = OrderModel()
    
    
    func checkIfActiveOrder(completion: @escaping (Bool) -> ()) {
        
        if Auth.auth().currentUser == nil {
            return
        }
        
        guard let userID = Auth.auth().currentUser?.uid else {
            isOrderNotFetched = true
            return
        }
        
        let ref = Database.database().reference()
        
        ref.child("users").child(userID).child("activeOrders").observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let activeUser = (snapshot.value as? [AnyHashable : Any]) else {
                self.isOrderNotFetched = true
                return
            }
            
            guard let activeOrderID = (activeUser["activeOrder"] as? String) else {
                self.isOrderNotFetched = true
                return
            }
            
            ref.child("activeOrders").child(activeOrderID).observeSingleEvent(of: .value, with: { (snapshotOrders) in
                guard let activeOrder = snapshotOrders.value as? NSDictionary else {
                    self.isOrderNotFetched = true
                    return
                }
                
                guard let activeOrderMap = Order.from(activeOrder) else {
                    self.isOrderNotFetched = true
                    return
                }
                
                let order = OrderModel(
                    id: activeOrderMap.id,
                    title: activeOrderMap.title,
                    description: activeOrderMap.description,
                    pickupBuy: activeOrderMap.pickupBuy,
                    maxPrice: activeOrderMap.maxPrice,
                    deliveryFee: activeOrderMap.deliveryFee,
                    dateSent: activeOrderMap.dateSent,
                    dateCompleted: activeOrderMap.dateCompleted,
                    status: activeOrderMap.status,
                    userID: activeOrderMap.userID,
                    location: activeOrderMap.location
                )
                
                DispatchQueue.main.async {
                    self.isOrderFetched = true
                    self.activeOrder = order
                    completion(self.isOrderFetched)
                }
            })
        })
    }
    
    func checkIfActiveBringer(completion: @escaping (Bool) -> ()) {
        
        if Auth.auth().currentUser == nil {
            return
        }
        
        guard let userID = Auth.auth().currentUser?.uid else {
            isBringerNotFetched = true
            return
        }
        
        let ref = Database.database().reference()
        
        ref.child("users").child(userID).child("activeBringers").observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let activeUser = (snapshot.value as? [AnyHashable : Any]) else {
                self.isBringerNotFetched = true
                return
            }
            
            guard let activeBringerID = (activeUser["activeBringer"] as? String) else {
                self.isBringerNotFetched = true
                return
            }
            
            ref.child("activeOrders").child(activeBringerID).observeSingleEvent(of: .value, with: { (snapshotOrders) in
                guard let activeOrder = snapshotOrders.value as? NSDictionary else {
                    self.isBringerNotFetched = true
                    return
                }
                
                guard let activeOrderMap = Order.from(activeOrder) else {
                    self.isBringerNotFetched = true
                    return
                }
                
                let order = OrderModel(
                    id: activeOrderMap.id,
                    title: activeOrderMap.title,
                    description: activeOrderMap.description,
                    pickupBuy: activeOrderMap.pickupBuy,
                    maxPrice: activeOrderMap.maxPrice,
                    deliveryFee: activeOrderMap.deliveryFee,
                    dateSent: activeOrderMap.dateSent,
                    dateCompleted: activeOrderMap.dateCompleted,
                    status: activeOrderMap.status,
                    userID: activeOrderMap.userID,
                    location: activeOrderMap.location
                )
                
                DispatchQueue.main.async {
                    self.isBringerFetched = true
                    self.activeOrder = order
                    self.tabSelection = 3
                    completion(self.isBringerFetched)
                }
            })
        })
    }
}

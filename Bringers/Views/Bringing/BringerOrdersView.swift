//
//  BringerOrdersView.swift
//  Bringers
//
//  Created by Keith C on 12/26/21.
//

import Foundation
import SwiftUI
import FirebaseDatabase
import Mapper

struct BringerOrdersView: View {
    
    @State private var isShowingOrder: Bool = false
    @State private var isShowingBringerConfirm: Bool = false
    @State private var confirmPressed: Bool = false
    @State private var isShowingBringerMap: Bool = false
    
    @State private var orderTitleState: String = ""
    
    @State private var orderButtons: [OrderListButton] = []
    
    @State private var orders: [OrderModel] = []
    
    
    private var rating: CGFloat = 3.8
    
    private var testDistances: [CGFloat] = [1.2, 2, 3.5, 7.6, 8.4, 10.6, 12, 13.2, 16, 18, 20, 22.1]
    private var testOrderNames: [String] = ["ass", "butt", "poo", "cock", "balls", "piss", "shit", "cunt", "fuck", "ween", "dick", "puss"]
    private var testShipping: [CGFloat] = [5, 10, 6, 14, 20, 9, 11, 14, 3, 6, 22, 1]
    
    init() {
        UITableView.appearance().separatorStyle = .none
        UITableViewCell.appearance().backgroundColor = .red
        UITableView.appearance().backgroundColor = .clear
    }
    
    
    var body: some View {
        
        // get all activeOrders from backend
        // get users coords
        // for each activeOrder, calc distance from user.coords and activeOrder.coords
        // sort by lowest distance
        // display in order
        
        
        // TODO: when backend is added: sort all orders in array by distance and use the properties like activeOrder.distance/activeOrder.shipping
        
        // requires sorted distances
        let lowestDistance: CGFloat = testDistances.first ?? 0
        let highestDistance: CGFloat = testDistances.last ?? 1
        let distanceGap: CGFloat = highestDistance - lowestDistance
        let alphaIncrementValDistance: CGFloat = 0.7/distanceGap
        
        // shipping can be unsorted
        let lowestShipping: CGFloat = testShipping.min() ?? 0
        let highestShipping: CGFloat = testShipping.max() ?? 1
        let shippingGap: CGFloat = highestShipping - lowestShipping
        let alphaIncrementValShipping: CGFloat = 0.7/shippingGap
        
        // TODO: calc distance and display
        List(orders) { order in
            OrderListButton(
                orderTitleState: $orderTitleState,
                isShowingOrder: $isShowingOrder,
                orderTitle: order.title,
                distance: 1,
                shippingCost: order.deliveryFee,
                distanceAlpha: ((1 - lowestDistance) * alphaIncrementValDistance) + 0.4,
                shippingAlpha: ((order.deliveryFee - lowestShipping) * alphaIncrementValShipping) + 0.4
            )
        }
        .frame(width: CustomDimensions.width + 20, height: CustomDimensions.height550)
        .onAppear {
            getActiveOrders { (orders) in
                self.orders = orders
            }
        }
        .background(Rectangle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: CustomDimensions.width, height: CustomDimensions.height550)
                        .cornerRadius(15))
        .tabItem {
            Image(systemName: "bag")
            Text("Bring")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
        
        .sheet(isPresented: $isShowingOrder, onDismiss: {
            if !isShowingOrder && confirmPressed {
                confirmPressed = false
                isShowingBringerConfirm.toggle()
            }
        }) {
            // TODO: replace hardcoded data with backend values from activeOrder
            BringerSelectedOrderView(
                isShowingOrder: $isShowingOrder,
                confirmPressed: $confirmPressed,
                pickupBuy: "Buy",
                maxItemPrice: 68,
                orderTitle: orderTitleState,
                description: "it sucks dont buy it",
                distance: 44,
                yourProfit: 2)
        }
        
        .fullScreenCover(isPresented: $isShowingBringerConfirm, onDismiss: {
            if !isShowingBringerConfirm {
                isShowingBringerMap.toggle()
            }
        }) {
            // TODO: replace hardcoded data with backend values from activeOrder
            BringerConfirmOrderBuyView(
                isShowingBringerConfirm: $isShowingBringerConfirm,
                maxItemPrice: 68,
                yourProfit: 2
            )
        }
        
        .fullScreenCover(isPresented: $isShowingBringerMap) {
            BringerOrderMapView(isShowingBringerMap: $isShowingBringerMap)
        }
    }
    
    func getActiveOrders(completion: @escaping ([OrderModel]) -> ()) {
        let ref = Database.database().reference()
        
        var allActiveOrders: [OrderModel] = []
        
        ref.child("activeOrders").observeSingleEvent(of: .value, with: { (snapshot) in
            let activeOrders = (snapshot.value as! NSDictionary).allValues
            for activeOrder in activeOrders {
                let activeOrderMap = Order.from(activeOrder as! NSDictionary)
                
                guard let activeOrderMap = activeOrderMap else {
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
                    userID: activeOrderMap.userID
                )
                
                allActiveOrders.append(order)
            }

            DispatchQueue.main.async {
                completion(allActiveOrders)
            }
        })
    }
}

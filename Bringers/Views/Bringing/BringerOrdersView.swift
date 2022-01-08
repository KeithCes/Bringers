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
    
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var isShowingOrder: Bool = false
    @State private var isShowingBringerConfirm: Bool = false
    @State private var confirmPressed: Bool = false
    @State private var isShowingBringerMap: Bool = false
    
    @State private var orderTitleState: String = ""
    
    @State private var orders: [OrderModel] = []
    
    private var rating: CGFloat = 3.8
    
    private var testDistances: [CGFloat] = [1.2, 2, 3.5, 7.6, 8.4, 10.6, 12, 13.2, 16, 18, 20, 22.1]
    private var testOrderNames: [String] = ["ass", "butt", "poo", "cock", "balls", "piss", "shit", "cunt", "fuck", "ween", "dick", "puss"]
    private var testShipping: [CGFloat] = [5, 10, 6, 14, 20, 9, 11, 14, 3, 6, 22, 1]
    
    var body: some View {
        
        // get all activeOrders from backend
        // get users coords
        // for each activeOrder, calc distance from user.coords and activeOrder.coords
        // sort by lowest distance
        // display in order
        
        
        // TODO: when backend is added: sort all orders in array by distance and use the properties like activeOrder.distance/activeOrder.shipping
        // TODO: when backend is added: pass entire order to button so that button can display the correct data AND can use the order data to display the order view
        VStack {
            ScrollView {
                VStack {
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
                    
                    ForEach(0..<testDistances.count) { i in
                        OrderListButton(
                            orderTitleState: $orderTitleState,
                            isShowingOrder: $isShowingOrder,
                            orderTitle: testOrderNames[i],
                            distance: testDistances[i],
                            shippingCost: testShipping[i],
                            distanceAlpha: ((testDistances[i] - lowestDistance) * alphaIncrementValDistance) + 0.4,
                            shippingAlpha: ((testShipping[i] - lowestShipping) * alphaIncrementValShipping) + 0.4
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: CustomDimensions.height500)
        }
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(.center)
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
        .onTapGesture {
            presentationMode.wrappedValue.dismiss()
        }
        
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
        .onAppear(perform: {
            getActiveOrders()
        })
    }
    
    func getActiveOrders() {
        let ref = Database.database().reference()
        
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
                
                self.orders.append(order)
            }
            
            print(orders)
        })
    }
}

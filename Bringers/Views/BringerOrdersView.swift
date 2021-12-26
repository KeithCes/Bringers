//
//  BringerOrdersView.swift
//  Bringers
//
//  Created by Keith C on 12/26/21.
//

import Foundation
import SwiftUI

struct BringerOrdersView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    private var rating: CGFloat = 3.8
    
    private var testDistances: [CGFloat] = [1.2, 3.5, 7.6, 8.4, 10.6, 16]
    private var testOrderNames: [String] = ["ass", "butt", "poo", "cock", "balls", "piss"]
    private var testShipping: [CGFloat] = [5, 10, 6, 14, 20, 9]
    
    var body: some View {
        
        // get all activeOrders from backend
        // get users coords
        // for each activeOrder, calc distance from user.coords and activeOrder.coords
        // sort by lowest distance
        // display in order
        
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
                    labelText: testOrderNames[i],
                    distance: testDistances[i],
                    shippingCost: testShipping[i],
                    distanceAlpha: ((testDistances[i] - lowestDistance) * alphaIncrementValDistance) + 0.4,
                    shippingAlpha: ((testShipping[i] - lowestShipping) * alphaIncrementValShipping) + 0.4
                )
            }
            
        }
        .foregroundColor(CustomColors.midGray)
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(.center)
        .background(Rectangle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 322, height: 500)
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
    }
}

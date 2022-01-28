//
//  PrelogView.swift
//  Bringers
//
//  Created by Keith C on 1/4/22.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct PrelogView: View {
    
    @State private var tabSelection = 2
    
    @State private var isShowingLogin: Bool = false
    @State private var isShowingCreate: Bool = false
    
    @State private var isOrderFetched: Bool = false
    @State private var isOrderNotFetched: Bool = false
    
    @State private var activeOrder: OrderModel = OrderModel()
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor(CustomColors.tabbarGray)
        UITabBar.appearance().alpha = 0.5
        UITabBar.appearance().unselectedItemTintColor = UIColor(CustomColors.darkGray).withAlphaComponent(0.5)
        
        UITextView.appearance().backgroundColor = .clear
        
        // uncomment to log user out
//         try! Auth.auth().signOut()
    }
    
    var body: some View {
        VStack {
            if Auth.auth().currentUser == nil {
                Button("LOGIN") {
                    isShowingLogin.toggle()
                }
                .padding(EdgeInsets(top: 35, leading: 20, bottom: 35, trailing: 20))
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(Color.white)
                .background(Rectangle()
                                .fill(CustomColors.blueGray.opacity(0.6))
                                .frame(width: CustomDimensions.width, height: 70)
                                .cornerRadius(15))
                
                .sheet(isPresented: $isShowingLogin) {
                    LoginView(isShowingLogin: $isShowingLogin)
                }
                
                Button("CREATE") {
                    isShowingCreate.toggle()
                }
                .padding(EdgeInsets(top: 35, leading: 20, bottom: 35, trailing: 20))
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(Color.white)
                .background(Rectangle()
                                .fill(CustomColors.blueGray.opacity(0.6))
                                .frame(width: CustomDimensions.width, height: 70)
                                .cornerRadius(15))
                
                .sheet(isPresented: $isShowingCreate) {
                    CreateAccountView(isShowingCreate: $isShowingCreate)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
        // i have no clue why this is needed; without it we don't transition from login/create -> tab view
        .onChange(of: isShowingLogin) { _ in
            checkIfActiveOrder { (isOrderFetched) in
                self.isOrderFetched = isOrderFetched
            }
        }
        // i have no clue why this is needed; without it we don't transition from login/create -> tab view
        .onChange(of: isShowingCreate) { _ in }
        // case active order
        .fullScreenCover(isPresented: $isOrderFetched) {
            TabView(selection: $tabSelection) {
                
                YourProfileView()
                    .tag(1)
                
                PlaceOrderView(givenOrder: $activeOrder)
                    .tag(2)
                    .background(CustomColors.seafoamGreen)
                
                BringerOrdersView()
                    .tag(3)
            }
            .accentColor(Color.black)
        }
        // case no active order or order not fetched
        .fullScreenCover(isPresented: $isOrderNotFetched) {
            TabView(selection: $tabSelection) {
                
                YourProfileView()
                    .tag(1)
                
                PlaceOrderView(givenOrder: $activeOrder)
                    .tag(2)
                    .background(CustomColors.seafoamGreen)
                
                BringerOrdersView()
                    .tag(3)
            }
            .accentColor(Color.black)
        }
        .onAppear {
            checkIfActiveOrder { (isOrderFetched) in
                self.isOrderFetched = isOrderFetched
            }
        }
    }
    
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
                isOrderNotFetched = true
                return
            }
            
            guard let activeOrderID = (activeUser["activeOrder"] as? String) else {
                isOrderNotFetched = true
                return
            }
            
            ref.child("activeOrders").child(activeOrderID).observeSingleEvent(of: .value, with: { (snapshotOrders) in
                guard let activeOrder = snapshotOrders.value as? NSDictionary else {
                    isOrderNotFetched = true
                    return
                }
                
                guard let activeOrderMap = Order.from(activeOrder) else {
                    isOrderNotFetched = true
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
                    isOrderFetched = true
                    self.activeOrder = order
                    completion(isOrderFetched)
                }
            })
        })
    }
}

//
//  PrelogView.swift
//  Bringers
//
//  Created by Keith C on 1/4/22.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct PrelogView: View {
    
    @State private var tabSelection = 2
    
    @State private var isShowingLogin: Bool = false
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor(CustomColors.tabbarGray)
        UITabBar.appearance().alpha = 0.5
        UITabBar.appearance().unselectedItemTintColor = UIColor(CustomColors.darkGray).withAlphaComponent(0.5)
        
        UITextView.appearance().backgroundColor = .clear
        
        try! Auth.auth().signOut()
    }
    
    var body: some View {
        if Auth.auth().currentUser != nil {
            TabView(selection: $tabSelection) {
                
                YourProfileView()
                    .tag(1)
                
                PlaceOrderView()
                    .tag(2)
                    .background(CustomColors.seafoamGreen)
                
                BringerOrdersView()
                    .tag(3)
                
            }
            .accentColor(Color.black)
        }
        else {
            LoginView(isShowingLogin: $isShowingLogin)
        }
        
        // i have no clue why this is needed; without it we don't transition from login -> tab view
        VStack{}.onChange(of: isShowingLogin) { _ in }
    }
}

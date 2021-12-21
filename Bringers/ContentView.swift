//
//  ContentView.swift
//  Bringers
//
//  Created by Keith C on 12/18/21.
//

import SwiftUI

struct ContentView: View {
    
    init() {
        UITabBar.appearance().barTintColor = UIColor(CustomColors.tabbarGray)
        UITabBar.appearance().alpha = 0.5
        UITabBar.appearance().unselectedItemTintColor = UIColor(CustomColors.darkGray).withAlphaComponent(0.5)
        
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        TabView {
            PlaceOrderView()
            
            Text("User Profile Tab")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(CustomColors.seafoamGreen)
                .ignoresSafeArea()
            
            Text("Bringers Tab")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .tabItem {
                    Image(systemName: "bag")
                    Text("Bring")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(CustomColors.seafoamGreen)
                .ignoresSafeArea()
        }
        .accentColor(Color.black)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

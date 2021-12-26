//
//  ContentView.swift
//  Bringers
//
//  Created by Keith C on 12/18/21.
//

import SwiftUI

struct ContentView: View {
    
    @State private var tabSelection = 2
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor(CustomColors.tabbarGray)
        UITabBar.appearance().alpha = 0.5
        UITabBar.appearance().unselectedItemTintColor = UIColor(CustomColors.darkGray).withAlphaComponent(0.5)
        
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        TabView(selection: $tabSelection) {
            
            YourProfileView()
                .tag(1)
            
            PlaceOrderView()
                .tag(2)
            
            Text("Bringers Tab")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .tabItem {
                    Image(systemName: "bag")
                    Text("Bring")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(CustomColors.seafoamGreen)
                .ignoresSafeArea()
                .tag(3)
        }
        .accentColor(Color.black)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

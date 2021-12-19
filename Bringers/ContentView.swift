//
//  ContentView.swift
//  Bringers
//
//  Created by Keith C on 12/18/21.
//

import SwiftUI

struct ContentView: View {
    
    @State private var name: String = ""
    
    init() {
        UITabBar.appearance().barTintColor = UIColor(CustomColors.tabbarGray)
        UITabBar.appearance().alpha = 0.5
        UITabBar.appearance().unselectedItemTintColor = UIColor(CustomColors.darkGray).withAlphaComponent(0.5)
    }
    
    var body: some View {
        TabView {
            VStack {
                Text("LOOKING FOR SOMETHING?")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                
                CustomTextbox(field: $name)
                    
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(CustomColors.seafoamGreen)
            .ignoresSafeArea()
            
            
            Text("Bookmark Tab")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .tabItem {
                    Image(systemName: "bookmark.circle.fill")
                    Text("Bookmark")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(CustomColors.seafoamGreen)
                .ignoresSafeArea()
            
            Text("Video Tab")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .tabItem {
                    Image(systemName: "video.circle.fill")
                    Text("Video")
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

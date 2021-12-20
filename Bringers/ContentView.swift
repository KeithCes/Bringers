//
//  ContentView.swift
//  Bringers
//
//  Created by Keith C on 12/18/21.
//

import SwiftUI

struct ContentView: View {
    
    @State private var pickupBuy: String = ""
    @State private var deliveryFee: String = ""
    @State private var maxItemPrice: String = ""
    @State private var itemName: String = ""
    @State private var description: String = ""
    
    @ObservedObject private var keyboard = KeyboardResponder()
    
    init() {
        UITabBar.appearance().barTintColor = UIColor(CustomColors.tabbarGray)
        UITabBar.appearance().alpha = 0.5
        UITabBar.appearance().unselectedItemTintColor = UIColor(CustomColors.darkGray).withAlphaComponent(0.5)
        
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        TabView {
            VStack {
                Text("LOOKING FOR SOMETHING?")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                
                CustomTextbox(field: $pickupBuy, placeholderText: "Pick-up or buy?")
                    .padding(EdgeInsets(top: 30, leading: 20, bottom: 15, trailing: 20))
                
                HStack {
                    CustomTextbox(field: $deliveryFee, placeholderText: "Delivery Fee", width: 153)
                    CustomTextbox(field: $maxItemPrice, placeholderText: "Max Item Price", width: 153)
                }
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 5, trailing: 20))
                
                CustomTextbox(field: $itemName, placeholderText: "Name of Item")
                    .padding(EdgeInsets(top: 30, leading: 20, bottom: 30, trailing: 20))
                
                TextEditor(text: $description)
                    .padding()
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(CustomColors.midGray)
                    .background(Rectangle()
                                    .fill(Color.white.opacity(0.5))
                                    .frame(width: 322, height: 153)
                                    .cornerRadius(15))
                    .frame(minWidth: 0, maxWidth: 300, minHeight: 0, maxHeight: 140)
                    .placeholderTopLeft(when: self.description.isEmpty) {
                        Text("Description").foregroundColor(CustomColors.midGray.opacity(0.6))
                        // makes placeholder even with text in box, not sure why we need this padding
                            .padding(.top, 24)
                            .padding(.leading, 20)
                    }
                    .onReceive(self.description.publisher.collect()) {
                        self.description = String($0.prefix(200))
                    }
            }
            .padding(.bottom, keyboard.currentHeight)
            .edgesIgnoringSafeArea(.bottom)
            .animation(.easeOut(duration: 0.16))
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(CustomColors.seafoamGreen)
            .ignoresSafeArea()
            .gesture(DragGesture().onChanged{_ in UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)})
            
            
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

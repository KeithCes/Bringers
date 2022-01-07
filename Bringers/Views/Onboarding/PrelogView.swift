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
    @State private var isShowingCreate: Bool = false
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor(CustomColors.tabbarGray)
        UITabBar.appearance().alpha = 0.5
        UITabBar.appearance().unselectedItemTintColor = UIColor(CustomColors.darkGray).withAlphaComponent(0.5)
        
        UITextView.appearance().backgroundColor = .clear
        
        // uncomment to log user out
//        try! Auth.auth().signOut()
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
            VStack {
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(CustomColors.seafoamGreen)
            .ignoresSafeArea()
            // i have no clue why this is needed; without it we don't transition from login/create -> tab view
            .onChange(of: isShowingLogin) { _ in }
            .onChange(of: isShowingCreate) { _ in }
        }
    }
}

//
//  PrelogView.swift
//  Bringers
//
//  Created by Keith C on 1/4/22.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth

struct PrelogView: View {
    
    @StateObject private var viewModel = PrelogViewModel()
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor(CustomColors.tabbarGray)
        UITabBar.appearance().alpha = 0.5
        UITabBar.appearance().unselectedItemTintColor = UIColor(CustomColors.darkGray).withAlphaComponent(0.5)
        
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        VStack {
            if Auth.auth().currentUser == nil {
                Button("LOGIN") {
                    viewModel.isShowingLogin.toggle()
                }
                .padding(EdgeInsets(top: 35, leading: 20, bottom: 35, trailing: 20))
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(Color.white)
                .background(Rectangle()
                                .fill(CustomColors.blueGray.opacity(0.6))
                                .frame(width: CustomDimensions.width, height: 70)
                                .cornerRadius(15))
                
                .sheet(isPresented: $viewModel.isShowingLogin) {
                    LoginView(isShowingLogin: $viewModel.isShowingLogin)
                }
                
                Button("CREATE") {
                    viewModel.isShowingCreate.toggle()
                }
                .padding(EdgeInsets(top: 35, leading: 20, bottom: 35, trailing: 20))
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(Color.white)
                .background(Rectangle()
                                .fill(CustomColors.blueGray.opacity(0.6))
                                .frame(width: CustomDimensions.width, height: 70)
                                .cornerRadius(15))
                
                .sheet(isPresented: $viewModel.isShowingCreate) {
                    CreateAccountView(isShowingCreate: $viewModel.isShowingCreate)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
        .onChange(of: viewModel.isShowingLogin) { _ in
            viewModel.checkIfActiveOrder { (isOrderFetched) in
                viewModel.isOrderFetched = isOrderFetched
            }
        }
        .onChange(of: viewModel.isShowingCreate) { _ in
            viewModel.checkIfActiveOrder { (isOrderFetched) in
                viewModel.isOrderFetched = isOrderFetched
            }
        }
        // case active order
        .fullScreenCover(isPresented: $viewModel.isOrderFetched) {
            TabView(selection: $viewModel.tabSelection) {
                
                YourProfileView()
                    .tag(1)
                
                PlaceOrderView(givenOrder: $viewModel.activeOrder)
                    .tag(2)
                    .background(CustomColors.seafoamGreen)
                
                BringerOrdersView(givenOrder: $viewModel.activeOrder)
                    .tag(3)
            }
            .accentColor(Color.black)
        }
        .onChange(of: viewModel.isOrderNotFetched) { _ in
            viewModel.checkIfActiveBringer { (isBringerFetched) in
                viewModel.isBringerFetched = isBringerFetched
            }
        }
        // case active bringer
        .fullScreenCover(isPresented: $viewModel.isBringerFetched) {
            TabView(selection: $viewModel.tabSelection) {
                
                YourProfileView()
                    .tag(1)
                
                PlaceOrderView(givenOrder: $viewModel.activeOrder)
                    .tag(2)
                    .background(CustomColors.seafoamGreen)
                
                BringerOrdersView(givenOrder: $viewModel.activeOrder)
                    .tag(3)
            }
            .accentColor(Color.black)
        }
        // case no active order no active bringer or order not fetched
        .fullScreenCover(isPresented: $viewModel.isBringerNotFetched) {
            TabView(selection: $viewModel.tabSelection) {
                
                YourProfileView()
                    .tag(1)
                
                PlaceOrderView(givenOrder: $viewModel.activeOrder)
                    .tag(2)
                    .background(CustomColors.seafoamGreen)
                
                BringerOrdersView(givenOrder: $viewModel.activeOrder)
                    .tag(3)
            }
            .accentColor(Color.black)
        }
        .onAppear {
            viewModel.checkIfActiveOrder { (isOrderFetched) in
                viewModel.isOrderFetched = isOrderFetched
            }
        }
    }
}

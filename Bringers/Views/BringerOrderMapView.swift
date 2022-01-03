//
//  BringerOrderMapView.swift
//  Bringers
//
//  Created by Keith C on 1/2/22.
//

import Foundation
import SwiftUI
import MapKit

struct BringerOrderMapView: View {
    
    @StateObject var viewModel = OrderComingMapViewModel()
    
    @Binding var isShowingBringerMap: Bool
    
    @State private var isShowingReceipt = false
    @State private var isShowingUserProfile = false
    @State private var isShowingInstructions = false
    
    var receiptImageName = "receipt"
    
    var body: some View {
        VStack {
            Text("DELIVER ITEM!")
                .font(.system(size: 48, weight: .bold, design: .rounded))
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
                .frame(width: 400, height: 300)
                .accentColor(CustomColors.seafoamGreen)
                .onAppear {
                    viewModel.checkIfLocationServicesEnabled()
                }
            HStack {
                
                Button(action: {
                    isShowingUserProfile.toggle()
                }) {
                    Image("scarra")
                        .resizable()
                        .frame(width: 74, height: 74)
                }
                .popover(isPresented: $isShowingUserProfile, content: {
                    UserProfileView()
                })
                
                VStack {
                    
                    Button {
                        // TODO: implement texting
                    } label: {
                        Image(systemName: "message.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(CustomColors.darkGray)
                    }
                    .frame(width: 49, height: 28)
                    .background(CustomColors.seafoamGreen)
                    .cornerRadius(15)
                    .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
                    
                    Button {
                        // TODO: implement calling
                    } label: {
                        Image(systemName: "phone.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(CustomColors.darkGray)
                    }
                    .frame(width: 49, height: 28)
                    .background(CustomColors.seafoamGreen)
                    .cornerRadius(15)
                    .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
                }
                
                Button {
                    isShowingInstructions.toggle()
                } label: {
                    Image(systemName: "note.text")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(CustomColors.darkGray)
                }
                .popover(isPresented: $isShowingInstructions, content: {
                    // TODO: replace dummy values
                    BringerInstructionsView(
                        pickupBuy: "Buy",
                        maxItemPrice: 66,
                        orderTitle: "WOOOOOO",
                        description: "Look here, look listen",
                        distance: 5,
                        yourProfit: 33
                    )
                })
                .frame(width: 50, height: 50)
                .background(Color.white.opacity(0.5))
                .cornerRadius(15)
                .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
                
                if receiptImageName != "" {
                    Button(action: {
                        isShowingReceipt.toggle()
                    }) {
                        Image(receiptImageName)
                            .resizable()
                            .frame(width: 74, height: 74)
                    }
                    .popover(isPresented: $isShowingReceipt, content: {
                        ReceiptView()
                    })
                }
            }
            .background(CustomColors.blueGray.opacity(0.6))
            .cornerRadius(15)
            .frame(width: 322, height: 108, alignment: .center)
            
            Button {
                // TODO: confirmation screen/backend call to cancel order
                isShowingBringerMap = false
            } label: {
                Image(systemName: "x.circle")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(CustomColors.darkGray)
            }
            .frame(width: 49, height: 28)
            .background(CustomColors.lightRed)
            .cornerRadius(15)
        }
        .edgesIgnoringSafeArea(.bottom)
        .tabItem {
            Image(systemName: "cart")
            Text("Order")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
    }
}
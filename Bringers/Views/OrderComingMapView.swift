//
//  OrderComingMapView.swift
//  Bringers
//
//  Created by Keith C on 12/23/21.
//

import Foundation
import SwiftUI
import MapKit

struct OrderComingMapView: View {
    
    @StateObject private var viewModel = OrderComingMapViewModel()
    
    @Binding var isShowingOrderComing: Bool
    
    @State private var isShowingReceipt = false
    @State private var isShowingUserProfile = false
    
    var receiptImageName = "receipt"
    
    var body: some View {
        VStack {
            CustomTitleText(labelText: "[SCARRA] IS COMING WITH YOUR ORDER!")

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
                .sheet(isPresented: $isShowingUserProfile, content: {
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
                
                if receiptImageName != "" {
                    Button(action: {
                        isShowingReceipt.toggle()
                    }) {
                        Image(receiptImageName)
                            .resizable()
                            .frame(width: 74, height: 74)
                    }
                    .sheet(isPresented: $isShowingReceipt, content: {
                        ReceiptView()
                    })
                }
            }
            .background(CustomColors.blueGray.opacity(0.6))
            .cornerRadius(15)
            .frame(width: CustomDimensions.width, height: 108, alignment: .center)
            
            Button {
                // TODO: confirmation screen/backend call to cancel order
                isShowingOrderComing = false
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

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
    
    @StateObject var viewModel = OrderComingMapViewModel()
    
    @State private var isShowingReceipt = false
    
    var body: some View {
        VStack {
            Text("[SCARRA] IS COMING WITH YOUR ORDER!")
                .font(.system(size: 48, weight: .bold, design: .rounded))
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
                .frame(width: 400, height: 300)
                .accentColor(CustomColors.seafoamGreen)
                .onAppear {
                    viewModel.checkIfLocationServicesEnabled()
                }
            HStack {
                Button {
                    print("user")
                } label: {
                    Image("scarra")
                        .resizable()
                        .frame(width: 74, height: 74)
                }
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
                }
                Button(action: {
                    isShowingReceipt.toggle()

                }) {
                    Image("receipt")
                        .resizable()
                        .frame(width: 74, height: 74)
                }
                .popover(isPresented: $isShowingReceipt, content: {
                    ReceiptView()
                })
            }
            .background(CustomColors.blueGray.opacity(0.6))
            .cornerRadius(15)
            .frame(width: 322, height: 108, alignment: .center)
        }
        .edgesIgnoringSafeArea(.bottom)
        .animation(.easeOut(duration: 0.16))
        .tabItem {
            Image(systemName: "cart")
            Text("Order")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
    }
}

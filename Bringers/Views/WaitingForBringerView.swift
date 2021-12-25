//
//  WaitingForBringerView.swift
//  Bringers
//
//  Created by Keith C on 12/24/21.
//

import Foundation
import SwiftUI

struct WaitingForBringerView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isShowingOrderComing = false
    
    @State private var animationAmount: CGFloat = 1
    
    var body: some View {
        VStack {
            Text("WAITING FOR A BRINGER TO ACCEPT YOUR ORDER...")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 15, trailing: 20))
                .fixedSize(horizontal: false, vertical: true)
            
            Rectangle()
                .frame(width: 200, height: 200)
                .background(CustomColors.midGray.opacity(0.5))
                .foregroundColor(CustomColors.midGray.opacity(0.5))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(CustomColors.midGray.opacity(0.5))
                        .scaleEffect(animationAmount)
                        .opacity(Double(2 - animationAmount))
                        .animation(
                            .easeInOut(duration: 2)
                                .repeatForever(autoreverses: false),
                            value: animationAmount
                        )
                )
                .overlay(
                    Image(systemName: "person")
                        .frame(width: 200, height: 200)
                        .scaleEffect(animationAmount + 2)
                        .opacity(Double(2 - animationAmount))
                        .animation(
                            .easeInOut(duration: 2)
                                .repeatForever(autoreverses: false),
                            value: animationAmount
                        )
                )
                .onAppear {
                    animationAmount = 2
                }
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 40, trailing: 20))
            
            Button {
                // TODO: confirmation screen/backend call to cancel order
                UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
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
        // TODO: remove later, replace with logic for bringer picking up order (backend)
        .onTapGesture {
            isShowingOrderComing.toggle()
        }
        .fullScreenCover(isPresented: $isShowingOrderComing, content: OrderComingMapView.init)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
    }
}

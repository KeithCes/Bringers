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
    
    var body: some View {
        VStack {
            Text("WAITING FOR A BRINGER TO ACCEPT YOUR ORDER...")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 15, trailing: 20))
                .fixedSize(horizontal: false, vertical: true)
            
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

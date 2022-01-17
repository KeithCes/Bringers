//
//  ReceiptView.swift
//  Bringers
//
//  Created by Keith C on 12/24/21.
//

import Foundation
import SwiftUI

struct ReceiptView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @Binding var receiptImage: Image
    
    var body: some View {
        VStack {
            self.receiptImage
                .resizable()
                .frame(width: 375, height: 812)
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
    }
}

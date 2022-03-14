//
//  CustomTextboxCurrencyDecimal.swift
//  Bringers
//
//  Created by Keith C on 3/11/22.
//

import Foundation
import SwiftUI

struct CustomTextboxCurrencyDecimal: View {
    
    @Binding var field: String
    
    var placeholderText: String
    
    init(field: Binding<String>, placeholderText: String) {
        self._field = field
        self.placeholderText = placeholderText
    }
    
    var body: some View {
        let text = Binding<String>(
            get: {
                return field
            },
            set: { text in
                field = text.currencyInputFormatting()
            }
        )
        
        TextField("", text: text)
            .keyboardType(.numberPad)
            .font(.system(size: 18, weight: .regular, design: .rounded))
            .multilineTextAlignment(.center)
            .placeholder(when: self.field == "") {
                Text(self.placeholderText).foregroundColor(CustomColors.midGray.opacity(0.5))
            }
            .foregroundColor(CustomColors.midGray)
            .multilineTextAlignment(.center)
            .background(Rectangle()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: (CustomDimensions.width - 16) / 2, height: 50)
                            .cornerRadius(15))
            .fixedSize(horizontal: false, vertical: true)
            .frame(minWidth: 0, maxWidth: ((CustomDimensions.width - 16) / 2) - 20, minHeight: 0, maxHeight: 40)
    }
}

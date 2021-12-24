//
//  CustomTextboxCurrency.swift
//  Bringers
//
//  Created by Keith C on 12/23/21.
//

import Foundation
import SwiftUI

struct CustomTextboxCurrency: View {
    
    // https://github.com/onmyway133/blog/issues/844
    
    @Binding var field: CGFloat
    
    var placeholderText: String
    
    init(field: Binding<CGFloat>, placeholderText: String) {
        self._field = field
        self.placeholderText = placeholderText
    }
    
    var body: some View {
        let text = Binding<String>(
            get: {
                if field > 999 {
                    field = 999
                }
                return field > 0 ? "$" + String(format: "%.0f", field) : ""
            },
            set: { text in
                let text = text.replacingOccurrences(of: "$", with: "")
                if Int(text) == 0 {
                    field = 10
                }
                else {
                    field = CGFloat(Int(text) ?? 0)
                }
            }
        )

        TextField("", text: text)
            .keyboardType(.numberPad)
            .font(.system(size: 18, weight: .regular, design: .rounded))
            .multilineTextAlignment(.center)
            .placeholder(when: self.field == 0) {
                Text(self.placeholderText).foregroundColor(CustomColors.midGray.opacity(0.5))
            }
            .foregroundColor(CustomColors.midGray)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
            .background(Rectangle()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: 153, height: 50)
                            .cornerRadius(15))
    }
}

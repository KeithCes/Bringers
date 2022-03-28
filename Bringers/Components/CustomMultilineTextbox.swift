//
//  CustomMultilineTextbox.swift
//  Bringers
//
//  Created by Keith C on 3/25/22.
//

import Foundation
import SwiftUI
import Combine

struct CustomMultilineTextbox: View {

    @Binding var field: String
    private var placeholderText: String
    private var charLimit: Int

    init(field: Binding<String>, placeholderText: String, charLimit: Int = 200) {
        UITextView.appearance().textContainerInset = UIEdgeInsets(top: 24, left: 17, bottom: 0, right: 0)
        
        self._field = field
        self.placeholderText = placeholderText
        self.charLimit = charLimit
    }

    var body: some View {
        TextEditor(text: self.$field)
            .placeholderTopLeft(when: self.field.isEmpty) {
                Text(self.placeholderText).foregroundColor(CustomColors.midGray.opacity(0.5))
                // makes placeholder even with text in box, not sure why we need this padding
                    .padding(.top, 24)
                    .padding(.leading, 20)
            }
            .font(.system(size: 18, weight: .regular, design: .rounded))
            .foregroundColor(CustomColors.midGray)
            .background(Rectangle()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: CustomDimensions.width, height: 153)
                            .cornerRadius(15))
            .frame(minWidth: 0, maxWidth: 300, minHeight: 0, maxHeight: 140)
            .onReceive(Just(self.field)) { _ in limitText(self.charLimit) }
    }
    
    func limitText(_ upper: Int) {
        if self.field.count > upper {
            self.field = String(self.field.prefix(upper))
        }
    }
}

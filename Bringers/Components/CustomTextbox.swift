//
//  CustomTextbox.swift
//  Bringers
//
//  Created by Keith C on 12/19/21.
//

import Foundation
import SwiftUI
import Combine

struct CustomTextbox: View {

    @Binding var field: String
    var placeholderText: String
    var height: CGFloat
    var width: CGFloat
    var charLimit: Int
    var onEditingChanged: (Bool) -> Void

    init(field: Binding<String>, placeholderText: String, height: CGFloat = 50, width: CGFloat = CustomDimensions.width, charLimit: Int = 20, onEditingChanged: @escaping (Bool) -> Void = {_ in }) {
        self._field = field
        self.placeholderText = placeholderText
        self.height = height
        self.width = width
        self.charLimit = charLimit
        self.onEditingChanged = onEditingChanged
    }

    var body: some View {
        TextField(self.field, text: self.$field, onEditingChanged: self.onEditingChanged)
            .font(.system(size: 18, weight: .regular, design: .rounded))
            .placeholder(when: self.field.isEmpty) {
                Text(self.placeholderText).foregroundColor(CustomColors.midGray.opacity(0.5))
            }
            .foregroundColor(CustomColors.midGray)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
            .background(Rectangle()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: self.width, height: self.height)
                            .cornerRadius(15))
            .onReceive(Just(self.field)) { _ in limitText(self.charLimit) }
    }
    
    func limitText(_ upper: Int) {
        if self.field.count > upper {
            self.field = String(self.field.prefix(upper))
        }
    }
}

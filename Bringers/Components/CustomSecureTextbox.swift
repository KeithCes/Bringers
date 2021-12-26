//
//  CustomSecureTextbox.swift
//  Bringers
//
//  Created by Keith C on 12/19/21.
//

import Foundation
import SwiftUI

struct CustomSecureTextbox: View {

    @Binding var field: String
    var placeholderText: String
    var height: CGFloat
    var width: CGFloat
    var charLimit: Int

    init(field: Binding<String>, placeholderText: String, height: CGFloat = 50, width: CGFloat = 322, charLimit: Int = 20) {
        self._field = field
        self.placeholderText = placeholderText
        self.height = height
        self.width = width
        self.charLimit = charLimit
    }

    var body: some View {
        SecureField(self.field, text: self.$field)
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
            .onReceive(self.field.publisher.collect()) {
                self.field = String($0.prefix(self.charLimit))
            }
    }
}

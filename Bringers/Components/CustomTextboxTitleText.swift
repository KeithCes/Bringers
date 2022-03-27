//
//  CustomTextboxTitleText.swift
//  Bringers
//
//  Created by Keith C on 12/26/21.
//

import Foundation
import SwiftUI
import Combine

struct CustomTextboxTitleText: View {

    @Binding var field: String
    private var placeholderText: String
    private var height: CGFloat
    private var width: CGFloat
    private var charLimit: Int
    private var titleText: String

    init(field: Binding<String>, placeholderText: String, height: CGFloat = 50, width: CGFloat = CustomDimensions.width, charLimit: Int = 20, titleText: String) {
        self._field = field
        self.placeholderText = placeholderText
        self.height = height
        self.width = width
        self.charLimit = charLimit
        self.titleText = titleText
    }

    var body: some View {
        TextField(self.field, text: self.$field)
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
                            .cornerRadius(15)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0)))
            .onReceive(Just(self.field)) { _ in limitText(self.charLimit) }
            .overlay(
                Text(self.titleText)
                    .foregroundColor(CustomColors.midGray.opacity(0.5))
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 35, trailing: 20))
            )
    }
    
    func limitText(_ upper: Int) {
        if self.field.count > upper {
            self.field = String(self.field.prefix(upper))
        }
    }
}

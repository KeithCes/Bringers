//
//  CustomTextbox.swift
//  Bringers
//
//  Created by Keith C on 12/19/21.
//

import Foundation
import SwiftUI

struct CustomTextbox: View {

    @Binding var field: String

    init(field: Binding<String>) {
        self._field = field
    }

    var body: some View {
        TextField(field, text: $field)
            .font(.system(size: 18, weight: .regular, design: .rounded))
            .foregroundColor(CustomColors.midGray)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
            .background(Rectangle()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: 322, height: 50)
                            .cornerRadius(15))
            .placeholder(when: field.isEmpty) {
                Text("Pick-up or buy?").foregroundColor(CustomColors.midGray.opacity(0.6))
            }
    }
}

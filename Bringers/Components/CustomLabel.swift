//
//  CustomLabel.swift
//  Bringers
//
//  Created by Keith C on 12/20/21.
//

import Foundation
import SwiftUI

struct CustomLabel: View {
    
    var labelText: String
    var height: CGFloat
    var width: CGFloat
    var isBold: Bool
    var fontSize: CGFloat
    var hasBackground: Bool
    
    init(labelText: String, height: CGFloat = 50, width: CGFloat = CustomDimensions.width, isBold: Bool = false, fontSize: CGFloat = 18, hasBackground: Bool = true) {
        self.labelText = labelText
        self.height = height
        self.width = width
        self.isBold = isBold
        self.fontSize = fontSize
        self.hasBackground = hasBackground
    }
    
    var body: some View {
        Text(self.labelText)
            .font(.system(size: self.fontSize, weight: self.isBold ? .bold : .regular, design: .rounded))
            .foregroundColor(CustomColors.midGray)
            .background(Rectangle()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: self.width, height: self.height)
                            .cornerRadius(15))
            .fixedSize(horizontal: false, vertical: true)
            .frame(minWidth: 0, maxWidth: self.width-20, minHeight: 0, maxHeight: self.height-10)
    }
}

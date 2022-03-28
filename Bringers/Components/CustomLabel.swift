//
//  CustomLabel.swift
//  Bringers
//
//  Created by Keith C on 12/20/21.
//

import Foundation
import SwiftUI

struct CustomLabel: View {
    
    private var labelText: String
    private var height: CGFloat
    private var width: CGFloat
    private var isBold: Bool
    private var fontSize: CGFloat
    private var hasBackground: Bool
    private var backgroundColor: Color
    
    init(labelText: String, height: CGFloat = 50, width: CGFloat = CustomDimensions.width, isBold: Bool = false, fontSize: CGFloat = 18, hasBackground: Bool = true, backgroundColor: Color = Color.white) {
        self.labelText = labelText
        self.height = height
        self.width = width
        self.isBold = isBold
        self.fontSize = fontSize
        self.hasBackground = hasBackground
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        Text(self.labelText)
            .font(.system(size: self.fontSize, weight: self.isBold ? .bold : .regular, design: .rounded))
            .foregroundColor(CustomColors.midGray)
            .background(Rectangle()
                            .fill(self.backgroundColor.opacity(0.5))
                            .frame(width: self.width, height: self.height)
                            .cornerRadius(15))
            .fixedSize(horizontal: false, vertical: true)
            .frame(minWidth: 0, maxWidth: self.width-20, minHeight: 0, maxHeight: self.height-10)
    }
}

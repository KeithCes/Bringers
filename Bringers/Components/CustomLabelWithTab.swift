//
//  CustomLabelWithTab.swift
//  Bringers
//
//  Created by Keith C on 12/26/21.
//

import Foundation
import SwiftUI

struct CustomLabelWithTab: View {
    
    var labelText: String
    var height: CGFloat
    var width: CGFloat
    var isBold: Bool
    var fontSize: CGFloat
    var tabText: String
    
    init(labelText: String, tabText: String, height: CGFloat = 50, width: CGFloat = CustomDimensions.width - 20, isBold: Bool = false, fontSize: CGFloat = 18, hasBackground: Bool = true) {
        self.labelText = labelText
        self.height = height
        self.width = width
        self.isBold = isBold
        self.fontSize = fontSize
        self.tabText = tabText
    }
    
    var body: some View {
        ZStack {
            Text(self.labelText)
                .font(.system(size: self.fontSize, weight: self.isBold ? .bold : .regular, design: .rounded))
                .foregroundColor(CustomColors.midGray)
                .fixedSize(horizontal: false, vertical: true)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                .frame(width: self.width, height: self.height, alignment: .leading)
                .background(Rectangle()
                                .fill(Color.white.opacity(0.5))
                                .cornerRadius(15))
            
            Rectangle()
                .foregroundColor(CustomColors.veryDarkGray.opacity(0.5))
                .frame(width: (CustomDimensions.width - 20) * 0.199, height: self.height)
                .overlay(
                    Text(self.tabText)
                        .font(.system(size: 18, weight: self.isBold ? .bold : .regular, design: .rounded))
                        .foregroundColor(CustomColors.seafoamGreen)
                )
                .padding(EdgeInsets(top: 0, leading: self.width * 0.798, bottom: 0, trailing: 0))
                .cornerRadius(15)
        }

    }
}

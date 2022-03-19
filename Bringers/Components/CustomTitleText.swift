//
//  CustomTitleText.swift
//  Bringers
//
//  Created by Keith C on 1/3/22.
//

import Foundation
import SwiftUI

struct CustomTitleText: View {
    
    private var labelText: String
    private var fontSize: CGFloat
    
    init(labelText: String, fontSize: CGFloat = 48) {
        self.labelText = labelText
        self.fontSize = fontSize
    }
    
    var body: some View {
        Text(self.labelText)
            .font(.system(size: self.fontSize, weight: .bold, design: .rounded))
            .foregroundColor(Color.white)
            .fixedSize(horizontal: false, vertical: true)
    }
}

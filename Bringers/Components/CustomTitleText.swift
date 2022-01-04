//
//  CustomTitleText.swift
//  Bringers
//
//  Created by Keith C on 1/3/22.
//

import Foundation
import SwiftUI

struct CustomTitleText: View {
    
    var labelText: String
    
    init(labelText: String) {
        self.labelText = labelText
    }
    
    var body: some View {
        Text(self.labelText)
            .font(.system(size: 48, weight: .bold, design: .rounded))
            .foregroundColor(Color.white)
    }
}

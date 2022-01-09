//
//  View+isHidden.swift
//  Bringers
//
//  Created by Keith C on 1/8/22.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder func isHidden(_ isHidden: Bool) -> some View {
        if isHidden {
            self.hidden()
        } else {
            self
        }
    }
}

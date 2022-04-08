//
//  View+hideKeyboard.swift
//  Bringers
//
//  Created by Keith C on 4/8/22.
//

import Foundation
import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

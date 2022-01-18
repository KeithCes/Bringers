//
//  CustomDimensions.swift
//  Bringers
//
//  Created by Keith C on 1/3/22.
//

import Foundation
import SwiftUI

struct CustomDimensions {
    // based off 375 x 812
    static let width = UIScreen.main.bounds.size.width * (322 / 375)
    static let height = UIScreen.main.bounds.size.height
    static let height300 = UIScreen.main.bounds.size.height * (300 / 812)
    static let height400 = UIScreen.main.bounds.size.height * (400 / 812)
    static let height500 = UIScreen.main.bounds.size.height * (500 / 812)
    static let height550 = UIScreen.main.bounds.size.height * (550 / 812)
    static let height600 = UIScreen.main.bounds.size.height * (600 / 812)
    static let height650 = UIScreen.main.bounds.size.height * (650 / 812)
}

//
//  CGFloat+Covertible.swift
//  Bringers
//
//  Created by Keith C on 1/8/22.
//

import Foundation
import SwiftUI
import Mapper

extension CGFloat: Convertible {
    public static func fromMap(_ value: Any) throws -> CGFloat {
        guard let cgVal = value as? CGFloat else {
            throw MapperError.convertibleError(value: value, type: CGFloat.self)
        }
        return cgVal
    }
}

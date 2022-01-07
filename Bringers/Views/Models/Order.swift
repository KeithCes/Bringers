//
//  Order.swift
//  Bringers
//
//  Created by Keith C on 1/7/22.
//

import Foundation
import Mapper

struct Order: Mappable {
    let description: String
    
    init(map: Mapper) throws {
        try description = map.from("description")
    }
}

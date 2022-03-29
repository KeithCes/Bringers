//
//  AnnotatedItem.swift
//  Bringers
//
//  Created by Keith C on 3/29/22.
//

import Foundation
import MapKit

struct AnnotatedItem: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
}

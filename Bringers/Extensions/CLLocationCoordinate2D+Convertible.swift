//
//  CLLocationCoordinate2D+Convertible.swift
//  Bringers
//
//  Created by Keith C on 1/9/22.
//

import Foundation
import MapKit
import Mapper

extension CLLocationCoordinate2D: Convertible {
  public static func fromMap(_ value: Any) throws -> CLLocationCoordinate2D {
    guard let location = value as? NSArray,
      let latitude = location[0] as? Double,
      let longitude = location[1] as? Double else
      {
         throw MapperError.convertibleError(value: value, type: [String: Double].self)
      }

      return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
}

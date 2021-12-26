//
//  RatingView.swift
//  Bringers
//
//  Created by Keith C on 12/24/21.
//

import Foundation
import SwiftUI

struct RatingView: View {
    
    // https://stackoverflow.com/questions/64379079/how-to-present-accurate-star-rating-using-swiftui
    
    var rating: CGFloat
    var maxRating: Int

    var body: some View {
        let stars = HStack(spacing: 0) {
            ForEach(0..<maxRating) { _ in
                Image(systemName: "star.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }

        stars.overlay(
            GeometryReader { g in
                let width = rating / CGFloat(maxRating) * g.size.width
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: width)
                        .foregroundColor(.yellow)
                }
            }
            .mask(stars)
        )
        .foregroundColor(.gray)
    }
}



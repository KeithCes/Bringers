//
//  UserProfileView.swift
//  Bringers
//
//  Created by Keith C on 12/24/21.
//

import Foundation
import SwiftUI

struct UserProfileView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @Binding var image: Image
    private var firstName: String = ""
    private var lastName: String = ""
    private var rating: CGFloat = 0
    
    init(image: Binding<Image>, firstName: String, lastName: String, rating: CGFloat) {
        self._image = image
        self.firstName = firstName
        self.lastName = lastName
        self.rating = rating
    }
    
    var body: some View {
        VStack {
            self.image
                .resizable()
                .frame(width: 186, height: 186)
                .cornerRadius(15)
            Text(self.firstName + " " + self.lastName)
                .font(.system(size: 24, weight: .regular, design: .rounded))
                .foregroundColor(CustomColors.midGray)
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 10, trailing: 0))
            Text("RATING: " + "\((self.rating * 10).rounded(.toNearestOrAwayFromZero) / 10)" + "/5")
                .font(.system(size: 24, weight: .regular, design: .rounded))
                .foregroundColor(CustomColors.midGray)
                .padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 0))
            RatingView(rating: (self.rating * 10).rounded(.toNearestOrAwayFromZero) / 10, maxRating: 5)
                .frame(width: 112, height: 16)
        }
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(.center)
        .background(Rectangle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: CustomDimensions.width, height: CustomDimensions.height500)
                        .cornerRadius(15))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
        .onTapGesture {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

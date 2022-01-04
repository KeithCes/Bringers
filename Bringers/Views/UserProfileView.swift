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
    
    private var rating: CGFloat = 3.8
    
    var body: some View {
        VStack {
            Image("scarra")
                .resizable()
                .frame(width: 186, height: 186)
                .cornerRadius(15)
            Text("FIRSTNAME" + " " + "LASTNAME")
                .font(.system(size: 24, weight: .regular, design: .rounded))
                .foregroundColor(CustomColors.midGray)
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 10, trailing: 0))
            Text("RATING: " + "\(rating)" + "/5")
                .font(.system(size: 24, weight: .regular, design: .rounded))
                .foregroundColor(CustomColors.midGray)
                .padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 0))
            RatingView(rating: rating, maxRating: 5)
                .frame(width: 112, height: 16)
        }
        .foregroundColor(CustomColors.midGray)
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

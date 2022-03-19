//
//  OrderCompleteView.swift
//  Bringers
//
//  Created by Keith C on 2/21/22.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct OrderCompleteView: View {
    
    @Binding var isShowingOrderCompleted: Bool
    private var orderID: String
    private var bringerRating: CGFloat
    private var bringerTotalRatings: CGFloat
    
    init(isShowingOrderCompleted: Binding<Bool>, orderID: String, bringerRating: CGFloat, bringerTotalRatings: CGFloat) {
        self._isShowingOrderCompleted = isShowingOrderCompleted
        self.orderID = orderID
        self.bringerRating = bringerRating
        self.bringerTotalRatings = bringerTotalRatings
    }
    
    var body: some View {
        VStack {
            CustomTitleText(labelText: "YOUR ORDER HAS BEEN DELIVERED!")
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 15, trailing: 20))
            
            CustomTitleText(labelText: "PLEASE RATE YOUR BRINGER:", fontSize: 24)
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
            
            HStack(spacing: 0) {
                ForEach(0..<5) { i in
                    Image(systemName: "star.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .onTapGesture {
                            sendRating(newRating: CGFloat(i + 1))
                        }
                        .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                }
            }
            .padding(EdgeInsets(top: 5, leading: 60, bottom: 35, trailing: 60))
            
            Button("DISMISS") {
                self.isShowingOrderCompleted.toggle()
            }
            .font(.system(size: 30, weight: .bold, design: .rounded))
            .foregroundColor(Color.white)
            .background(Rectangle()
                            .fill(CustomColors.blueGray.opacity(0.6))
                            .frame(width: CustomDimensions.width, height: 70)
                            .cornerRadius(15))
            .padding(EdgeInsets(top: 20, leading: 20, bottom: 10, trailing: 20))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
    }
    
    func sendRating(newRating: CGFloat) {
        
        let userID = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        
        ref.child("users").child(userID).child("pastOrders").child(orderID).child("bringerID").observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let bringerID = snapshot.value as? String else {
                return
            }
            
            let calcRating = ((bringerRating * bringerTotalRatings) + newRating) / (bringerTotalRatings + 1)
            
            ref.child("users").child(bringerID).child("userInfo").updateChildValues(["rating" : calcRating])
            ref.child("users").child(bringerID).child("userInfo").updateChildValues(["totalRatings" : bringerTotalRatings + 1])
            
            self.isShowingOrderCompleted.toggle()
        })
    }
}

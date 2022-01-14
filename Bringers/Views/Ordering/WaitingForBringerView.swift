//
//  WaitingForBringerView.swift
//  Bringers
//
//  Created by Keith C on 12/24/21.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import Mapper

struct WaitingForBringerView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject private var viewModel = LocationViewModel()
    
    @Binding var isShowingWaitingForBringer: Bool
    @Binding var isOrderCancelledWaiting: Bool
    
    @Binding var order: OrderModel
    
    @State private var animationAmount: CGFloat = 1
    
    @State private var timer: Timer?
    
    var body: some View {
        VStack {
            CustomTitleText(labelText: "WAITING FOR A BRINGER TO ACCEPT YOUR ORDER...")
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 15, trailing: 20))
            
            Rectangle()
                .frame(width: 200, height: 200)
                .background(CustomColors.midGray.opacity(0.5))
                .foregroundColor(CustomColors.midGray.opacity(0.5))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(CustomColors.midGray.opacity(0.5))
                        .scaleEffect(animationAmount)
                        .opacity(Double(2 - animationAmount))
                        .animation(
                            .easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: false),
                            value: animationAmount
                        )
                )
                .overlay(
                    Image(systemName: "person")
                        .frame(width: 200, height: 200)
                        .scaleEffect(animationAmount + 2)
                        .opacity(Double(2 - animationAmount))
                        .animation(
                            .easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: false),
                            value: animationAmount
                        )
                )
                .onAppear {
                    animationAmount = 2
                }
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 40, trailing: 20))
            
            Button {
                deactivateOrder()
            } label: {
                Image(systemName: "x.circle")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(CustomColors.darkGray)
            }
            .frame(width: 49, height: 28)
            .background(CustomColors.lightRed)
            .cornerRadius(15)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
        .onAppear {
            viewModel.setViewParentType(type: MapViewParent.order)
            viewModel.checkIfLocationServicesEnabled()
            viewModel.setOrderID(id: order.id)
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                sendUserLocation()
                checkIfOrderInProgress()
            }
        }
    }
    
    func deactivateOrder() {
        let userID = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        
        // moves order from active to past, closes view
        ref.child("activeOrders").child($order.wrappedValue.id).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // adds to past
            ref.child("users").child(userID).child("pastOrders").child($order.wrappedValue.id).updateChildValues(snapshot.value as! [AnyHashable : Any])
            
            // sets date completed
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/YYYY"
            let currentDateString = dateFormatter.string(from: Date())
            
            ref.child("users").child(userID).child("pastOrders").child($order.wrappedValue.id).updateChildValues(["dateCompleted" : currentDateString])
            
            // sets order cancelled
            ref.child("users").child(userID).child("pastOrders").child($order.wrappedValue.id).updateChildValues(["status" : "cancelled"])
            
            
            // removes from active
            ref.child("activeOrders").child($order.wrappedValue.id).removeValue()
            ref.child("users").child(userID).child("activeOrders").removeValue()
            
            self.timer?.invalidate()
            isShowingWaitingForBringer = false
            isOrderCancelledWaiting = true
        })
    }
    
    func sendUserLocation() {
        let ref = Database.database().reference()
        guard let locationManager = viewModel.getLocation() else {
            return
        }
        ref.child("activeOrders").child(self.order.id).updateChildValues(["location":[locationManager.location?.coordinate.latitude, locationManager.location?.coordinate.longitude]])
    }
    
    func checkIfOrderInProgress() {
        let ref = Database.database().reference()
        ref.child("activeOrders").child($order.wrappedValue.id).observeSingleEvent(of: .value, with: { (snapshot) in
            let currentStatus = (snapshot.value as! NSDictionary)["status"]
            
            guard let currentStatus = currentStatus else {
                self.timer?.invalidate()
                isShowingWaitingForBringer = false
                return
            }
            
            if currentStatus as! String == "inprogress" {
                self.timer?.invalidate()
                isShowingWaitingForBringer = false
            }
        })
    }
}

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
    
    @State private var paymentIntentID: String = ""
    
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
            
            Button("CANCEL ORDER") {
                // TODO: confirmation screen
                deactivateOrder()
            }
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundColor(Color.white)
            .background(Rectangle()
                            .fill(CustomColors.lightRed)
                            .frame(width: CustomDimensions.width, height: 35)
                            .cornerRadius(15))
            .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
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
        
        // TODO: show toast if order fails to be canceled
        sendCancelOrder { success in
            guard let success = success, success == true else {
                return
            }

            // moves order from active to past, closes view
            ref.child("activeOrders").child(order.id).observeSingleEvent(of: .value, with: { (snapshot) in
                
                // adds to past
                ref.child("users").child(userID).child("pastOrders").child(order.id).updateChildValues(snapshot.value as! [AnyHashable : Any])
                
                // sets date completed
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/YYYY"
                let currentDateString = dateFormatter.string(from: Date())
                
                ref.child("users").child(userID).child("pastOrders").child(order.id).updateChildValues(["dateCompleted" : currentDateString])
                
                // sets order cancelled
                ref.child("users").child(userID).child("pastOrders").child(order.id).updateChildValues(["status" : "cancelled"])
                
                
                // removes from active
                ref.child("activeOrders").child(order.id).removeValue()
                ref.child("users").child(userID).child("activeOrders").removeValue()
                
                self.timer?.invalidate()
                isShowingWaitingForBringer = false
                isOrderCancelledWaiting = true
            })
        }
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
        ref.child("activeOrders").child(order.id).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let currentStatus = (snapshot.value as! NSDictionary)["status"] else {
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
    
    func sendCancelOrder(completion: @escaping (Bool?) -> Void) {
        let url = URL(string: "https://bringers-nodejs.vercel.app/cancel-order")!

        getOrderPaymentIntent { _ in
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try! JSONEncoder().encode([
                "paymentIntentID" : self.paymentIntentID,
            ])
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let _ = data, error == nil,
                      (response as? HTTPURLResponse)?.statusCode == 200 else {
                          completion(nil)
                          return
                      }
                completion(true)
            }.resume()
        }
    }
    
    func getOrderPaymentIntent(completion: @escaping (Bool?) -> Void) {
        let ref = Database.database().reference()
        
        ref.child("activeOrders").child(self.order.id).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let activeUser = (snapshot.value as? [AnyHashable : Any]) else {
                completion(nil)
                return
            }
            
            guard let paymentIntentID = (activeUser["paymentIntentID"] as? String) else {
                completion(nil)
                return
            }

            self.paymentIntentID = paymentIntentID
            completion(true)
        })
    }
}

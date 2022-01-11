//
//  OrderComingMapView.swift
//  Bringers
//
//  Created by Keith C on 12/23/21.
//

import Foundation
import SwiftUI
import MapKit
import FirebaseAuth
import FirebaseDatabase

struct OrderComingMapView: View {
    
    @StateObject private var viewModel = LocationViewModel()
    
    @Binding var isShowingOrderComing: Bool
    @Binding var isOrderCancelledMap: Bool
    
    @Binding var order: OrderModel
    
    @State private var isShowingReceipt = false
    @State private var isShowingUserProfile = false
    
    var receiptImageName = "receipt"
    
    init(isShowingOrderComing: Binding<Bool>, isOrderCancelledMap: Binding<Bool>, order: Binding<OrderModel>) {
        
        self._isShowingOrderComing = isShowingOrderComing
        self._order = order
        self._isOrderCancelledMap = isOrderCancelledMap
    }
    
    var body: some View {
        VStack {
            CustomTitleText(labelText: "[SCARRA] IS COMING WITH YOUR ORDER!")

            Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
                .frame(width: 400, height: 300)
                .accentColor(CustomColors.seafoamGreen)
                .onAppear {
                    viewModel.checkIfLocationServicesEnabled()
                }
            HStack {
                
                Button(action: {
                    isShowingUserProfile.toggle()
                }) {
                    Image("scarra")
                        .resizable()
                        .frame(width: 74, height: 74)
                }
                .sheet(isPresented: $isShowingUserProfile, content: {
                    UserProfileView()
                })
                
                VStack {
                    
                    Button {
                        // TODO: implement texting
                    } label: {
                        Image(systemName: "message.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(CustomColors.darkGray)
                    }
                    .frame(width: 49, height: 28)
                    .background(CustomColors.seafoamGreen)
                    .cornerRadius(15)
                    .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
                    
                    Button {
                        // TODO: implement calling
                    } label: {
                        Image(systemName: "phone.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(CustomColors.darkGray)
                    }
                    .frame(width: 49, height: 28)
                    .background(CustomColors.seafoamGreen)
                    .cornerRadius(15)
                    .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
                }
                
                if receiptImageName != "" {
                    Button(action: {
                        isShowingReceipt.toggle()
                    }) {
                        Image(receiptImageName)
                            .resizable()
                            .frame(width: 74, height: 74)
                    }
                    .sheet(isPresented: $isShowingReceipt, content: {
                        ReceiptView()
                    })
                }
            }
            .background(CustomColors.blueGray.opacity(0.6))
            .cornerRadius(15)
            .frame(width: CustomDimensions.width, height: 108, alignment: .center)
            
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
        .edgesIgnoringSafeArea(.bottom)
        .tabItem {
            Image(systemName: "cart")
            Text("Order")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
        .onAppear() {
            viewModel.setOrderID(id: $order.wrappedValue.id)
            viewModel.setViewParentType(type: MapViewParent.order)
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
        })
        
        isShowingOrderComing = false
        isOrderCancelledMap = true
    }
}

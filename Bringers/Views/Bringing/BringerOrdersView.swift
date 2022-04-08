//
//  BringerOrdersView.swift
//  Bringers
//
//  Created by Keith C on 12/26/21.
//

import Foundation
import MapKit
import SwiftUI
import Mapper

struct BringerOrdersView: View {
    
    @StateObject private var viewModel = BringerOrdersViewModel()
    
    @Binding var givenOrder: OrderModel
    
    init(givenOrder: Binding<OrderModel>) {
        UITableView.appearance().backgroundColor = .clear
        self._givenOrder = givenOrder
    }
    
    var body: some View {
        ZStack {
            if viewModel.userInfo.stripeAccountID == "" {
                
                VStack {
                    CustomTitleText(labelText: "TO BECOME A BRINGER AND PICK UP ORDERS, WE NEED TO CONFIRM A FEW DETAILS:")
                    
                    Link(destination: URL(string: viewModel.stripeURLString)!, label: {
                        Button("CONFIRM ACCOUNT") {
                            
                            viewModel.isProgressViewHidden = false
                            
                            ProgressView()
                                .isHidden(viewModel.isProgressViewHidden)
                                .scaleEffect(x: 2, y: 2, anchor: .center)
                                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center)
                                .background(RoundedRectangle(cornerRadius: 3)
                                                .fill(CustomColors.seafoamGreen))
                                .progressViewStyle(CircularProgressViewStyle(tint: CustomColors.darkGray))

                            
                            viewModel.didSelectConnectWithStripe { url in
                                DispatchQueue.main.async {
                                    viewModel.stripeURLString = url ?? ""
                                    viewModel.isProgressViewHidden = true
                                    viewModel.isShowingSafari = true
                                }
                            }
                        }
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(Color.white)
                        .background(Rectangle()
                                        .fill(CustomColors.blueGray.opacity(0.6))
                                        .frame(width: CustomDimensions.width, height: 70)
                                        .cornerRadius(15))
                        .padding(EdgeInsets(top: 30, leading: 20, bottom: 10, trailing: 20))
                    })
                }
            }
            else {
                if viewModel.orders.isEmpty {
                    List {
                        CustomLabel(labelText: "NO ACTIVE ORDERS IN YOUR AREA", height: 100, isBold: true, fontSize: 30, hasBackground: false)
                            .multilineTextAlignment(.center)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                    .frame(width: CustomDimensions.width + 20, height: CustomDimensions.height550)
                    .refreshable {
                        viewModel.getActiveOrders { (orders) in
                            viewModel.getYourProfile()
                            viewModel.orders = orders
                        }
                    }
                }
                else {
                    List(viewModel.orders) { order in
                        OrderListButton(
                            isShowingOrder: $viewModel.isShowingOrder,
                            order: order,
                            currentOrder: $viewModel.currentOrder,
                            distance: viewModel.currentCoords.distance(from: order.location),
                            distanceAlpha: ((viewModel.currentCoords.distance(from: order.location) - viewModel.currentCoords.distance(from: viewModel.lowestDistance)) * viewModel.alphaIncrementValDistance) + 0.4,
                            shippingAlpha: ((order.deliveryFee - viewModel.lowestShipping) * viewModel.alphaIncrementValShipping) + 0.4
                        )
                    }
                    .refreshable {
                        viewModel.getActiveOrders { (orders) in
                            viewModel.getYourProfile()
                            viewModel.orders = orders
                        }
                    }
                    .frame(width: CustomDimensions.width + 20, height: CustomDimensions.height550)
                }
            }
            ProgressView()
                .scaleEffect(x: 2, y: 2, anchor: .center)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3)
                                .fill(CustomColors.seafoamGreen))
                .progressViewStyle(CircularProgressViewStyle(tint: CustomColors.darkGray))
                .isHidden(viewModel.isProgressViewHidden)
        }
        .toast(message: viewModel.toastMessage,
               isShowing: $viewModel.isShowingToast,
               duration: Toast.long
        )
        .frame(width: CustomDimensions.width + 20, height: CustomDimensions.height550)
        .onAppear {
            viewModel.checkIfLocationServicesEnabled()
            
            viewModel.getActiveOrders { (orders) in
                viewModel.getYourProfile()
                viewModel.orders = orders
            }
        }
        .background(Rectangle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: CustomDimensions.width, height: CustomDimensions.height550)
                        .cornerRadius(15)
                        .isHidden(viewModel.userInfo.stripeAccountID == ""))
        .tabItem {
            Image(systemName: "bag")
            Text("Bring")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
        
        .sheet(isPresented: $viewModel.isShowingOrder, onDismiss: {
            if !viewModel.isShowingOrder && viewModel.acceptPressed {
                viewModel.isShowingBringerConfirm.toggle()
            }
            if !viewModel.isShowingOrder && viewModel.offerPressed {
                viewModel.isShowingBringerOffer.toggle()
            }
            viewModel.acceptPressed = false
            viewModel.offerPressed = false
        }) {
            BringerSelectedOrderView(
                isShowingOrder: $viewModel.isShowingOrder,
                acceptPressed: $viewModel.acceptPressed,
                offerPressed: $viewModel.offerPressed,
                order: $viewModel.currentOrder,
                currentCoords: $viewModel.currentCoords
            )
        }
        
        .sheet(isPresented: $viewModel.isShowingBringerOffer, onDismiss: {
            viewModel.getActiveOrders { (orders) in
                viewModel.getYourProfile()
                viewModel.orders = orders
            }
            
            if !viewModel.isShowingBringerOffer && viewModel.confirmPressed {
                viewModel.isShowingBringerConfirm.toggle()
                viewModel.confirmPressed = false
            }
        }) {
            BringerOfferOrderView(
                isShowingBringerOffer: $viewModel.isShowingBringerOffer,
                confirmPressed: $viewModel.confirmPressed,
                currentOrder: $viewModel.currentOrder,
                bringerCoords: $viewModel.currentCoords,
                currentOffer: $viewModel.currentOffer
            )
        }
        
        .sheet(isPresented: $viewModel.isShowingBringerConfirm, onDismiss: {
            viewModel.getActiveOrders { (orders) in
                viewModel.getYourProfile()
                viewModel.orders = orders
            }
            
            if !viewModel.isShowingBringerConfirm && viewModel.confirmPressed {
                viewModel.setOrderInProgress()
                viewModel.incrementBringersAccepted()
                viewModel.confirmPressed = false
                viewModel.isShowingBringerMap.toggle()
            }
            if !viewModel.isShowingBringerConfirm && viewModel.offerSent {
                viewModel.sendOffer(orderID: viewModel.currentOrder.id, offer: viewModel.currentOffer)
                viewModel.offerSent = false
            }
        }) {
            BringerConfirmOrderView(
                isShowingBringerConfirm: $viewModel.isShowingBringerConfirm,
                confirmPressed: $viewModel.confirmPressed,
                currentOrder: $viewModel.currentOrder,
                currentOffer: $viewModel.currentOffer,
                offerSent: $viewModel.offerSent
            )
        }
        
        .fullScreenCover(isPresented: $viewModel.isShowingBringerMap, onDismiss: {
            
            viewModel.getActiveOrders { (orders) in
                viewModel.getYourProfile()
                viewModel.orders = orders
            }
            
            if !viewModel.isShowingBringerMap && !viewModel.isOrderCancelledMap {
                viewModel.incrementBringersCompleted()
            }
            else if viewModel.isOrderCancelledMap {
                viewModel.incrementBringersCanceled()
            }
            
            self.givenOrder = OrderModel()
        }) {
            BringerOrderMapView(
                isShowingBringerMap: $viewModel.isShowingBringerMap,
                isOrderCancelledMap: $viewModel.isOrderCancelledMap,
                currentOrder: self.givenOrder.status == "inprogress" ? $givenOrder : $viewModel.currentOrder,
                currentCoords: $viewModel.currentCoords
            )
        }
        .sheet(isPresented: $viewModel.isShowingSafari) {
            SafariView(url: URL(string: viewModel.stripeURLString)!)
        }
        .onChange(of: viewModel.isShowingSafari) { _ in
            if !viewModel.isShowingSafari {
                viewModel.fetchUserDetails { chargesEnabled in
                    if chargesEnabled! {
                        viewModel.updateUserProfileStripeAccountID()
                        
                        viewModel.getActiveOrders { (orders) in
                            viewModel.getYourProfile()
                            viewModel.orders = orders
                        }
                    }
                    else {
                        print("ERROR USER NOT CREATED")
                    }
                }
            }
        }
        .onAppear {
            if self.givenOrder.status == "inprogress" {
                viewModel.isShowingBringerMap = true
            }
        }
    }
}

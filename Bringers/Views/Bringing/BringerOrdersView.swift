//
//  BringerOrdersView.swift
//  Bringers
//
//  Created by Keith C on 12/26/21.
//

import Foundation
import MapKit
import SwiftUI
import FirebaseDatabase
import Mapper

struct BringerOrdersView: View {
    
    @State private var isShowingOrder: Bool = false
    @State private var isShowingBringerConfirm: Bool = false
    @State private var confirmPressed: Bool = false
    @State private var isShowingBringerMap: Bool = false
    
    @State private var orderTitleState: String = ""
    
    @State private var orderButtons: [OrderListButton] = []
    
    @State private var orders: [OrderModel] = []
    @State private var currentOrder: OrderModel = OrderModel(id: "", title: "", description: "", pickupBuy: "", maxPrice: 0, deliveryFee: 0, dateSent: "", dateCompleted: "", status: "", userID: "", location: CLLocationCoordinate2D(latitude: 37.334388, longitude: -122.009015))
    
    @State private var isProgressViewHidden: Bool = false
    
    @StateObject private var viewModel = BringerOrderLocationViewModel()
    
    static var currentCoords: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.334388, longitude: -122.009015)
    static var lowestDistance: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.334388, longitude: -122.009015)
    static var alphaIncrementValDistance: CGFloat = 0.1 //= 0.7/distanceGap
    static var lowestShipping: CGFloat = 0
    static var alphaIncrementValShipping: CGFloat = 0.1 //= 0.7/shippingGap
    
    private var testDistances: [CGFloat] = [1.2, 2, 3.5, 7.6, 8.4, 10.6, 12, 13.2, 16, 18, 20, 22.1]
    private var testOrderNames: [String] = ["ass", "butt", "poo", "cock", "balls", "piss", "shit", "cunt", "fuck", "ween", "dick", "puss"]
    private var testShipping: [CGFloat] = [5, 10, 6, 14, 20, 9, 11, 14, 3, 6, 22, 1]
    
    init() {
        UITableView.appearance().separatorStyle = .none
        UITableViewCell.appearance().backgroundColor = .red
        UITableView.appearance().backgroundColor = .clear
    }
    
    
    var body: some View {
        ZStack {
            List(orders) { order in
                OrderListButton(
                    orderTitleState: $orderTitleState,
                    isShowingOrder: $isShowingOrder,
                    order: order,
                    currentOrder: $currentOrder,
                    orderTitle: order.title,
                    distance: BringerOrdersView.currentCoords.distance(from: order.location),
                    shippingCost: order.deliveryFee,
                    distanceAlpha: ((BringerOrdersView.currentCoords.distance(from: order.location) - BringerOrdersView.currentCoords.distance(from: BringerOrdersView.lowestDistance)) * BringerOrdersView.alphaIncrementValDistance) + 0.4,
                    shippingAlpha: ((order.deliveryFee - BringerOrdersView.lowestShipping) * BringerOrdersView.alphaIncrementValShipping) + 0.4
                )
            }
            ProgressView()
                .scaleEffect(x: 2, y: 2, anchor: .center)
                .frame(width: CustomDimensions.width, height: CustomDimensions.height600, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3)
                                .fill(CustomColors.seafoamGreen))
                .progressViewStyle(CircularProgressViewStyle(tint: CustomColors.darkGray))
                .isHidden(self.isProgressViewHidden)
        }
        .frame(width: CustomDimensions.width + 20, height: CustomDimensions.height550)
        .onAppear {
            viewModel.checkIfLocationServicesEnabled()
            getActiveOrders { (orders) in
                self.orders = orders
            }
        }
        .background(Rectangle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: CustomDimensions.width, height: CustomDimensions.height550)
                        .cornerRadius(15))
        .tabItem {
            Image(systemName: "bag")
            Text("Bring")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
        
        // i have no clue why this is needed; without it the values don't update from the backend until after the first press (SEE: PrelogView)
        .onChange(of: orderTitleState) { _ in }
        
        .sheet(isPresented: $isShowingOrder, onDismiss: {
            if !isShowingOrder && confirmPressed {
                confirmPressed = false
                isShowingBringerConfirm.toggle()
            }
        }) {
            // TODO: add actual distance calculation
            BringerSelectedOrderView(
                isShowingOrder: $isShowingOrder,
                confirmPressed: $confirmPressed,
                order: $currentOrder,
                distance: 1)
        }
        
        .fullScreenCover(isPresented: $isShowingBringerConfirm, onDismiss: {
            if !isShowingBringerConfirm {
                isShowingBringerMap.toggle()
            }
        }) {
            // TODO: replace hardcoded data with backend values from activeOrder
            BringerConfirmOrderBuyView(
                isShowingBringerConfirm: $isShowingBringerConfirm,
                maxItemPrice: 68,
                yourProfit: 2
            )
        }
        
        .fullScreenCover(isPresented: $isShowingBringerMap) {
            BringerOrderMapView(isShowingBringerMap: $isShowingBringerMap)
        }
    }
    
    func getActiveOrders(completion: @escaping ([OrderModel]) -> ()) {
        let ref = Database.database().reference()
        
        var allActiveOrders: [OrderModel] = []
        
        ref.child("activeOrders").observeSingleEvent(of: .value, with: { (snapshot) in
            let activeOrders = (snapshot.value as! NSDictionary).allValues
            for activeOrder in activeOrders {
                let activeOrderMap = Order.from(activeOrder as! NSDictionary)
                
                guard let activeOrderMap = activeOrderMap else {
                    return
                }
                
                let order = OrderModel(
                    id: activeOrderMap.id,
                    title: activeOrderMap.title,
                    description: activeOrderMap.description,
                    pickupBuy: activeOrderMap.pickupBuy,
                    maxPrice: activeOrderMap.maxPrice,
                    deliveryFee: activeOrderMap.deliveryFee,
                    dateSent: activeOrderMap.dateSent,
                    dateCompleted: activeOrderMap.dateCompleted,
                    status: activeOrderMap.status,
                    userID: activeOrderMap.userID,
                    location: activeOrderMap.location
                )
                
                allActiveOrders.append(order)
            }
            
            DispatchQueue.main.async {
                
                self.isProgressViewHidden = true
                
                // calc lowest/highest location
                BringerOrdersView.lowestDistance = allActiveOrders.min(by: { a, b in BringerOrdersView.currentCoords.distance(from: a.location) < BringerOrdersView.currentCoords.distance(from: b.location) })?.location ?? CLLocationCoordinate2D(latitude: 37.334388, longitude: -122.009015)
                let highestDistance = allActiveOrders.max(by: { a, b in BringerOrdersView.currentCoords.distance(from: a.location) < BringerOrdersView.currentCoords.distance(from: b.location) })?.location ?? CLLocationCoordinate2D(latitude: 37.334388, longitude: -122.009015)
                // distance gap from lowest/highest
                let distanceGap: CGFloat = BringerOrdersView.currentCoords.distance(from: highestDistance) - BringerOrdersView.currentCoords.distance(from: BringerOrdersView.lowestDistance)
                // gets alpha
                BringerOrdersView.alphaIncrementValDistance = 0.7/distanceGap
                
                // delivery calcs
                BringerOrdersView.lowestShipping = allActiveOrders.min(by: { a, b in a.deliveryFee < b.deliveryFee })?.deliveryFee ?? 0
                let highestShipping: CGFloat = allActiveOrders.max(by: { a, b in a.deliveryFee < b.deliveryFee })?.deliveryFee ?? 0
                let shippingGap: CGFloat = highestShipping - BringerOrdersView.lowestShipping
                BringerOrdersView.alphaIncrementValShipping = 0.7/shippingGap
                
                // sorts orders on distance
                let sortedOrders: [OrderModel] = allActiveOrders.sorted(by: { a, b in BringerOrdersView.currentCoords.distance(from: a.location) < BringerOrdersView.currentCoords.distance(from: b.location) })
                
                
                completion(sortedOrders)
            }
        })
    }
}

final class BringerOrderLocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    
    @Published private(set) var orderID: String = ""
    
    @Published var region = MKCoordinateRegion(
        center: MapDetails.defaultCoords,
        span: MapDetails.defaultSpan)
    
    func checkIfLocationServicesEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.delegate = self
            locationManager?.startUpdatingLocation()
        }
        else {
            // TODO: (turn on location services) alert
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else {
            return
        }
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // TODO: show alert restricted (likely parental controls)
            print("ass res")
        case .denied:
            // TODO: show alert denied (go settings and change)
            print("ass denied")
        case .authorizedAlways, .authorizedWhenInUse:
            guard let location = locationManager.location else {
                break
            }
            BringerOrdersView.currentCoords = location.coordinate
        @unknown default:
            break
        }
    }
}

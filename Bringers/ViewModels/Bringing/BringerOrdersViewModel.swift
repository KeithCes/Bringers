//
//  BringerOrdersViewModel.swift
//  Bringers
//
//  Created by Keith C on 3/26/22.
//

import Foundation
import SwiftUI
import FirebaseDatabase
import FirebaseAuth
import MapKit
import SafariServices

final class BringerOrdersViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var isShowingOrder: Bool = false
    @Published var acceptPressed: Bool = false
    @Published var offerPressed: Bool = false
    @Published var isShowingBringerConfirm: Bool = false
    @Published var isShowingBringerOffer: Bool = false
    @Published var confirmPressed: Bool = false
    @Published var isShowingBringerMap: Bool = false
    @Published var isOrderCancelledMap: Bool = false
    @Published var isShowingSafari: Bool = false
    @Published var offerSent: Bool = false
    
    @Published var orders: [OrderModel] = []
    @Published var currentOrder: OrderModel = OrderModel()
    @Published var currentOffer: OfferModel = OfferModel()
    
    @Published var isProgressViewHidden: Bool = false
    
    @Published var currentCoords: CLLocationCoordinate2D = DefaultCoords.coords
    @Published var lowestDistance: CLLocationCoordinate2D = DefaultCoords.coords
    @Published var alphaIncrementValDistance: CGFloat = 0.1
    @Published var lowestShipping: CGFloat = 0
    @Published var alphaIncrementValShipping: CGFloat = 0.1
    
    @Published var isShowingToast: Bool = false
    @Published var toastMessage: String = "Error"
    
    @Published var userInfo: UserInfoModel = UserInfoModel()
    
    // TODO: change to custom URL when wesbite setup
    @Published var stripeURLString = "https://example.com"
    @Published var stripeAccountID = ""
    
    @Published var region = MKCoordinateRegion(center:  DefaultCoords.coords, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
    
    private var locationManager: CLLocationManager?
    
    
    func getActiveOrders(completion: @escaping ([OrderModel]) -> ()) {
        let ref = Database.database().reference()
        let userID = Auth.auth().currentUser!.uid
        
        var allActiveOrders: [OrderModel] = []
        
        ref.child("activeOrders").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let activeOrders = (snapshot.value as? NSDictionary)?.allValues else {
                self.isProgressViewHidden = true
                completion([])
                return
            }
            for activeOrder in activeOrders {
                let activeOrderMap = Order.from(activeOrder as! NSDictionary)
                
                guard let activeOrderMap = activeOrderMap else {
                    self.isProgressViewHidden = true
                    continue
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
                
                self.currentCoords = self.getCurrentCoords()
                
                // calc lowest/highest location
                self.lowestDistance = allActiveOrders.min(by: { a, b in self.currentCoords.distance(from: a.location) < self.currentCoords.distance(from: b.location) })?.location ?? DefaultCoords.coords
                let highestDistance = allActiveOrders.max(by: { a, b in self.currentCoords.distance(from: a.location) < self.currentCoords.distance(from: b.location) })?.location ?? DefaultCoords.coords
                // distance gap from lowest/highest
                let distanceGap: CGFloat = self.currentCoords.distance(from: highestDistance) - self.currentCoords.distance(from: self.lowestDistance)
                // gets alpha
                self.alphaIncrementValDistance = distanceGap != 0 ? 0.7/distanceGap : 0.4
                
                // delivery calcs
                self.lowestShipping = allActiveOrders.min(by: { a, b in a.deliveryFee < b.deliveryFee })?.deliveryFee ?? 0
                let highestShipping: CGFloat = allActiveOrders.max(by: { a, b in a.deliveryFee < b.deliveryFee })?.deliveryFee ?? 0
                let shippingGap: CGFloat = highestShipping - self.lowestShipping
                self.alphaIncrementValShipping = shippingGap != 0 ? 0.7/shippingGap : 0.4
                
                // filters only waiting orders (not in progress) and not your own
                let filteredActiveOrders: [OrderModel] = allActiveOrders.filter({ a in a.status == "waiting" && a.userID != userID })
                
                // sorts orders on distance
                let sortedOrders: [OrderModel] = filteredActiveOrders.sorted(by: { a, b in self.currentCoords.distance(from: a.location) < self.currentCoords.distance(from: b.location) })
                
                completion(sortedOrders)
            }
        })
    }
    
    func setOrderInProgress() {
        let ref = Database.database().reference()
        let userID = Auth.auth().currentUser!.uid
        
        ref.child("activeOrders").child(self.currentOrder.id).updateChildValues(["status" : "inprogress"])
        ref.child("activeOrders").child(self.currentOrder.id).updateChildValues(["bringerID" : userID])
        ref.child("activeOrders").child(self.currentOrder.id).updateChildValues(["bringerLocation" : [self.currentCoords.latitude, self.currentCoords.longitude]])
        
        ref.child("users").child(userID).child("activeBringers").updateChildValues(["activeBringer" : self.currentOrder.id])
    }
    
    func getYourProfile() {
        
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference()
        
        ref.child("users").child(userID).child("userInfo").observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let activeUserInfo = snapshot.value as? NSDictionary else {
                return
            }
            
            guard let activeUserInfoMap = UserInfo.from(activeUserInfo) else {
                return
            }
            
            let userInfo = UserInfoModel(
                dateOfBirth: activeUserInfoMap.dateOfBirth,
                dateOfCreation: activeUserInfoMap.dateOfCreation,
                email: activeUserInfoMap.email,
                firstName: activeUserInfoMap.firstName,
                lastName: activeUserInfoMap.lastName,
                ordersCompleted: activeUserInfoMap.ordersCompleted,
                ordersPlaced: activeUserInfoMap.ordersPlaced,
                ordersCanceled: activeUserInfoMap.ordersCanceled,
                bringersCompleted: activeUserInfoMap.bringersCompleted,
                bringersAccepted: activeUserInfoMap.bringersAccepted,
                bringersCanceled: activeUserInfoMap.bringersCanceled,
                phoneNumber: activeUserInfoMap.phoneNumber,
                profilePictureURL: activeUserInfoMap.profilePictureURL,
                rating: activeUserInfoMap.rating,
                totalRatings: activeUserInfoMap.totalRatings,
                stripeAccountID: activeUserInfoMap.stripeAccountID,
                stripeCustomerID: activeUserInfoMap.stripeCustomerID,
                address: activeUserInfoMap.address,
                state: activeUserInfoMap.state,
                city: activeUserInfoMap.city,
                country: activeUserInfoMap.country,
                zipcode: activeUserInfoMap.zipcode
            )
            
            self.isProgressViewHidden = true
            self.userInfo = userInfo
        })
    }
    
    func didSelectConnectWithStripe(completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://bringers-nodejs.vercel.app/onboard-user")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data,
                  error == nil,
                  (response as? HTTPURLResponse)?.statusCode == 200,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                  let accountURLString = json["url"] as? String,
                  let accountID = json["userID"] as? String else {
                      completion(nil)
                      return
                  }
            DispatchQueue.main.async {
                self.stripeAccountID = accountID
            }
            completion(accountURLString)
        }.resume()
    }
    
    func fetchUserDetails(completion: @escaping (Bool?) -> Void) {
        let url = URL(string: "https://bringers-nodejs.vercel.app/get-user-details")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(["userID" : self.stripeAccountID])
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data,
                  error == nil,
                  (response as? HTTPURLResponse)?.statusCode == 200,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                  let chargesEnabled = json["chargesEnabled"] as? Bool else {
                      completion(nil)
                      return
                  }
            completion(chargesEnabled)
        }.resume()
    }
    
    func updateUserProfileStripeAccountID() {
        
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference()
        
        
        ref.child("users").child(userID).child("userInfo").updateChildValues(["stripeAccountID" : self.stripeAccountID])
    }
    
    func incrementBringersAccepted() {
        let ref = Database.database().reference()
        let userID = Auth.auth().currentUser!.uid
        
        ref.child("users").child(userID).child("userInfo").updateChildValues(["bringersAccepted" : self.userInfo.bringersAccepted + 1])
    }
    
    func incrementBringersCanceled() {
        let ref = Database.database().reference()
        let userID = Auth.auth().currentUser!.uid
        
        ref.child("users").child(userID).child("userInfo").updateChildValues(["bringersCanceled" : self.userInfo.bringersCanceled + 1])
    }
    
    func incrementBringersCompleted() {
        let ref = Database.database().reference()
        let userID = Auth.auth().currentUser!.uid
        
        ref.child("users").child(userID).child("userInfo").updateChildValues(["bringersCompleted" : self.userInfo.bringersCompleted + 1])
    }
    
    func checkIfLocationServicesEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.delegate = self
            locationManager?.startUpdatingLocation()
        }
        else {
            self.toastMessage = "Error: turn on location services!"
            self.isShowingToast.toggle()
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
            self.toastMessage = "Error: location services are restricted, turn off restriction to use."
            self.isShowingToast.toggle()
            print("Error: restricted")
        case .denied:
            self.toastMessage = "Error: location services are denied, go to settings to change"
            self.isShowingToast.toggle()
            print("Error: denied")
        case .authorizedAlways, .authorizedWhenInUse:
            guard let location = locationManager.location else {
                break
            }
            self.currentCoords = location.coordinate
        @unknown default:
            break
        }
    }
    
    func getCurrentCoords() -> CLLocationCoordinate2D {
        return self.currentCoords
    }
    
    func sendOffer(orderID: String, offer: OfferModel) {
        
        let ref = Database.database().reference()
        let userID = Auth.auth().currentUser!.uid
        
        ref.child("activeOrders").child(orderID).child("offers").child(userID).updateChildValues(["id" : offer.id])
        ref.child("activeOrders").child(orderID).child("offers").child(userID).updateChildValues(["bringerID" : offer.bringerID])
        ref.child("activeOrders").child(orderID).child("offers").child(userID).updateChildValues(["bringerLocation" : [offer.bringerLocation.latitude, offer.bringerLocation.longitude]])
        ref.child("activeOrders").child(orderID).child("offers").child(userID).updateChildValues(["offerAmount" : offer.offerAmount])
    }
}

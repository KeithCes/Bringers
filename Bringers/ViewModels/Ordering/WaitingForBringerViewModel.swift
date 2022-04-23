//
//  WaitingForBringerViewModel.swift
//  Bringers
//
//  Created by Keith C on 3/26/22.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import MapKit

final class WaitingForBringerViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var animationAmount: CGFloat = 1
    
    @Published var timer: Timer?
    
    @Published var isShowingToast: Bool = false
    @Published var toastMessage: String = "Error"
    
    @Published var isShowingWaitingForBringer: Bool = true
    @Published var isOrderCancelledWaiting: Bool = false
    
    @Published var isShowingOfferConfirm: Bool = false
    @Published var isOfferAccepted: Bool = false
    @Published var offers: [OfferModel] = []
    @Published var currentOffer: OfferModel = OfferModel()
    
    @Published var region = MKCoordinateRegion(center: DefaultCoords.coords, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
    
    private var locationManager: CLLocationManager?
    private var startTime: Date?
    
    
    func deactivateOrder(orderID: String) {
        let userID = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        
        // moves order from active to past, closes view
        ref.child("activeOrders").child(orderID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // adds to past
            ref.child("users").child(userID).child("pastOrders").child(orderID).updateChildValues(snapshot.value as! [AnyHashable : Any])
            
            // sets date completed
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/YYYY"
            let currentDateString = dateFormatter.string(from: Date())
            
            ref.child("users").child(userID).child("pastOrders").child(orderID).updateChildValues(["dateCompleted" : currentDateString])
            
            // sets order cancelled
            ref.child("users").child(userID).child("pastOrders").child(orderID).updateChildValues(["status" : "cancelled"])
            
            
            // removes from active
            ref.child("activeOrders").child(orderID).removeValue()
            ref.child("users").child(userID).child("activeOrders").removeValue()
            
            self.timer?.invalidate()
            self.isOrderCancelledWaiting = true
        })
    }
    
    func sendUserLocation(orderID: String) {
        let ref = Database.database().reference()
        guard let locationManager = self.getLocation() else {
            return
        }
        ref.child("activeOrders").child(orderID).updateChildValues(["location":[locationManager.location?.coordinate.latitude, locationManager.location?.coordinate.longitude]])
    }
    
    func checkIfOrderInProgress(orderID: String) {
        let ref = Database.database().reference()
        ref.child("activeOrders").child(orderID).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let currentStatus = (snapshot.value as! NSDictionary)["status"] else {
                self.timer?.invalidate()
                self.isShowingWaitingForBringer = false
                return
            }
            
            if currentStatus as! String == "inprogress" {
                self.timer?.invalidate()
                self.isShowingWaitingForBringer = false
            }
        })
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
    
    private func checkLocationAuthorization(orderID: String) {
        guard let locationManager = locationManager else {
            return
        }
        
        let ref = Database.database().reference()
            
        ref.child("activeOrders").child(orderID).updateChildValues(["location":[locationManager.location?.coordinate.latitude, locationManager.location?.coordinate.longitude]])
        
        
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
            region = MKCoordinateRegion(center: location.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        @unknown default:
            break
        }
    }
    
    private func locationManagerDidChangeAuthorization(orderID: String, _ manager: CLLocationManager) {
        checkLocationAuthorization(orderID: orderID)
    }
    
    private func getLocation() -> CLLocationManager? {
        return self.locationManager
    }
    
    func getOffers(orderID: String, completion: @escaping ([OfferModel]) -> ()) {
        let ref = Database.database().reference()
        
        var allOffers: [OfferModel] = []
        
        ref.child("activeOrders").child(orderID).child("offers").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let activeOffers = (snapshot.value as? NSDictionary)?.allValues else {
                completion([])
                return
            }
            for activeOffer in activeOffers {
                let activeOfferMap = Offer.from(activeOffer as! NSDictionary)
                
                guard let activeOfferMap = activeOfferMap else {
                    continue
                }
                
                let offer = OfferModel(
                    id: activeOfferMap.id,
                    bringerID: activeOfferMap.bringerID,
                    bringerLocation: activeOfferMap.bringerLocation,
                    offerAmount: activeOfferMap.offerAmount
                )
                
                allOffers.append(offer)
            }
            
            completion(allOffers)
        })
    }
    
    func setOrderInProgress(order: OrderModel, completion: @escaping (String) -> Void) {
        let ref = Database.database().reference()
        
        ref.child("activeOrders").child(order.id).updateChildValues(["status" : "inprogress"])
        ref.child("activeOrders").child(order.id).updateChildValues(["bringerID" : self.currentOffer.bringerID])
        ref.child("activeOrders").child(order.id).updateChildValues(["bringerLocation" : [self.currentOffer.bringerLocation.latitude, self.currentOffer.bringerLocation.longitude]])
        ref.child("activeOrders").child(order.id).updateChildValues(["deliveryFee" : self.currentOffer.offerAmount])
        
        ref.child("users").child(self.currentOffer.bringerID).child("activeBringers").updateChildValues(["activeBringer" : order.id])
        
        self.checkIfOrderInProgress(orderID: order.id)
        
        
        getCardSource(userID: order.userID) { sourceAndCustomerID in
            let url = URL(string: "https://bringers-nodejs.vercel.app/charge-customer")!
            
            // TODO: calc tax based on location (change 0.0625 to be dynamic)
            let estTax = round(CGFloat(order.maxPrice) * 0.0625 * 100)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try! JSONEncoder().encode([
                "amount" : "\(Int((self.currentOffer.offerAmount * 100) + (order.maxPrice * 100) + estTax))",
                "customerID" : sourceAndCustomerID?["customerID"],
                "sourceID" : sourceAndCustomerID?["defaultSource"]
            ])
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data,
                      error == nil,
                      (response as? HTTPURLResponse)?.statusCode == 200,
                      let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                      let chargeID = json["chargeID"] as? String else {
                          completion("")
                          return
                      }
                completion(chargeID)
            }.resume()
        }
    }
    
    func setChargeID(chargeID: String, orderID: String) {
        let ref = Database.database().reference()
        ref.child("activeOrders").child(orderID).updateChildValues(["chargeID" : chargeID])
    }
    
    func getCardSource(userID: String, completion: @escaping ([String: String]?) -> Void) {
        
        let ref = Database.database().reference()
        ref.child("users").child(userID).child("userInfo").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let activeUserInfo = snapshot.value as? NSDictionary else {
                return
            }
            
            guard let activeUserInfoMap = UserInfo.from(activeUserInfo) else {
                return
            }
            
            let url = URL(string: "https://bringers-nodejs.vercel.app/get-customer-details")!
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try! JSONEncoder().encode(["customerID" : activeUserInfoMap.stripeCustomerID])
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data,
                      error == nil,
                      (response as? HTTPURLResponse)?.statusCode == 200,
                      let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                      let defaultSource = json["defaultSource"] as? String else {
                          completion(nil)
                          return
                      }
                completion(["defaultSource": defaultSource, "customerID": activeUserInfoMap.stripeCustomerID])
            }.resume()
        })
    }
}

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
    
    @Published var paymentIntentID: String = ""
    
    @Published var timer: Timer?
    
    @Published var isShowingWaitingForBringer: Bool = true
    @Published var isOrderCancelledWaiting: Bool = false
    
    @Published var region = MKCoordinateRegion(center: DefaultCoords.coords, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
    
    private var locationManager: CLLocationManager?
    private var startTime: Date?
    
    
    func deactivateOrder(orderID: String) {
        let userID = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        
        // TODO: show toast if order fails to be canceled
        sendCancelOrder(orderID: orderID) { success in
            guard let success = success, success == true else {
                return
            }

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
    
    private func sendCancelOrder(orderID: String, completion: @escaping (Bool?) -> Void) {
        let url = URL(string: "https://bringers-nodejs.vercel.app/cancel-order")!

        getOrderPaymentIntent(orderID: orderID) { _ in
            
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
    
    private func getOrderPaymentIntent(orderID: String, completion: @escaping (Bool?) -> Void) {
        let ref = Database.database().reference()
        
        ref.child("activeOrders").child(orderID).observeSingleEvent(of: .value, with: { (snapshot) in
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
            // TODO: show alert restricted (likely parental controls)
            print("ass res")
        case .denied:
            // TODO: show alert denied (go settings and change)
            print("ass denied")
        case .authorizedAlways, .authorizedWhenInUse:
            guard let location = locationManager.location else {
                break
            }
            region = MKCoordinateRegion(center: location.coordinate,
                                        span: MapDetails.defaultSpan)
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
}
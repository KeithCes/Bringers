//
//  OrderComingMapViewModel.swift
//  Bringers
//
//  Created by Keith C on 3/26/22.
//

import Foundation
import SwiftUI
import MapKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

final class OrderComingMapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var isShowingReceipt = false
    @Published var isShowingUserProfile = false
    
    @Published var isShowingOrderCompleted = false
    
    @Published var receiptInputImage: UIImage?
    @Published var receiptImage: Image = Image("placeholder")
    
    @Published var profileInputImage: UIImage?
    @Published var profileImage: Image = Image("placeholder")
    @Published var profileImageUploaded: Bool = false
    
    @Published var bringerInfo: UserInfoModel = UserInfoModel()
    
    @Published var paymentIntentID: String = ""
    
    @Published var timer: Timer?
    
    @Published var isShowingOrderComing: Bool = true
    @Published var isOrderCancelledMap: Bool = false
    
    @Published var newRating: CGFloat = 0
    
    @Published var bringerLocation: CLLocationCoordinate2D = DefaultCoords.coords
    @Published var bringerAnotations: [AnnotatedItem] = [AnnotatedItem(name: "bringerLocation", coordinate: DefaultCoords.coords)]
    
    @Published var region = MKCoordinateRegion(center: DefaultCoords.coords, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
    
    private var locationManager: CLLocationManager?
    private var startTime: Date?
    
    
    func checkOrderCancelled(orderID: String) {
        let ref = Database.database().reference()
        
        ref.child("activeOrders").child(orderID).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshotDict = (snapshot.value as? NSDictionary) else {
                self.orderEnded(orderID: orderID)
                return
            }
            
            guard let _ = snapshotDict["id"] else {
                self.orderEnded(orderID: orderID)
                return
            }
            
            if snapshot.value == nil {
                self.orderEnded(orderID: orderID)
            }
        })
    }
    
    func orderEnded(orderID: String) {
        let userID = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        
        ref.child("activeOrders").child(orderID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // removes from active
            ref.child("activeOrders").child(orderID).removeValue()
            
            self.timer?.invalidate()
            
            // checks if order completed
            DispatchQueue.main.async {
                ref.child("users").child(userID).child("pastOrders").child(orderID).observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let snapshotDict = (snapshot.value as? NSDictionary) else {
                        return
                    }
                    guard let orderStatus = snapshotDict["status"] as? String else {
                        return
                    }
                    
                    if orderStatus == "completed" {
                        self.isShowingOrderCompleted = true
                    }
                    else {
                        self.timer?.invalidate()
                        self.isShowingOrderComing = false
                        self.isOrderCancelledMap = true
                    }
                })
            }
        })
    }
    
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
                
                // adds to past FOR BRINGER
                let bringerID = (snapshot.value as! [AnyHashable : Any])["bringerID"] as! String
                ref.child("users").child(bringerID).child("pastBringers").child(orderID).updateChildValues(snapshot.value as! [AnyHashable : Any])
                
                // sets date completed
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/YYYY"
                let currentDateString = dateFormatter.string(from: Date())
                
                ref.child("users").child(userID).child("pastOrders").child(orderID).updateChildValues(["dateCompleted" : currentDateString])
                ref.child("users").child(bringerID).child("pastBringers").child(orderID).updateChildValues(["dateCompleted" : currentDateString])
                
                // sets order cancelled
                ref.child("users").child(userID).child("pastOrders").child(orderID).updateChildValues(["status" : "cancelled"])
                ref.child("users").child(bringerID).child("pastBringers").child(orderID).updateChildValues(["status" : "cancelled"])
                
                
                // removes from active
                ref.child("activeOrders").child(orderID).removeValue()
                ref.child("users").child(bringerID).child("activeBringers").removeValue()
                ref.child("users").child(userID).child("activeOrders").removeValue()
                
                self.timer?.invalidate()
                self.isShowingOrderComing = false
                self.isOrderCancelledMap = true
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
    
    func getBringerLocation(orderID: String) {
        let ref = Database.database().reference()
        ref.child("activeOrders").child(orderID).child("bringerLocation").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshotCoords = snapshot.value as? NSArray else {
                self.orderEnded(orderID: orderID)
                return
            }
            let bringerLat = snapshotCoords[0] as! CGFloat
            let bringerLong = snapshotCoords[1] as! CGFloat
            
            self.bringerLocation = CLLocationCoordinate2D(latitude: bringerLat, longitude: bringerLong)
            let newAnnotation = AnnotatedItem(name: "bringerLocation", coordinate: self.bringerLocation)
            self.bringerAnotations = [newAnnotation]
            
            let positions = [self.bringerLocation, self.getLocation()?.location?.coordinate ?? DefaultCoords.coords]
            
            var minLat = 91.0
            var maxLat = -91.0
            var minLon = 181.0
            var maxLon = -181.0
            
            for i in positions {
                maxLat = max(maxLat, i.latitude)
                minLat = min(minLat, i.latitude)
                maxLon = max(maxLon, i.longitude)
                minLon = min(minLon, i.longitude)
            }
            
            let center = CLLocationCoordinate2D(latitude: (maxLat + minLat) / 2,
                                                longitude: (maxLon + minLon) / 2)
            
            let span = MKCoordinateSpan(latitudeDelta: abs(maxLat - minLat) * 1.3,
                                        longitudeDelta: abs(maxLon - minLon) * 1.3)
            
            self.region.span = span
            self.region.center = center
        })
    }
    
    func getReceipt(orderID: String) {
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let receiptRef = storageRef.child("orderReceipts/" + orderID + "/" + "receipt.png")
        
        receiptRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let _ = error {
                // error occurred
            } else {
                self.receiptInputImage = UIImage(data: data!)
                
                guard let inputImage = self.receiptInputImage else { return }
                self.receiptImage = Image(uiImage: inputImage)
            }
        }
    }
    
    func getProfilePicture(bringerID: String) {
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let profilePictureRef = storageRef.child("profilePictures/" + bringerID + "/" + "profilePicture.png")
        
        profilePictureRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let _ = error {
                // error occurred
            } else {
                self.profileInputImage = UIImage(data: data!)
                
                guard let inputImage = self.profileInputImage else { return }
                self.profileImage = Image(uiImage: inputImage)
            }
        }
    }
    
    func getBringerInfo(orderID: String) {
        let ref = Database.database().reference()
        
        ref.child("activeOrders").child(orderID).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshotDict = (snapshot.value as? NSDictionary),
                  let bringerID = snapshotDict["bringerID"] as? String else {
                      return
                  }
            ref.child("users").child(bringerID).child("userInfo").observeSingleEvent(of: .value, with: { (snapshotUserDetails) in
                guard let activeUserInfo = snapshotUserDetails.value as? NSDictionary else {
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
                
                self.bringerInfo = userInfo
                
                self.getProfilePicture(bringerID: bringerID)
            })
        })
    }
    
    func sendCancelOrder(orderID: String, completion: @escaping (Bool?) -> Void) {
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
    
    func getOrderPaymentIntent(orderID: String, completion: @escaping (Bool?) -> Void) {
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
    
    func sendRating(orderID: String, bringerRating: CGFloat, bringerTotalRatings: CGFloat) {
        
        let userID = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        
        ref.child("users").child(userID).child("pastOrders").child(orderID).child("bringerID").observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let bringerID = snapshot.value as? String else {
                return
            }
            
            let calcRating = ((bringerRating * bringerTotalRatings) + self.newRating) / (bringerTotalRatings + 1)
            
            ref.child("users").child(bringerID).child("userInfo").updateChildValues(["rating" : calcRating])
            ref.child("users").child(bringerID).child("userInfo").updateChildValues(["totalRatings" : bringerTotalRatings + 1])
            
            self.isShowingOrderCompleted.toggle()
        })
    }
}

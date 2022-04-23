//
//  BringerOrderMapViewModel.swift
//  Bringers
//
//  Created by Keith C on 3/27/22.
//

import Foundation
import SwiftUI
import MapKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

final class BringerOrderMapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var isShowingUserProfile = false
    @Published var isShowingInstructions = false
    @Published var isShowingImagePicker = false
    @Published var receiptInputImage: UIImage?
    @Published var receiptImage: Image = Image("placeholder")
    @Published var receiptImageUploaded: Bool = false
    
    @Published var isShowingBringerCompleteConfirmation: Bool = false
    @Published var isOrderSuccessfullyCompleted: Bool = false
    
    @Published var profileInputImage: UIImage?
    @Published var profileImage: Image = Image("placeholder")
    @Published var profileImageUploaded: Bool = false
    
    @Published var ordererInfo: UserInfoModel = UserInfoModel()
    
    @Published var chargeID: String = ""
    
    @Published var timer: Timer?
    
    @Published var isShowingToast: Bool = false
    @Published var toastMessage: String = "Error"
    
    @Published var isShowingBringerMap: Bool = true
    @Published var isOrderCancelledMap: Bool = false
    
    @Published var orderLocation: CLLocationCoordinate2D = DefaultCoords.coords
    @Published var orderAnotations: [AnnotatedItem] = [AnnotatedItem(name: "orderLocation", coordinate: DefaultCoords.coords)]
    
    @Published var region = MKCoordinateRegion(center: DefaultCoords.coords, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
    
    private var locationManager: CLLocationManager?
    private var startTime: Date?
    
    
    func checkOrderCancelled(orderID: String) {
        let ref = Database.database().reference()
        ref.child("activeOrders").child(orderID).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshotDict = (snapshot.value as? NSDictionary) else {
                self.orderCancelled(orderID: orderID)
                return
            }
            
            guard let _ = snapshotDict["id"] else {
                self.orderCancelled(orderID: orderID)
                return
            }
            
            if snapshot.value == nil {
                self.orderCancelled(orderID: orderID)
            }
        })
    }
    
    func orderCancelled(orderID: String) {
        let ref = Database.database().reference()
        
        ref.child("activeOrders").child(orderID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // removes from active
            ref.child("activeOrders").child(orderID).removeValue()
            
            self.timer?.invalidate()
            self.isShowingBringerMap = false
            self.isOrderCancelledMap = true
        })
    }
    
    func deactivateOrder(orderID: String, isCompleted: Bool = false) {
        let userID = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        
        sendCancelOrder(orderID: orderID, isCompleted: isCompleted) { success in
            guard let success = success, success == true else {
                self.toastMessage = "Error canceling order"
                self.isShowingToast.toggle()
                return
            }
            
            // moves order from active to past, closes view
            ref.child("activeOrders").child(orderID).observeSingleEvent(of: .value, with: { (snapshot) in
                
                // adds to past FOR ORDER
                let ordererID = (snapshot.value as! [AnyHashable : Any])["userID"] as! String
                ref.child("users").child(ordererID).child("pastOrders").child(orderID).updateChildValues(snapshot.value as! [AnyHashable : Any])
                
                // adds to past
                ref.child("users").child(userID).child("pastBringers").child(orderID).updateChildValues(snapshot.value as! [AnyHashable : Any])
                
                // sets date completed
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/YYYY"
                let currentDateString = dateFormatter.string(from: Date())
                
                ref.child("users").child(ordererID).child("pastOrders").child(orderID).updateChildValues(["dateCompleted" : currentDateString])
                ref.child("users").child(userID).child("pastBringers").child(orderID).updateChildValues(["dateCompleted" : currentDateString])
                
                // sets order completed/cancelled
                let status = isCompleted ? "completed" : "cancelled"
                ref.child("users").child(ordererID).child("pastOrders").child(orderID).updateChildValues(["status" : status])
                ref.child("users").child(userID).child("pastBringers").child(orderID).updateChildValues(["status" : status])
                
                
                // removes from active
                ref.child("activeOrders").child(orderID).removeValue()
                ref.child("users").child(userID).child("activeBringers").removeValue()
                ref.child("users").child(ordererID).child("activeOrders").removeValue()
                
                self.timer?.invalidate()
                self.isShowingBringerMap = false
            })
        }
    }
    
    func sendBringerLocation(orderID: String) {
        let ref = Database.database().reference()
        guard let locationManager = self.getLocation() else {
            return
        }
        ref.child("activeOrders").child(orderID).updateChildValues(["bringerLocation":[locationManager.location?.coordinate.latitude, locationManager.location?.coordinate.longitude]])
    }
    
    func getOrderLocation(orderID: String) {
        let ref = Database.database().reference()
        ref.child("activeOrders").child(orderID).child("location").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshotCoords = snapshot.value as? NSArray else {
                self.orderCancelled(orderID: orderID)
                return
            }
            let bringerLat = snapshotCoords[0] as! CGFloat
            let bringerLong = snapshotCoords[1] as! CGFloat
            
            self.orderLocation = CLLocationCoordinate2D(latitude: bringerLat, longitude: bringerLong)
            let newAnnotation = AnnotatedItem(name: "orderLocation", coordinate: self.orderLocation)
            self.orderAnotations = [newAnnotation]
            
            let positions = [self.orderLocation, self.getLocation()?.location?.coordinate ?? DefaultCoords.coords]
            
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
    
    func uploadReceipt(orderID: String) {
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let receiptRef = storageRef.child("orderReceipts/" + orderID + "/" + "receipt.png")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        guard let data: Data = self.receiptInputImage?.jpegData(compressionQuality: 0.20) else {
            return
        }
        
        receiptRef.putData(data, metadata: nil) { (metadata, error) in
            guard let _ = metadata else {
                // error occurred
                return
            }
            self.receiptImageUploaded = true
        }
    }
    
    func loadImage() {
        guard let inputImage = receiptInputImage else { return }
        self.receiptImage = Image(uiImage: inputImage)
    }
    
    func getProfilePicture(userID: String) {
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let profilePictureRef = storageRef.child("profilePictures/" + userID + "/" + "profilePicture.png")
        
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
    
    func getOrdererDetails(userID: String) {
        
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
            
            self.ordererInfo = userInfo
        })
        
        self.getProfilePicture(userID: userID)
    }
    
    func sendCancelOrder(orderID: String, isCompleted: Bool, completion: @escaping (Bool?) -> Void) {
        let url = URL(string: "https://bringers-nodejs.vercel.app/cancel-order")!

        if isCompleted {
            completion(true)
            return
        }
        getOrderChargeID(orderID: orderID) { _ in
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try! JSONEncoder().encode([
                "chargeID" : self.chargeID,
            ])
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let _ = data, error == nil,
                      (response as? HTTPURLResponse)?.statusCode == 200 else {
                          completion(nil)
                          return
                      }
                DispatchQueue.main.async {
                    self.isOrderCancelledMap = true
                }
                completion(true)
            }.resume()
        }
    }
    
    func getOrderChargeID(orderID: String, completion: @escaping (Bool?) -> Void) {
        let ref = Database.database().reference()
        
        ref.child("activeOrders").child(orderID).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let activeUser = (snapshot.value as? [AnyHashable : Any]) else {
                completion(nil)
                return
            }
            
            guard let chargeID = (activeUser["chargeID"] as? String) else {
                completion(nil)
                return
            }

            self.chargeID = chargeID
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
    
    func getLocation() -> CLLocationManager? {
        return self.locationManager
    }
}

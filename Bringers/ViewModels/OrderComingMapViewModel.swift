//
//  OrderComingMapViewModel.swift
//  Bringers
//
//  Created by Keith C on 12/24/21.
//

import Foundation
import MapKit
import FirebaseAuth
import FirebaseDatabase

enum MapDetails {
    static let defaultCoords = CLLocationCoordinate2D(latitude: 37.334388, longitude: -122.009015)
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
}

final class OrderComingMapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    private var startTime: Date?
    
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
            region = MKCoordinateRegion(center: location.coordinate,
                                        span: MapDetails.defaultSpan)
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    // sends updated user location coords to database
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let loc = locations.last else { return }

        let time = loc.timestamp

        guard var startTime = startTime else {
            self.startTime = time
            return
        }

        let elapsed = time.timeIntervalSince(startTime)

        // update interval
        if elapsed > 1 {
            
            let userID = Auth.auth().currentUser!.uid
            let ref = Database.database().reference()
            
            ref.child("users").child(userID).child("activeOrders").child(orderID).updateChildValues(["location":[locationManager?.location?.coordinate.latitude, locationManager?.location?.coordinate.longitude]])

            startTime = time

        }
    }
    
    func setOrderID(id: String) {
        orderID = id
    }

}

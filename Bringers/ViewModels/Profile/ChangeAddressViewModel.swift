//
//  ChangeAddressViewModel.swift
//  Bringers
//
//  Created by Keith C on 3/24/22.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseDatabase

final class ChangeAddressViewModel: ObservableObject {
    
    @Published var address: String = ""
    @Published var city: String = ""
    @Published var zipcode: String = ""
    @Published var state: String = ""
    @Published var country: String = ""
    
    @Published var countryColor: SwiftUI.Color = CustomColors.midGray.opacity(0.5)
    @Published var stateColor: SwiftUI.Color = CustomColors.midGray.opacity(0.5)
    
    
    func updateUserValue(userInfo: UserInfoModel) {
        let ref = Database.database().reference()
        let userID = Auth.auth().currentUser!.uid
        
        self.updateUserValueStripe(userInfo: userInfo) { _ in
            ref.child("users").child(userID).child("userInfo").updateChildValues([
                "address" : self.address != "" ? self.address : userInfo.address,
                "state" : self.state != "" ? self.state : userInfo.state,
                "city" : self.city != "" ? self.city : userInfo.city,
                "zipcode" : self.zipcode != "" ? self.zipcode : userInfo.zipcode,
                "country" : self.country != "" ? self.country : userInfo.country,
            ])
        }
    }
    
    private func updateUserValueStripe(userInfo: UserInfoModel, completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://bringers-nodejs.vercel.app/update-customer-address")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode([
            "customerID" : userInfo.stripeCustomerID,
            "addressLine1" : self.address != "" ? self.address : userInfo.address,
            "addressCity" : self.city != "" ? self.city : userInfo.city,
            "addressCountry" : self.country != "" ? self.country : userInfo.country,
            "addressState": self.state != "" ? self.state : userInfo.state,
            "addressPostalCode" : self.zipcode != "" ? self.zipcode : userInfo.zipcode,
        ])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil,
                  (response as? HTTPURLResponse)?.statusCode == 200,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                  let customerID = json["customerID"] as? String else {
                      completion(nil)
                      return
                  }
            completion(customerID)
        }.resume()
    }
}

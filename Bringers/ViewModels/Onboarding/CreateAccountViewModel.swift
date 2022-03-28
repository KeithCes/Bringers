//
//  CreateAccountViewModel.swift
//  Bringers
//
//  Created by Keith C on 3/25/22.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseDatabase

final class CreateAccountViewModel: ObservableObject {
    
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var dob: Date = Date()
    @Published var email: String = ""
    @Published var phoneNumber: String = ""
    @Published var address: String = ""
    @Published var city: String = ""
    @Published var zipcode: String = ""
    @Published var state: String = "State"
    @Published var country: String = "Country"
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    @Published var stripeCustomerID: String = ""
    
    @Published var isDobChanged: Bool = false
    
    @Published var isShowingCreate: Bool = true
    
    @Published var countryColor: SwiftUI.Color = CustomColors.midGray.opacity(0.5)
    @Published var stateColor: SwiftUI.Color = CustomColors.midGray.opacity(0.5)
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    
    
    func checkIfCreateInfoValid() -> Bool {
        return firstName.count > 2 && lastName.count > 2 && email.count > 0 && (phoneNumber.count == 10 || phoneNumber.count == 11) && password.count >= 6 && password.count >= 6 && password == confirmPassword && address.count > 5 && city.count > 2 && state.count == 2 && country.count == 2 && zipcode.count == 5
    }
    
    func createAccount() {
        
        // TODO: add toasts to show what error user is facing (password too short, email badly formatted, etc)
        
        if checkIfCreateInfoValid() {
            
            let ref = Database.database().reference()
            
            Auth.auth().createUser(withEmail: email, password: password) { username, error in
                if error == nil && username != nil {
                    
                    let userID = Auth.auth().currentUser!.uid
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/YYYY"
                    let dobString = dateFormatter.string(from: self.dob)
                    let currentDateString = dateFormatter.string(from: Date())
                    
                    let userDetails = [
                        "firstName": self.firstName,
                        "lastName": self.lastName,
                        "dateOfBirth": dobString,
                        "email": self.email,
                        "phoneNumber": self.phoneNumber,
                        "dateOfCreation": currentDateString,
                        "ordersPlaced": 0,
                        "ordersCompleted": 0,
                        "ordersCanceled": 0,
                        "bringersCompleted": 0,
                        "bringersAccepted": 0,
                        "bringersCanceled": 0,
                        "profilePictureURL": "",
                        "rating": 0,
                        "totalRatings": 0,
                        "stripeAccountID": "",
                        "stripeCustomerID": self.stripeCustomerID,
                        "address": self.address,
                        "state": self.state,
                        "city": self.city,
                        "country": self.country,
                        "zipcode": self.zipcode
                    ] as [String : Any]
                    
                    ref.child("users").child(userID).child("userInfo").setValue(userDetails)
                    
                    print("user created")
                    self.isShowingCreate = false
                }
                else {
                    print("error:  \(error!.localizedDescription)")
                }
            }
        }
    }
    
    func createStripeCustomer(completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://bringers-nodejs.vercel.app/onboard-customer")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode([
            "addressLine1" : address,
            "addressCity" : city,
            "addressCountry" : country,
            "addressState": state,
            "addressPostalCode" : zipcode,
            "email" : email,
            "name" : firstName + " " + lastName,
            "phone" : phoneNumber
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

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
    
    @Published var isShowingToast: Bool = false
    @Published var toastMessage: String = "Error"
    
    @Published var countryColor: SwiftUI.Color = CustomColors.midGray.opacity(0.5)
    @Published var stateColor: SwiftUI.Color = CustomColors.midGray.opacity(0.5)
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    
    
    func checkIfCreateInfoValid() -> Bool {
        return firstName.count > 1 && lastName.count > 1 && email.count > 0 && checkValidEmail(email: email) && (phoneNumber.count == 10 || phoneNumber.count == 11) && password.count >= 6 && password.count >= 6 && password == confirmPassword && address.count > 5 && city.count > 2 && state.count == 2 && country.count == 2 && zipcode.count == 5
    }
    
    func checkPostErrorToast() {
        if firstName.count <= 1 {
            self.toastMessage = "Name must be at least 2 characters long"
        }
        else if lastName.count <= 1 {
            self.toastMessage = "Name must be at least 2 characters long"
        }
        else if email.count <= 0 || !checkValidEmail(email: email) {
            self.toastMessage = "Email is not valid"
        }
        else if phoneNumber.count < 10 || phoneNumber.count > 11 {
            self.toastMessage = "Phone Number is not valid"
        }
        else if password.count < 6 {
            self.toastMessage = "Password is too short"
        }
        else if password != confirmPassword {
            self.toastMessage = "Password confirmation must match"
        }
        else if address.count <= 5 {
            self.toastMessage = "Address is not valid"
        }
        else if city.count <= 2 {
            self.toastMessage = "City is not valid"
        }
        else if state.count != 2 {
            self.toastMessage = "State is not valid"
        }
        else if country.count != 2 {
            self.toastMessage = "Country is not valid"
        }
        else if zipcode.count != 5 {
            self.toastMessage = "Zipcode is not valid"
        }
        self.isShowingToast.toggle()
    }
    
    func createAccount() {
        
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
    
    func checkValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

//
//  CreateAccountView.swift
//  Bringers
//
//  Created by Keith C on 1/4/22.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct CreateAccountView: View {
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var dob: Date = Date()
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var address: String = ""
    @State private var city: String = ""
    @State private var zipcode: String = ""
    @State private var state: String = ""
    @State private var country: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var stripeCustomerID: String = ""
    
    @State private var isDobChanged: Bool = false
    
    @Binding var isShowingCreate: Bool
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    
    @ObservedObject private var kGuardian = KeyboardGuardian(textFieldCount: 9)
    @State private var name = Array<String>.init(repeating: "", count: 9)
    
    var body: some View {
        ScrollView {
            VStack {
                CustomTitleText(labelText: "CREATE ACCOUNT")
                    .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
                
                CustomTextbox(field: $firstName, placeholderText: "First Name", onEditingChanged: { if $0 { self.kGuardian.showField = 0 } })
                    .background(GeometryGetter(rect: $kGuardian.rects[0]))
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                CustomTextbox(field: $lastName, placeholderText: "Last Name", onEditingChanged: { if $0 { self.kGuardian.showField = 1 } })
                    .background(GeometryGetter(rect: $kGuardian.rects[1]))
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                
                DatePicker(selection: $dob, in: ...Date(), displayedComponents: .date) {
                    Text("Date of Birth")
                }
                .accentColor(CustomColors.seafoamGreen)
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .colorInvert()
                .colorScheme(.light)
                .colorMultiply(CustomColors.midGray.opacity(isDobChanged ? 1 : 0.5))
                .frame(width: 30, height: 30, alignment: .center)
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                .background(Rectangle()
                                .fill(Color.white.opacity(0.5))
                                .frame(width: CustomDimensions.width, height: 50)
                                .cornerRadius(15))
                .padding(EdgeInsets(top: 0, leading: 50, bottom: 30, trailing: 50))
                .overlay(
                    Text("Date of Birth")
                        .foregroundColor(CustomColors.midGray.opacity(0.5))
                        .font(.system(size: 10, weight: .regular, design: .rounded))
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 65, trailing: 20))
                )
                
                CustomTextbox(field: $email, placeholderText: "Email", charLimit: 30, onEditingChanged: { if $0 { self.kGuardian.showField = 3 } })
                    .background(GeometryGetter(rect: $kGuardian.rects[3]))
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                    .textInputAutocapitalization(.never)
                CustomTextbox(field: $phoneNumber, placeholderText: "Phone Number", onEditingChanged: { if $0 { self.kGuardian.showField = 4 } })
                    .background(GeometryGetter(rect: $kGuardian.rects[4]))
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                    .keyboardType(.numberPad)
                
                // TODO: restrictions on data input to match Stripe Customer creation parameters
                Group {
                    CustomTextbox(field: $address, placeholderText: "Billing Address", onEditingChanged: { if $0 { self.kGuardian.showField = 5 } })
                        .background(GeometryGetter(rect: $kGuardian.rects[5]))
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                    // TODO: state dropdown
                    CustomTextbox(field: $state, placeholderText: "State", onEditingChanged: { if $0 { self.kGuardian.showField = 6 } })
                        .background(GeometryGetter(rect: $kGuardian.rects[6]))
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                    CustomTextbox(field: $city, placeholderText: "City", onEditingChanged: { if $0 { self.kGuardian.showField = 7 } })
                        .background(GeometryGetter(rect: $kGuardian.rects[7]))
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                    CustomTextbox(field: $zipcode, placeholderText: "Zipcode", onEditingChanged: { if $0 { self.kGuardian.showField = 7 } })
                        .background(GeometryGetter(rect: $kGuardian.rects[7]))
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                    // TODO: country dropdown
                    CustomTextbox(field: $country, placeholderText: "Country", onEditingChanged: { if $0 { self.kGuardian.showField = 8 } })
                        .background(GeometryGetter(rect: $kGuardian.rects[8]))
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                }
                
                CustomSecureTextbox(field: $password, placeholderText: "Password")
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                CustomSecureTextbox(field: $confirmPassword, placeholderText: "Confirm Password")
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                    .submitLabel(.done)
                    .onSubmit {
                        createAccount()
                    }
                
                Button("CREATE") {
                    if checkIfCreateInfoValid() {
                        
                        createStripeCustomer { customerID in
                            guard let stripeCustomerID = customerID else {
                                return
                            }
                            self.stripeCustomerID = stripeCustomerID
                            createAccount()
                        }
                    }
                }
                .padding(EdgeInsets(top: 35, leading: 20, bottom: 35, trailing: 20))
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(Color.white)
                .background(Rectangle()
                                .fill(CustomColors.blueGray.opacity(0.6))
                                .frame(width: CustomDimensions.width, height: 70)
                                .cornerRadius(15))
            }
            .onChange(of: dob, perform: { _ in
                isDobChanged = dob != Date()
            })
            .onAppear { self.kGuardian.addObserver() }
            .onDisappear { self.kGuardian.removeObserver() }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(CustomColors.seafoamGreen)
            .ignoresSafeArea()
        }
        .background(CustomColors.seafoamGreen)
    }
    
    func checkIfCreateInfoValid() -> Bool {
        return firstName.count > 2 && lastName.count > 2 && email.count > 0 && (phoneNumber.count == 10 || phoneNumber.count == 11) && password.count >= 6 && password.count >= 6 && password == confirmPassword && address.count > 5 && city.count > 2 && state.count > 1 && country.count > 1
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
                    let dobString = dateFormatter.string(from: dob)
                    let currentDateString = dateFormatter.string(from: Date())
                    
                    let userDetails = [
                        "firstName": firstName,
                        "lastName": lastName,
                        "dateOfBirth": dobString,
                        "email": email,
                        "phoneNumber": phoneNumber,
                        "dateOfCreation": currentDateString,
                        "ordersPlaced": 0,
                        "ordersCompleted": 0,
                        "profilePictureURL": "",
                        "rating": 0,
                        "stripeAccountID": "",
                        "stripeCustomerID": stripeCustomerID,
                        "address": address,
                        "state": state,
                        "city": city,
                        "country": country,
                        "zipcode": zipcode
                    ] as [String : Any]
                    
                    ref.child("users").child(userID).child("userInfo").setValue(userDetails)
                    
                    print("user created")
                    isShowingCreate.toggle()
                }
                else {
                    print("error:  \(error!.localizedDescription)")
                }
            }
        }
    }
    
    private func createStripeCustomer(completion: @escaping (String?) -> Void) {
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

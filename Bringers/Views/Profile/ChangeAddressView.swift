//
//  ChangeAddressView.swift
//  Bringers
//
//  Created by Keith C on 3/21/22.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import Combine

struct ChangeAddressView: View {
    
    @Binding var userInfo: UserInfoModel
    
    @State private var address: String = ""
    @State private var city: String = ""
    @State private var zipcode: String = ""
    @State private var state: String = ""
    @State private var country: String = ""
    
    @State private var countryColor: SwiftUI.Color = CustomColors.midGray.opacity(0.5)
    @State private var stateColor: SwiftUI.Color = CustomColors.midGray.opacity(0.5)
    var stateCodes = ["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC",
                          "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA",
                          "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE",
                          "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC",
                          "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"]
    
    var body: some View {
        VStack {
            CustomTitleText(labelText: "CHANGE ADDRESS")
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
            
            VStack {
                CustomTextbox(field: $address, placeholderText: self.userInfo.address)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 21, trailing: 20))
                    .submitLabel(.done)
                    .onSubmit {
                        if address.count > 5 {
                            updateUserValue()
                        }
                        else {
                            // TODO: error toast invalid
                        }
                    }
                
                // state
                Menu {
                    ForEach(self.stateCodes.reversed(), id: \.self) { state in
                        Button {
                            self.state = state
                            self.stateColor = CustomColors.midGray
                            updateUserValue()
                        } label: {
                            Text(state)
                        }
                    }
                } label: {
                    Text(self.state != "" ? self.state : self.userInfo.state)
                }
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(self.stateColor)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .background(Rectangle()
                                .fill(Color.white.opacity(0.5))
                                .frame(width: CustomDimensions.width, height: 50)
                                .cornerRadius(15))
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 21, trailing: 20))
                
                CustomTextbox(field: $city, placeholderText: self.userInfo.city)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 21, trailing: 20))
                    .onSubmit {
                        if city.count > 2 {
                            updateUserValue()
                        }
                        else {
                            // TODO: error toast invalid
                        }
                    }
                CustomTextbox(field: $zipcode, placeholderText: self.userInfo.zipcode, charLimit: 5)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 21, trailing: 20))
                    .onReceive(Just(zipcode)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            self.zipcode = filtered
                        }
                    }
                    .submitLabel(.done)
                    .onSubmit {
                        if zipcode.count == 5 {
                            updateUserValue()
                        }
                        else {
                            // TODO: error toast invalid
                        }
                    }
                
                // country
                Menu {
                    Button {
                        self.country = self.userInfo.country
                        self.countryColor = CustomColors.midGray
                        updateUserValue()
                    } label: {
                        Text("US")
                    }
                    
                } label: {
                    Text(self.country != "" ? self.country : self.userInfo.country)
                }
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(self.countryColor)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .background(Rectangle()
                                .fill(Color.white.opacity(0.5))
                                .frame(width: CustomDimensions.width, height: 50)
                                .cornerRadius(15))
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            }
            .background(Rectangle()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: CustomDimensions.width, height: CustomDimensions.height300)
                            .cornerRadius(15))
            .padding(EdgeInsets(top: 75, leading: 0, bottom: 0, trailing: 0))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 150, trailing: 0))
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
    }
    
    private func updateUserValue() {
        let ref = Database.database().reference()
        let userID = Auth.auth().currentUser!.uid
        
        updateUserValueStripe { _ in
            ref.child("users").child(userID).child("userInfo").updateChildValues([
                "address" : self.address != "" ? self.address : self.userInfo.address,
                "state" : self.state != "" ? self.state : self.userInfo.state,
                "city" : self.city != "" ? self.city : self.userInfo.city,
                "zipcode" : self.zipcode != "" ? self.zipcode : self.userInfo.zipcode,
                "country" : self.country != "" ? self.country : self.userInfo.country,
            ])
        }
    }
    
    private func updateUserValueStripe(completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://bringers-nodejs.vercel.app/update-customer-address")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode([
            "customerID" : self.userInfo.stripeCustomerID,
            "addressLine1" : self.address != "" ? self.address : self.userInfo.address,
            "addressCity" : self.city != "" ? self.city : self.userInfo.city,
            "addressCountry" : self.country != "" ? self.country : self.userInfo.country,
            "addressState": self.state != "" ? self.state : self.userInfo.state,
            "addressPostalCode" : self.zipcode != "" ? self.zipcode : self.userInfo.zipcode,
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



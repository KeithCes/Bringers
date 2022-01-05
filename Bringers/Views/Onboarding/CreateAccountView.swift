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
    @State private var dob: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @Binding private var isShowingCreate: Bool
    
    @ObservedObject private var kGuardian = KeyboardGuardian(textFieldCount: 5)
    @State private var name = Array<String>.init(repeating: "", count: 5)
    
    init(isShowingCreate: Binding<Bool>) {
        self._isShowingCreate = isShowingCreate
    }
    
    var body: some View {
        VStack {
            CustomTitleText(labelText: "CREATE ACCOUNT")
            
            CustomTextbox(field: $firstName, placeholderText: "First Name", onEditingChanged: { if $0 { self.kGuardian.showField = 0 } })
                .background(GeometryGetter(rect: $kGuardian.rects[0]))
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
            CustomTextbox(field: $lastName, placeholderText: "Last Name", onEditingChanged: { if $0 { self.kGuardian.showField = 1 } })
                .background(GeometryGetter(rect: $kGuardian.rects[1]))
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
            CustomTextbox(field: $dob, placeholderText: "Date of Birth", onEditingChanged: { if $0 { self.kGuardian.showField = 2 } })
                .background(GeometryGetter(rect: $kGuardian.rects[2]))
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
            CustomTextbox(field: $email, placeholderText: "Email", onEditingChanged: { if $0 { self.kGuardian.showField = 3 } })
                .background(GeometryGetter(rect: $kGuardian.rects[3]))
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                .textInputAutocapitalization(.never)
            CustomTextbox(field: $phoneNumber, placeholderText: "Phone Number", onEditingChanged: { if $0 { self.kGuardian.showField = 4 } })
                .background(GeometryGetter(rect: $kGuardian.rects[4]))
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                .keyboardType(.numberPad)
            CustomSecureTextbox(field: $password, placeholderText: "Password")
                .background(GeometryGetter(rect: $kGuardian.rects[0]))
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
            CustomSecureTextbox(field: $confirmPassword, placeholderText: "Confirm Password")
                .background(GeometryGetter(rect: $kGuardian.rects[0]))
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                .submitLabel(.done)
                .onSubmit {
                    createAccount()
                }
            
            Button("CREATE") {
                createAccount()
            }
            .padding(EdgeInsets(top: 35, leading: 20, bottom: 35, trailing: 20))
            .font(.system(size: 30, weight: .bold, design: .rounded))
            .foregroundColor(Color.white)
            .background(Rectangle()
                            .fill(CustomColors.blueGray.opacity(0.6))
                            .frame(width: CustomDimensions.width, height: 70)
                            .cornerRadius(15))
        }
        .onAppear { self.kGuardian.addObserver() }
        .onDisappear { self.kGuardian.removeObserver() }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
    }
    
    func createAccount() {
        
        // TODO: add toasts to show what error user is facing (password too short, email badly formatted, etc)
        
        if firstName.count > 2 && lastName.count > 2 && dob.count > 0 && email.count > 0 && (phoneNumber.count == 10 || phoneNumber.count == 11) && password.count > 6 && password.count > 6 && password == confirmPassword {
            
            let ref = Database.database().reference()
            
            Auth.auth().createUser(withEmail: email, password: password) { username, error in
                if error == nil && username != nil {
                    
                    let userID = Auth.auth().currentUser!.uid
                    let userDetails = ["email": email, "username": email]
                    ref.child("users").child(userID).setValue(userDetails)
                    
                    ref.child("users").child(userID).child("preferences").observeSingleEvent(of: .value, with: { (snapshot) in
                        let value = snapshot.value as? NSDictionary
                        if value == nil {
                            ref.child("users").child(userID).child("preferences")
                        }
                    })
                    
                    print("user created")
                    isShowingCreate.toggle()
                }
                else {
                    print("error:  \(error!.localizedDescription)")
                }
            }
        }
    }
}

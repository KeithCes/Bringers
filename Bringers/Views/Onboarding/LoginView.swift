//
//  LoginView.swift
//  Bringers
//
//  Created by Keith C on 1/4/22.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct LoginView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    @Binding private var isShowingLogin: Bool
    
    @ObservedObject private var kGuardian = KeyboardGuardian(textFieldCount: 1)
    @State private var name = Array<String>.init(repeating: "", count: 1)
    
    init(isShowingLogin: Binding<Bool>) {
        self._isShowingLogin = isShowingLogin
    }
    
    var body: some View {
        VStack {
            CustomTitleText(labelText: "LOGIN")
            CustomTextbox(field: $email, placeholderText: "Email", onEditingChanged: { if $0 { self.kGuardian.showField = 0 } })
                .background(GeometryGetter(rect: $kGuardian.rects[0]))
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                .textInputAutocapitalization(.never)
            CustomSecureTextbox(field: $password, placeholderText: "Password")
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                .submitLabel(.done)
                .onSubmit {
                    login()
                }
            Button("LOGIN") {
                login()
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
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                isShowingLogin.toggle()
            }
        }
    }
}

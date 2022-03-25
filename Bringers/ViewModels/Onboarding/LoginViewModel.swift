//
//  LoginViewModel.swift
//  Bringers
//
//  Created by Keith C on 3/25/22.
//

import Foundation
import FirebaseAuth

final class LoginViewModel: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    @Published var isShowingLogin: Bool = true
    
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
            } else {
                self.isShowingLogin = false
            }
        }
    }
}

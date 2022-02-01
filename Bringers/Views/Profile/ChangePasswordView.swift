//
//  ChangePasswordView.swift
//  Bringers
//
//  Created by Keith C on 12/25/21.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct ChangePasswordView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    
    @FocusState private var isNewPasswordFocused: Bool
    @FocusState private var isConfirmPasswordFocused: Bool
    
    private var oldPassword: String = "******"
    
    @ObservedObject private var keyboard = KeyboardResponder()
    
    var body: some View {
        VStack {
            CustomTitleText(labelText: "CHANGE PASSWORD")
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
            
            VStack {
                CustomSecureTextboxTitleText(field: $newPassword, placeholderText: "-", titleText: "NEW PASSWORD")
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 21, trailing: 20))
                    .focused($isNewPasswordFocused)
                    .submitLabel(.next)
                    .onSubmit {
                        isConfirmPasswordFocused.toggle()
                    }
                
                CustomSecureTextboxTitleText(field: $confirmPassword, placeholderText: "-", titleText: "CONFIRM PASSWORD")
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    .focused($isConfirmPasswordFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        if newPassword == confirmPassword {
                            Auth.auth().currentUser?.updatePassword(to: confirmPassword) { error in
                                if error != nil {
                                    // TODO: display toast if error
                                    print(error?.localizedDescription ?? "")
                                }
                                else {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
            }
            .background(Rectangle()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: CustomDimensions.width, height: CustomDimensions.height200)
                            .cornerRadius(15))
            .padding(EdgeInsets(top: 100, leading: 0, bottom: 0, trailing: 0))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 250, trailing: 0))
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
    }
}

//
//  ChangePasswordView.swift
//  Bringers
//
//  Created by Keith C on 12/25/21.
//

import Foundation
import SwiftUI

struct ChangePasswordView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    
    @FocusState private var isCurrentPasswordFocused: Bool
    @FocusState private var isNewPasswordFocused: Bool
    @FocusState private var isConfirmPasswordFocused: Bool
    
    private var oldPassword: String = "******"
    
    @ObservedObject private var keyboard = KeyboardResponder()
    
    var body: some View {
        VStack {
            Text("CHANGE PASSWORD:")
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(CustomColors.midGray)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
            
            CustomSecureTextbox(field: $currentPassword, placeholderText: oldPassword, titleText: "CURRENT PASSWORD")
                .padding(EdgeInsets(top: 20, leading: 20, bottom: 21, trailing: 20))
                .focused($isCurrentPasswordFocused)
                .onAppear {
                    // delay before keyboard can pop up; shorter timer doesn't appear at all
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.7) {
                        isCurrentPasswordFocused.toggle()
                    }
                }
                .submitLabel(.next)
                .onSubmit {
                    isNewPasswordFocused.toggle()
                }
            
            
            CustomSecureTextbox(field: $newPassword, placeholderText: "-", titleText: "NEW PASSWORD")
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 21, trailing: 20))
                .focused($isNewPasswordFocused)
                .submitLabel(.next)
                .onSubmit {
                    isConfirmPasswordFocused.toggle()
                }
            
            CustomSecureTextbox(field: $confirmPassword, placeholderText: "-", titleText: "CONFIRM PASSWORD")
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 21, trailing: 20))
                .focused($isConfirmPasswordFocused)
                .submitLabel(.done)
                .onSubmit {
                    // TODO: send change password request to backend before dismissing view
                    presentationMode.wrappedValue.dismiss()
                }
        }
        .background(Rectangle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: CustomDimensions.width, height: CustomDimensions.height300)
                        .cornerRadius(15))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 250, trailing: 0))
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
    }
}

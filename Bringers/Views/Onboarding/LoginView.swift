//
//  LoginView.swift
//  Bringers
//
//  Created by Keith C on 1/4/22.
//

import Foundation
import SwiftUI

struct LoginView: View {
    
    @StateObject private var viewModel = LoginViewModel()
    
    @Binding var isShowingLogin: Bool
    
    
    var body: some View {
        VStack {
            CustomTitleText(labelText: "LOGIN")
            
            CustomTextbox(field: $viewModel.email, placeholderText: "Email")
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                .textInputAutocapitalization(.never)
            
            CustomSecureTextbox(field: $viewModel.password, placeholderText: "Password")
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                .submitLabel(.done)
                .onSubmit {
                    viewModel.login()
                }
            
            Button("LOGIN") {
                viewModel.login()
            }
            .padding(EdgeInsets(top: 35, leading: 20, bottom: 35, trailing: 20))
            .font(.system(size: 30, weight: .bold, design: .rounded))
            .foregroundColor(Color.white)
            .background(Rectangle()
                            .fill(CustomColors.blueGray.opacity(0.6))
                            .frame(width: CustomDimensions.width, height: 70)
                            .cornerRadius(15))
        }
        .toast(message: viewModel.toastMessage,
               isShowing: $viewModel.isShowingToast,
               duration: Toast.long
        )
        .onChange(of: viewModel.isShowingLogin, perform: { _ in
            self.isShowingLogin.toggle()
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
    }
}

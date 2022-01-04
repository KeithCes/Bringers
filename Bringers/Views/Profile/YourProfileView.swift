//
//  YourProfileView.swift
//  Bringers
//
//  Created by Keith C on 12/25/21.
//

import Foundation
import SwiftUI

struct YourProfileView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var firstname: String = ""
    @State private var lastname: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var savedCreditCard: String = ""
    
    @State private var isShowingChangePassword: Bool = false
    
    private var rating: CGFloat = 3.8
    
    @ObservedObject private var keyboard = KeyboardResponder()
    private var keyboardHeight: CGFloat = 0
    
    init() {
        keyboardHeight = keyboard.currentHeight
    }
    
    var body: some View {
        VStack {
            ZStack {
                Image("scarra")
                    .resizable()
                    .frame(width: 186, height: 186)
                    .cornerRadius(15)
                    .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
                
                Button(action: {
                    // TODO: add iOS native image upload and push image to backend (backend)
                }) {
                    Image(systemName: "pencil")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundColor(CustomColors.darkGray)
                        .background(Rectangle()
                                        .fill(Color.white.opacity(0.5))
                                        .frame(width: 31, height: 31)
                                        .cornerRadius(15))
                }
                .padding(EdgeInsets(top: 190, leading: 190, bottom: 0, trailing: 20))
                
                Button(action: {
                    isShowingChangePassword.toggle()
                }) {
                    Image(systemName: "key.fill")
                        .resizable()
                        .frame(width: 12, height: 22)
                        .foregroundColor(CustomColors.darkGray)
                        .background(Rectangle()
                                        .fill(Color.white.opacity(0.5))
                                        .frame(width: 31, height: 31)
                                        .cornerRadius(15))
                }
                .padding(EdgeInsets(top: 0, leading: 250, bottom: 160, trailing: 0))
                .sheet(isPresented: $isShowingChangePassword, content: {
                    ChangePasswordView()
                })
            }
            
            
            CustomTextboxTitleText(field: $firstname, placeholderText: "FIRSTNAME", titleText: "FIRST NAME")
                .padding(EdgeInsets(top: 30, leading: 20, bottom: 20, trailing: 20))
                .submitLabel(.done)
                .onSubmit {
                    // TODO: check valid/update value on backend
                }

            CustomTextboxTitleText(field: $lastname, placeholderText: "LASTNAME", titleText: "LAST NAME")
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                .submitLabel(.done)
                .onSubmit {
                    // TODO: check valid/update value on backend
                }
            
            CustomTextboxTitleText(field: $email, placeholderText: "scarra@dignitas.com", titleText: "EMAIL")
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                .submitLabel(.done)
                .onSubmit {
                    // TODO: check valid/update value on backend
                }
            
            CustomTextboxTitleText(field: $phoneNumber, placeholderText: "860-555-5555", titleText: "PHONE NUMBER")
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                .submitLabel(.done)
                .onSubmit {
                    // TODO: check valid/update value on backend
                }
            
            CustomTextboxTitleText(field: $savedCreditCard, placeholderText: "****-****-****-9420", titleText: "SAVED CREDIT CARD")
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                .submitLabel(.done)
                .onSubmit {
                    // TODO: check valid/update value on backend
                }
            
            
            Text("RATING: " + "\(rating)" + "/5")
                .font(.system(size: 24, weight: .regular, design: .rounded))
                .foregroundColor(CustomColors.midGray)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            RatingView(rating: rating, maxRating: 5)
                .frame(width: 112, height: 16)
        }
        .background(Rectangle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: CustomDimensions.width, height: CustomDimensions.height600)
                        .cornerRadius(15))
        .padding(.bottom, keyboardHeight)
        .edgesIgnoringSafeArea(.bottom)
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(.center)
        .tabItem {
            Image(systemName: "person")
            Text("Profile")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
        .gesture(DragGesture().onChanged{_ in UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)})
    }
}

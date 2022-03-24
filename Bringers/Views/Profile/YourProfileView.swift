//
//  YourProfileView.swift
//  Bringers
//
//  Created by Keith C on 12/25/21.
//

import Foundation
import SwiftUI
import Combine

struct YourProfileView: View {
    
    @StateObject var viewModel = YourProfileViewModel()
    
    @ObservedObject private var keyboard = KeyboardResponder()
    private var keyboardHeight: CGFloat = 0
    
    init() {
        keyboardHeight = keyboard.currentHeight
    }
    
    var body: some View {
        VStack {
            ZStack {
                viewModel.profileImage
                    .resizable()
                    .frame(width: 186, height: 186)
                    .cornerRadius(15)
                    .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
                
                // edit profile picture
                Button(action: {
                    viewModel.isShowingImagePicker.toggle()
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
                
                // logout
                Button(action: {
                    viewModel.logoutUser()
                }) {
                    Image(systemName: "return.left")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundColor(CustomColors.darkGray)
                        .background(Rectangle()
                                        .fill(Color.white.opacity(0.5))
                                        .frame(width: 31, height: 31)
                                        .cornerRadius(15))
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 160, trailing: 250))
                
                // address
                Button(action: {
                    viewModel.isShowingChangeAddress.toggle()
                }) {
                    Text("ADDRESS")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(CustomColors.darkGray)
                        .background(Rectangle()
                                        .fill(Color.white.opacity(0.5))
                                        .frame(width: 60, height: 31)
                                        .cornerRadius(15))
                }
                .padding(EdgeInsets(top: 190, leading: 0, bottom: 0, trailing: 250))
                .sheet(isPresented: $viewModel.isShowingChangeAddress, content: {
                    ChangeAddressView(userInfo: $viewModel.userInfo)
                })
                
                // password
                Button(action: {
                    viewModel.isShowingChangePassword.toggle()
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
                .sheet(isPresented: $viewModel.isShowingChangePassword, content: {
                    ChangePasswordView()
                })
                .fullScreenCover(isPresented: $viewModel.isUserLoggedOut) {
                    PrelogView()
                }
            }
            
            
            CustomTextboxTitleText(field: $viewModel.firstname, placeholderText: viewModel.userInfo.firstName, titleText: "FIRST NAME")
                .padding(EdgeInsets(top: 30, leading: 20, bottom: 20, trailing: 20))
                .submitLabel(.done)
                .onSubmit {
                    if viewModel.firstname.count > 2 {
                        viewModel.updateUserValue()
                    }
                    else {
                        // TODO: show toast name too short/invalid
                    }
                }
            
            CustomTextboxTitleText(field: $viewModel.lastname, placeholderText: viewModel.userInfo.lastName, titleText: "LAST NAME")
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                .submitLabel(.done)
                .onSubmit {
                    if viewModel.lastname.count > 2 {
                        viewModel.updateUserValue()
                    }
                    else {
                        // TODO: show toast name too short/invalid
                    }
                }
            
            CustomTextboxTitleText(field: $viewModel.email, placeholderText: viewModel.userInfo.email, charLimit: 30, titleText: "EMAIL")
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                .submitLabel(.done)
                .onSubmit {
                    if viewModel.checkValidEmail(email: viewModel.email) {
                        viewModel.updateUserValue()
                    }
                    else {
                        // TODO: show email invalid toast/notification
                    }
                }
                .textInputAutocapitalization(.never)
            
            CustomTextboxTitleText(field: $viewModel.phoneNumber, placeholderText: viewModel.userInfo.phoneNumber, titleText: "PHONE NUMBER")
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                .submitLabel(.done)
                .onReceive(Just(viewModel.phoneNumber)) { newValue in
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    if filtered != newValue {
                        viewModel.phoneNumber = filtered
                    }
                }
                .onSubmit {
                    if viewModel.phoneNumber.count == 10 || viewModel.phoneNumber.count == 11 {
                        viewModel.updateUserValue()
                    }
                    else {
                        // TODO: show phone number invalid toast/notification
                    }
                }
            
            Text("RATING: " + "\((viewModel.userInfo.rating * 10).rounded(.toNearestOrAwayFromZero) / 10)" + "/5")
                .font(.system(size: 24, weight: .regular, design: .rounded))
                .foregroundColor(CustomColors.midGray)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            RatingView(rating: (viewModel.userInfo.rating * 10).rounded(.toNearestOrAwayFromZero) / 10, maxRating: 5)
                .frame(width: 112, height: 16)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
        }
        .background(Rectangle()
                        .fill(Color.white.opacity(0.5))
                        .cornerRadius(15)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: -5, trailing: 20)))
        .padding(.bottom, keyboardHeight)
        .overlay(
            ProgressView()
                .scaleEffect(x: 2, y: 2, anchor: .center)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3)
                                .fill(CustomColors.seafoamGreen))
                .progressViewStyle(CircularProgressViewStyle(tint: CustomColors.darkGray))
                .isHidden(viewModel.isProgressViewHidden)
        )
        .edgesIgnoringSafeArea(.bottom)
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(.center)
        .tabItem {
            Image(systemName: "person")
            Text("Profile")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 20)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
        .gesture(DragGesture().onChanged{_ in UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)})
        .onAppear {
            viewModel.clearText()
            viewModel.getYourProfile()
        }
        .sheet(isPresented: $viewModel.isShowingImagePicker) {
            ImagePicker(image: $viewModel.profileInputImage)
        }
        .onChange(of: viewModel.profileInputImage) { _ in
            viewModel.loadImage()
            viewModel.uploadProfilePicture()
        }
        .onChange(of: viewModel.isShowingChangeAddress) { _ in
            viewModel.getYourProfile()
        }
    }
}

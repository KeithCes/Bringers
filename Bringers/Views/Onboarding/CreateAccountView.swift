//
//  CreateAccountView.swift
//  Bringers
//
//  Created by Keith C on 1/4/22.
//

import Foundation
import SwiftUI
import Combine

struct CreateAccountView: View {
    
    @StateObject private var viewModel = CreateAccountViewModel()
    
    @Binding var isShowingCreate: Bool
    
    
    var body: some View {
        ScrollView {
            VStack {
                CustomTitleText(labelText: "CREATE ACCOUNT")
                    .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
                
                CustomTextbox(field: $viewModel.firstName, placeholderText: "First Name")
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                
                CustomTextbox(field: $viewModel.lastName, placeholderText: "Last Name")
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                
                DatePicker(selection: $viewModel.dob, in: ...Date(), displayedComponents: .date) {
                    Text("Date of Birth")
                }
                .accentColor(CustomColors.seafoamGreen)
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .colorInvert()
                .colorScheme(.light)
                .colorMultiply(CustomColors.midGray.opacity(viewModel.isDobChanged ? 1 : 0.5))
                .frame(width: 30, height: 30, alignment: .center)
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                .background(Rectangle()
                                .fill(Color.white.opacity(0.5))
                                .frame(width: CustomDimensions.width, height: 50)
                                .cornerRadius(15))
                .padding(EdgeInsets(top: 0, leading: 50, bottom: 20, trailing: 50))
                .overlay(
                    Text("Date of Birth")
                        .foregroundColor(CustomColors.midGray.opacity(0.5))
                        .font(.system(size: 10, weight: .regular, design: .rounded))
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 60, trailing: 20))
                )
                
                CustomTextbox(field: $viewModel.email, placeholderText: "Email", charLimit: 30)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                    .textInputAutocapitalization(.never)
                CustomTextbox(field: $viewModel.phoneNumber, placeholderText: "Phone Number")
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                    .keyboardType(.numberPad)
                
                Group {
                    CustomTextbox(field: $viewModel.address, placeholderText: "Billing Address")
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                    
                    CustomTextbox(field: $viewModel.city, placeholderText: "City")
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                        .toast(message: viewModel.toastMessage,
                               isShowing: $viewModel.isShowingToast,
                               duration: Toast.long
                        )
                    
                    // state
                    Menu {
                        ForEach(StateCodes.codes, id: \.self) { state in
                            Button {
                                viewModel.state = state
                                viewModel.stateColor = CustomColors.midGray
                            } label: {
                                Text(state)
                            }
                        }
                    } label: {
                        Text(viewModel.state)
                    }
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(viewModel.stateColor)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .background(Rectangle()
                                    .fill(Color.white.opacity(0.5))
                                    .frame(width: CustomDimensions.width, height: 50)
                                    .cornerRadius(15))
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                    
                    CustomTextbox(field: $viewModel.zipcode, placeholderText: "Zipcode", charLimit: 5)
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                        .onReceive(Just(viewModel.zipcode)) { newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                viewModel.zipcode = filtered
                            }
                        }
                        .keyboardType(.numberPad)
                    
                    // country
                    Menu {
                        Button {
                            viewModel.country = "US"
                            viewModel.countryColor = CustomColors.midGray
                        } label: {
                            Text("US")
                        }
                        
                    } label: {
                        Text(viewModel.country)
                    }
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(viewModel.countryColor)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .background(Rectangle()
                                    .fill(Color.white.opacity(0.5))
                                    .frame(width: CustomDimensions.width, height: 50)
                                    .cornerRadius(15))
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                }
                
                CustomSecureTextbox(field: $viewModel.password, placeholderText: "Password")
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                
                CustomSecureTextbox(field: $viewModel.confirmPassword, placeholderText: "Confirm Password")
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                    .submitLabel(.done)
                    .onSubmit {
                        viewModel.createAccount()
                    }
                
                Button("CREATE") {
                    viewModel.checkPostErrorToast()
                    
                    if viewModel.checkIfCreateInfoValid() {
                        
                        viewModel.createStripeCustomer { customerID in
                            guard let stripeCustomerID = customerID else {
                                return
                            }
                            DispatchQueue.main.async {
                                viewModel.stripeCustomerID = stripeCustomerID
                                viewModel.createAccount()
                            }
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
            .onChange(of: viewModel.dob, perform: { _ in
                viewModel.isDobChanged = viewModel.dob != Date()
            })
            .onChange(of: viewModel.isShowingCreate, perform: { _ in
                self.isShowingCreate.toggle()
            })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(CustomColors.seafoamGreen)
            .ignoresSafeArea()
        }
        .background(CustomColors.seafoamGreen)
    }
}

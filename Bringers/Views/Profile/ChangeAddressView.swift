//
//  ChangeAddressView.swift
//  Bringers
//
//  Created by Keith C on 3/21/22.
//

import Foundation
import SwiftUI
import Combine

struct ChangeAddressView: View {
    
    @StateObject private var viewModel = ChangeAddressViewModel()
    
    @Binding var userInfo: UserInfoModel
    
    
    var body: some View {
        VStack {
            CustomTitleText(labelText: "CHANGE ADDRESS")
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
            
            VStack {
                CustomTextbox(field: $viewModel.address, placeholderText: self.userInfo.address)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 21, trailing: 20))
                    .submitLabel(.done)
                    .onSubmit {
                        if viewModel.address.count > 5 {
                            viewModel.updateUserValue(userInfo: userInfo)
                        }
                        else {
                            viewModel.toastMessage = "Address is not valid"
                            viewModel.isShowingToast.toggle()
                        }
                    }
                
                CustomTextbox(field: $viewModel.city, placeholderText: self.userInfo.city)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 21, trailing: 20))
                    .onSubmit {
                        if viewModel.city.count > 2 {
                            viewModel.updateUserValue(userInfo: userInfo)
                        }
                        else {
                            viewModel.toastMessage = "City is not valid"
                            viewModel.isShowingToast.toggle()
                        }
                    }
                
                // state
                Menu {
                    ForEach(StateCodes.codes, id: \.self) { state in
                        Button {
                            viewModel.state = state
                            viewModel.stateColor = CustomColors.midGray
                            viewModel.updateUserValue(userInfo: userInfo)
                        } label: {
                            Text(state)
                        }
                    }
                } label: {
                    Text(viewModel.state != "" ? viewModel.state : self.userInfo.state)
                }
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(viewModel.stateColor)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .background(Rectangle()
                                .fill(Color.white.opacity(0.5))
                                .frame(width: CustomDimensions.width, height: 50)
                                .cornerRadius(15))
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 21, trailing: 20))
                
                CustomTextbox(field: $viewModel.zipcode, placeholderText: self.userInfo.zipcode, charLimit: 5)
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 21, trailing: 20))
                    .onReceive(Just(viewModel.zipcode)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            viewModel.zipcode = filtered
                        }
                    }
                    .submitLabel(.done)
                    .onSubmit {
                        if viewModel.zipcode.count == 5 {
                            viewModel.updateUserValue(userInfo: userInfo)
                        }
                        else {
                            viewModel.toastMessage = "Zipcode is not valid"
                            viewModel.isShowingToast.toggle()
                        }
                    }
                
                // country
                Menu {
                    Button {
                        viewModel.country = self.userInfo.country
                        viewModel.countryColor = CustomColors.midGray
                        viewModel.updateUserValue(userInfo: userInfo)
                    } label: {
                        Text("US")
                    }
                    
                } label: {
                    Text(viewModel.country != "" ? viewModel.country : self.userInfo.country)
                }
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(viewModel.countryColor)
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
        .toast(message: viewModel.toastMessage,
               isShowing: $viewModel.isShowingToast,
               duration: Toast.long
        )
    }
}

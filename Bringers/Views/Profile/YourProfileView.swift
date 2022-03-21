//
//  YourProfileView.swift
//  Bringers
//
//  Created by Keith C on 12/25/21.
//

import Foundation
import SwiftUI
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import Combine

struct YourProfileView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var firstname: String = ""
    @State private var lastname: String = ""
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var savedCreditCard: String = ""
    
    @State private var isShowingChangePassword: Bool = false
    @State private var isShowingChangeAddress: Bool = false
    @State private var isShowingImagePicker = false
    
    @State private var isProgressViewHidden: Bool = false
    
    @State private var isUserLoggedOut: Bool = false
    
    @State private var profileInputImage: UIImage?
    @State private var profileImage: Image = Image("placeholder")
    @State private var profileImageUploaded: Bool = false
    
    @State private var userInfo: UserInfoModel = UserInfoModel()
    
    @ObservedObject private var keyboard = KeyboardResponder()
    private var keyboardHeight: CGFloat = 0
    
    init() {
        keyboardHeight = keyboard.currentHeight
    }
    
    var body: some View {
        VStack {
            ZStack {
                self.profileImage
                    .resizable()
                    .frame(width: 186, height: 186)
                    .cornerRadius(15)
                    .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
                
                // edit profile picture
                Button(action: {
                    isShowingImagePicker.toggle()
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
                    try! Auth.auth().signOut()
                    self.isUserLoggedOut.toggle()
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
                    isShowingChangeAddress.toggle()
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
                .sheet(isPresented: $isShowingChangeAddress, content: {
                    ChangeAddressView(userInfo: $userInfo)
                })
                
                // password
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
                .fullScreenCover(isPresented: $isUserLoggedOut) {
                    PrelogView()
                }
            }
            
            
            CustomTextboxTitleText(field: $firstname, placeholderText: self.userInfo.firstName, titleText: "FIRST NAME")
                .padding(EdgeInsets(top: 30, leading: 20, bottom: 20, trailing: 20))
                .submitLabel(.done)
                .onSubmit {
                    if firstname.count > 2 {
                        updateUserValue()
                    }
                    else {
                        // TODO: show toast name too short/invalid
                    }
                }
            
            CustomTextboxTitleText(field: $lastname, placeholderText: self.userInfo.lastName, titleText: "LAST NAME")
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                .submitLabel(.done)
                .onSubmit {
                    if lastname.count > 2 {
                        updateUserValue()
                    }
                    else {
                        // TODO: show toast name too short/invalid
                    }
                }
            
            CustomTextboxTitleText(field: $email, placeholderText: self.userInfo.email, titleText: "EMAIL")
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                .submitLabel(.done)
                .onSubmit {
                    if checkValidEmail(email: email) {
                        updateUserValue()
                    }
                    else {
                        // TODO: show email invalid toast/notification
                    }
                }
                .textInputAutocapitalization(.never)
            
            CustomTextboxTitleText(field: $phoneNumber, placeholderText: self.userInfo.phoneNumber, titleText: "PHONE NUMBER")
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                .submitLabel(.done)
                .onReceive(Just(phoneNumber)) { newValue in
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    if filtered != newValue {
                        self.phoneNumber = filtered
                    }
                }
                .onSubmit {
                    if phoneNumber.count == 10 || phoneNumber.count == 11 {
                        updateUserValue()
                    }
                    else {
                        // TODO: show phone number invalid toast/notification
                    }
                }
            
            Text("RATING: " + "\((self.userInfo.rating * 10).rounded(.toNearestOrAwayFromZero) / 10)" + "/5")
                .font(.system(size: 24, weight: .regular, design: .rounded))
                .foregroundColor(CustomColors.midGray)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            RatingView(rating: (self.userInfo.rating * 10).rounded(.toNearestOrAwayFromZero) / 10, maxRating: 5)
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
                .isHidden(self.isProgressViewHidden)
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
            clearText()
            getYourProfile()
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(image: $profileInputImage)
        }
        .onChange(of: profileInputImage) { _ in
            loadImage()
            uploadProfilePicture()
        }
        .onChange(of: isShowingChangeAddress) { _ in
            getYourProfile()
        }
    }
    
    func getYourProfile() {
        
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference()
        
        ref.child("users").child(userID).child("userInfo").observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let activeUserInfo = snapshot.value as? NSDictionary else {
                return
            }
            
            guard let activeUserInfoMap = UserInfo.from(activeUserInfo) else {
                return
            }
            
            let userInfo = UserInfoModel(
                dateOfBirth: activeUserInfoMap.dateOfBirth,
                dateOfCreation: activeUserInfoMap.dateOfCreation,
                email: activeUserInfoMap.email,
                firstName: activeUserInfoMap.firstName,
                lastName: activeUserInfoMap.lastName,
                ordersCompleted: activeUserInfoMap.ordersCompleted,
                ordersPlaced: activeUserInfoMap.ordersPlaced,
                ordersCanceled: activeUserInfoMap.ordersCanceled,
                bringersCompleted: activeUserInfoMap.bringersCompleted,
                bringersAccepted: activeUserInfoMap.bringersAccepted,
                bringersCanceled: activeUserInfoMap.bringersCanceled,
                phoneNumber: activeUserInfoMap.phoneNumber,
                profilePictureURL: activeUserInfoMap.profilePictureURL,
                rating: activeUserInfoMap.rating,
                totalRatings: activeUserInfoMap.totalRatings,
                stripeAccountID: activeUserInfoMap.stripeAccountID,
                stripeCustomerID: activeUserInfoMap.stripeCustomerID,
                address: activeUserInfoMap.address,
                state: activeUserInfoMap.state,
                city: activeUserInfoMap.city,
                country: activeUserInfoMap.country,
                zipcode: activeUserInfoMap.zipcode
            )
            
            self.userInfo = userInfo
            
            getProfilePicture()
        })
    }
    
    func updateUserValue() {
        let ref = Database.database().reference()
        let userID = Auth.auth().currentUser!.uid
        
        let firstname = self.firstname != "" ? self.firstname : self.userInfo.firstName
        let lastname = self.lastname != "" ? self.lastname : self.userInfo.lastName
        
        updateUserValueStripe { _ in
            ref.child("users").child(userID).child("userInfo").updateChildValues([
                "firstName" : firstname,
                "lastName" : lastname,
                "email" : self.email != "" ? self.email : self.userInfo.email,
                "phoneNumber" : self.phoneNumber != "" ? self.phoneNumber : self.userInfo.phoneNumber,
            ])
            getYourProfile()
        }
    }
    
    private func updateUserValueStripe(completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://bringers-nodejs.vercel.app/update-customer-info")!
        
        let firstname = self.firstname != "" ? self.firstname : self.userInfo.firstName
        let lastname = self.lastname != "" ? self.lastname : self.userInfo.lastName
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode([
            "customerID" : self.userInfo.stripeCustomerID,
            "fullName" : firstname + " " + lastname,
            "email" : self.email != "" ? self.email : self.userInfo.email,
            "phoneNumber" : self.phoneNumber != "" ? self.phoneNumber : self.userInfo.phoneNumber,
        ])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil,
                  (response as? HTTPURLResponse)?.statusCode == 200,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                  let customerID = json["customerID"] as? String else {
                      completion(nil)
                      return
                  }
            completion(customerID)
        }.resume()
    }
    
    func checkValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func clearText() {
        self.firstname = ""
        self.lastname = ""
        self.email = ""
        self.phoneNumber = ""
    }
    
    func uploadProfilePicture() {
        
        let userID = Auth.auth().currentUser!.uid
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let profilePictureRef = storageRef.child("profilePictures/" + userID + "/" + "profilePicture.png")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        guard let data: Data = self.profileInputImage?.jpegData(compressionQuality: 0.20) else {
            return
        }
        
        profilePictureRef.putData(data, metadata: nil) { (metadata, error) in
            guard let _ = metadata else {
                // error occurred
                return
            }
            self.profileImageUploaded = true
        }
    }
    
    func loadImage() {
        guard let inputImage = profileInputImage else { return }
        self.profileImage = Image(uiImage: inputImage)
    }
    
    func getProfilePicture() {
        
        let userID = Auth.auth().currentUser!.uid
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let profilePictureRef = storageRef.child("profilePictures/" + userID + "/" + "profilePicture.png")
        
        profilePictureRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let _ = error {
                // error occurred
            } else {
                self.profileInputImage = UIImage(data: data!)
                
                guard let inputImage = profileInputImage else { return }
                self.profileImage = Image(uiImage: inputImage)
            }
            self.isProgressViewHidden = true
        }
    }
}

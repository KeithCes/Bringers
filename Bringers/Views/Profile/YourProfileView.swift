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
    @State private var isShowingImagePicker = false
    
    @State private var isProgressViewHidden: Bool = false
    
    @State private var isUserLoggedOut: Bool = false
    
    @State private var profileInputImage: UIImage?
    @State private var profileImage: Image = Image("placeholder")
    @State private var profileImageUploaded: Bool = false
    
    @State private var userInfo: UserInfoModel = UserInfoModel()
    
    private var rating: CGFloat = 3.8
    
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
                    updateUserValue(property: "firstName", value: self.firstname)
                }
            
            CustomTextboxTitleText(field: $lastname, placeholderText: self.userInfo.lastName, titleText: "LAST NAME")
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                .submitLabel(.done)
                .onSubmit {
                    updateUserValue(property: "lastName", value: self.lastname)
                }
            
            CustomTextboxTitleText(field: $email, placeholderText: self.userInfo.email, titleText: "EMAIL")
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                .submitLabel(.done)
                .onSubmit {
                    if checkValidEmail(email: email) {
                        updateUserValue(property: "email", value: self.email)
                    }
                    else {
                        // TODO: show email invalid toast/notification
                    }
                }
            
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
                        updateUserValue(property: "phoneNumber", value: self.phoneNumber)
                    }
                    else {
                        // TODO: show phone number invalid toast/notification
                    }
                }
            
            // TODO: send credit card data securly (probably thorugh payment provider; stripe?)
            CustomTextboxTitleText(field: $savedCreditCard, placeholderText: "****-****-****-9420", titleText: "SAVED CREDIT CARD")
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 30, trailing: 20))
                .submitLabel(.done)
                .onSubmit { }
            
            
            Text("RATING: " + "\(rating)" + "/5")
                .font(.system(size: 24, weight: .regular, design: .rounded))
                .foregroundColor(CustomColors.midGray)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            RatingView(rating: rating, maxRating: 5)
                .frame(width: 112, height: 16)
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
                phoneNumber: activeUserInfoMap.phoneNumber,
                profilePictureURL: activeUserInfoMap.profilePictureURL,
                rating: activeUserInfoMap.rating,
                stripeAccountID: activeUserInfoMap.stripeAccountID,
                address: activeUserInfoMap.address,
                state: activeUserInfoMap.state,
                city: activeUserInfoMap.city,
                country: activeUserInfoMap.country
            )
            
            self.userInfo = userInfo
            
            getProfilePicture()
        })
    }
    
    func updateUserValue(property: String, value: Any) {
        let ref = Database.database().reference()
        let userID = Auth.auth().currentUser!.uid
        
        ref.child("users").child(userID).child("userInfo").updateChildValues([property : value])
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

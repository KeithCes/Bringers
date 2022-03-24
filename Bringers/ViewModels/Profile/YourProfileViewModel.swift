//
//  YourProfileViewModel.swift
//  Bringers
//
//  Created by Keith C on 3/24/22.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

final class YourProfileViewModel: ObservableObject {
    
    @Published var firstname: String = ""
    @Published var lastname: String = ""
    @Published var email: String = ""
    @Published var phoneNumber: String = ""
    
    @Published var profileInputImage: UIImage?
    @Published var profileImage: Image = Image("placeholder")
    @Published var profileImageUploaded: Bool = false
    
    @Published var savedCreditCard: String = ""
    
    @Published var isShowingChangePassword: Bool = false
    @Published var isShowingChangeAddress: Bool = false
    @Published var isShowingImagePicker = false
    
    @Published var isProgressViewHidden: Bool = false
    
    @Published var isUserLoggedOut: Bool = false
    
    @Published var userInfo: UserInfoModel = UserInfoModel()
    
    
    func clearText() {
        self.firstname = ""
        self.lastname = ""
        self.email = ""
        self.phoneNumber = ""
    }
    
    func checkValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
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
            
            self.getProfilePicture()
        })
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
                
                guard let inputImage = self.profileInputImage else { return }
                self.profileImage = Image(uiImage: inputImage)
            }
            self.isProgressViewHidden = true
        }
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
            self.getYourProfile()
        }
    }
    
    func updateUserValueStripe(completion: @escaping (String?) -> Void) {
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
    
    func logoutUser() {
        try! Auth.auth().signOut()
        self.isUserLoggedOut.toggle()
    }
}

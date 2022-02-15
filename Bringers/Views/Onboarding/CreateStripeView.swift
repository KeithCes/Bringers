//
//  CreateStripeView.swift
//  Bringers
//
//  Created by Keith C on 2/15/22.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import Stripe
import SafariServices

struct CreateStripeView: View {
    
    @Binding var isShowingStripe: Bool
    @Binding var isStripeCompletedSuccessfully: Bool
    @Binding var stripeAccountID: String
    
    @State var isShowingSafari: Bool = false
    
    // TODO: change to custom URL when wesbite setup
    @State var stripeURLString = "https://duckduckgo.com"
    @State var stripeUserID = ""
    
    var body: some View {
        VStack {
            CustomTitleText(labelText: "SETUP STRIPE TO MAKE AND RECEIVE PAYMENTS")
            
            Link(destination: URL(string: self.stripeURLString)!, label: {
                Button("SETUP STRIPE") {
                    didSelectConnectWithStripe { url in
                        
                        self.stripeURLString = url ?? ""
                        
                        DispatchQueue.main.async {
                            self.isShowingSafari = true
                        }
                    }
                }
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(Color.white)
                .background(Rectangle()
                                .fill(CustomColors.blueGray.opacity(0.6))
                                .frame(width: CustomDimensions.width, height: 70)
                                .cornerRadius(15))
                .padding(EdgeInsets(top: 30, leading: 20, bottom: 10, trailing: 20))
            })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CustomColors.seafoamGreen)
        .ignoresSafeArea()
        
        .sheet(isPresented: $isShowingSafari) {
            SafariView(url: URL(string: self.stripeURLString)!)
        }
        
        .onChange(of: isShowingSafari) { isShowingSafari in
            if !isShowingSafari {
                fetchUserDetails { chargesEnabled in
                    if chargesEnabled! {
                        self.stripeAccountID = self.stripeUserID
                        isShowingStripe.toggle()
                        isStripeCompletedSuccessfully = true
                    }
                    else {
                        print("ERROR USER NOT CREATED")
                    }
                }
            }
        }
    }
    
    func didSelectConnectWithStripe(completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://bringers-nodejs.vercel.app/onboard-user")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data,
                  error == nil,
                  (response as? HTTPURLResponse)?.statusCode == 200,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                  let accountURLString = json["url"] as? String,
                  let accountID = json["userID"] as? String else {
                      completion(nil)
                      return
                  }
            DispatchQueue.main.async {
                self.stripeUserID = accountID
            }
            completion(accountURLString)
        }.resume()
    }

    func fetchUserDetails(completion: @escaping (Bool?) -> Void) {
        let url = URL(string: "https://bringers-nodejs.vercel.app/get-user-details")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(["userID" : self.stripeUserID])
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data,
                  error == nil,
                  (response as? HTTPURLResponse)?.statusCode == 200,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                  let chargesEnabled = json["chargesEnabled"] as? Bool else {
                      completion(nil)
                      return
                  }
            completion(chargesEnabled)
        }.resume()
    }
}

struct SafariView: UIViewControllerRepresentable {

    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {

    }
}

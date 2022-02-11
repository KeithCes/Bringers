//
//  BringersApp.swift
//  Bringers
//
//  Created by Keith C on 12/18/21.
//

import SwiftUI
import Firebase
import Stripe

@main
struct BringersApp: App {
    
    init() {
        FirebaseApp.configure()
        
        StripeAPI.defaultPublishableKey = "pk_test_51KQygWGjcG48IAigJva0t2AH6Rr2cIx6UHSiUUFPpHFytLU7Gj1ws6orxFvU5wKiIS7Jx1obHpm7AmbPtuakvPs900yOqYLf5f"
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

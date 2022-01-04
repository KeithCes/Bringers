//
//  BringersApp.swift
//  Bringers
//
//  Created by Keith C on 12/18/21.
//

import SwiftUI
import Firebase

@main
struct BringersApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

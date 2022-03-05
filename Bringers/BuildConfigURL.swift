//
//  BuildConfigURL.swift
//  Bringers
//
//  Created by Keith C on 3/5/22.
//

import Foundation

struct BuildConfigURL {
    
    #if TESTS
    static var url = "http://localhost:1234/"
    #else
    static var url = "https://bringers-nodejs.vercel.app/"
    #endif
}

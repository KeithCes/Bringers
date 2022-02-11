//
//  PaymentConfig.swift
//  Bringers
//
//  Created by Keith C on 2/8/22.
//

import Foundation

class PaymentConfig {
    var paymentIntentClientSecret: String?
    static var shared: PaymentConfig = PaymentConfig()
    
    private init() { }
}

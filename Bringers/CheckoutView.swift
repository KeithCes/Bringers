//
//  CheckoutView.swift
//  Bringers
//
//  Created by Keith C on 2/9/22.
//

import Foundation

import SwiftUI
import Stripe

struct CheckoutView: View {
    
    @State private var message: String = ""
    @State private var isSuccess: Bool = false
    @State private var paymentMethodParams: STPPaymentMethodParams?
    let paymentGatewayController = PaymentGatewayController()
        
    private func pay() {
        
        guard let clientSecret = PaymentConfig.shared.paymentIntentClientSecret else {
            return
        }
        
        let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
        paymentIntentParams.paymentMethodParams = paymentMethodParams
        
        paymentGatewayController.submitPayment(intent: paymentIntentParams) { status, intent, error in
            
            switch status {
                case .failed:
                    message = "Failed"
                case .canceled:
                    message = "Cancelled"
                case .succeeded:
                    message = "Your payment has been successfully completed!"
            }
            
        }
        
    }

    var body: some View {
        VStack {
            List {
                
                HStack {
                    Spacer()
                    Text("Total \(69)")
                    Spacer()
                }
                
                Section {
                    // Stripe Credit Card TextField Here
                    STPPaymentCardTextField.Representable.init(paymentMethodParams: $paymentMethodParams)
                } header: {
                    Text("Payment Information")
                }
                
                HStack {
                    Spacer()
                    Button("Pay") {
                        pay()
                    }.buttonStyle(.plain)
                    Spacer()
                }
                
                Text(message)
                    .font(.headline)
                
                
            }
            
            NavigationLink(isActive: $isSuccess, destination: {
                Confirmation()
            }, label: {
                EmptyView()
            })
            
            
            .navigationTitle("Checkout")
            
        }
    }
}

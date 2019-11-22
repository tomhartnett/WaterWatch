//
//  SummaryView.swift
//  WaterWatch WatchKit Extension
//
//  Created by Tom Hartnett on 11/21/19.
//  Copyright © 2019 Sleekible LLC. All rights reserved.
//

import HealthKit
import SwiftUI

struct SummaryView: View {
    @State private var showingAlert = false
    @State private var errorMessage = ""
    @State private var showAddView = false
    
    var body: some View {
        VStack {
            Text("Thu, Nov 21")
            Text("2.55 L")
                .font(.title)
            Text("6 entries")
            Button(action: {
                self.showAddView.toggle()
            }) {
                Text("Add Entry")
            }
        }.onAppear() {
            guard HKHealthStore.isHealthDataAvailable() else {
                self.errorMessage = "HealthKit not available"
                self.showingAlert = true
                return
            }
            let dataStore = HealthDataStore()
            let status = dataStore.getAuthorizationStatus()
            switch status {
            case .sharingDenied:
                self.errorMessage = "HealthKit access denied"
                self.showingAlert = true
            case .notDetermined:
                dataStore.requestAuthorization { (authorized, error) in
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        self.showingAlert = true
                        return
                    }
                    
                    if !authorized {
                        self.errorMessage = "HealthKit access denied"
                        self.showingAlert = true
                    } else {
                        // query for today's data
                    }
                }
            case .sharingAuthorized:
                // query for today's data
                break
            @unknown default:
                fatalError()
            }
        }.alert(isPresented: $showingAlert) {
            Alert(title: Text("HealthKit Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }.sheet(isPresented: $showAddView) {
            AddView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
    }
}

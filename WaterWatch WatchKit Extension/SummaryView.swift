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
    @State private var summary = Summary(date: Date(), volumeDisplayString: "0.0 L", percentOfGoal: 0, entryCount: 0)
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter
    }()
    
    var body: some View {
        VStack {
            Text("\(summary.date, formatter: self.dateFormatter)")
            Text("\(summary.volumeDisplayString) / \(String(format: "%.0f", summary.percentOfGoal * 100))%")
                .font(.system(size: 28, weight: Font.Weight.semibold, design: Font.Design.rounded))
                .padding(.vertical)
            if summary.entryCount > 0 {
                Text(String(repeating: "💧", count: summary.entryCount))
            }
            Text("\(summary.entryCount) \(summary.entryCount == 1 ? "entry" : "entries")")
            Button(action: {
                self.showAddView.toggle()
            }) {
                Text("Add Entry")
                    .font(.system(size: 20, weight: Font.Weight.regular, design: Font.Design.rounded))
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
                        dataStore.getWaterForCurrentDay { (summary) in
                            if let summary = summary {
                                self.summary = summary
                            }
                        }
                    }
                }
            case .sharingAuthorized:
                dataStore.getWaterForCurrentDay { (summary) in
                    if let summary = summary {
                        self.summary = summary
                    }
                }
            @unknown default:
                fatalError()
            }
        }.alert(isPresented: $showingAlert) {
            Alert(title: Text("HealthKit Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }.sheet(isPresented: $showAddView) {
            AddView(isPresented: self.$showAddView)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
    }
}

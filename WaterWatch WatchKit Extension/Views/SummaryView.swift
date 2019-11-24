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
    @ObservedObject var globalState = GlobalState()
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter
    }()
    
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        return formatter
    }()
    
    var body: some View {
        VStack {
            Text("\(globalState.dailySummary.date, formatter: self.dateFormatter)")
            
            if globalState.preferredUnit == PreferredUnit.fluidOunces {
                Text("\(globalState.dailySummary.volumeFluidOunces, specifier: "%.0f") fl oz / \(globalState.dailySummary.percentOfGoal * 100, specifier: "%.0f")%")
                    .font(.system(size: 28, weight: Font.Weight.semibold, design: Font.Design.rounded))
                    .padding(.vertical)
            } else {
                Text("\(globalState.dailySummary.volumeLiters, specifier: "%.2f") L / \(globalState.dailySummary.percentOfGoal * 100, specifier: "%.0f")%")
                    .font(.system(size: 28, weight: Font.Weight.semibold, design: Font.Design.rounded))
                    .padding(.vertical)
            }
            
            if globalState.dailySummary.entryCount > 0 {
                Text("\(globalState.dailySummary.entryCount)💧 - \(globalState.dailySummary.date, formatter: self.timeFormatter)")
            } else {
                Text("0💧")
            }
            
            Button(action: {
                self.globalState.showAddView.toggle()
            }) {
                Text("Add Entry")
                    .font(.system(size: 20, weight: Font.Weight.regular, design: Font.Design.rounded))
            }
        }.onAppear() {
            guard HKHealthStore.isHealthDataAvailable() else {
                self.globalState.errorMessage = "HealthKit not available"
                return
            }
            let dataStore = HealthDataStore()
            let status = dataStore.getAuthorizationStatus()
            switch status {
            case .sharingDenied:
                self.globalState.errorMessage = "HealthKit access denied"
            case .notDetermined:
                dataStore.requestAuthorization { (authorized, error) in
                    if let error = error {
                        self.globalState.errorMessage = error.localizedDescription
                        return
                    }
                    
                    if !authorized {
                        self.globalState.errorMessage = "HealthKit access denied"
                    } else {
                        dataStore.getWaterForCurrentDay { (summary) in
                            if let summary = summary {
                                DispatchQueue.main.async {
                                    self.globalState.dailySummary = summary
                                }
                            }
                        }
                    }
                }
            case .sharingAuthorized:
                dataStore.getWaterForCurrentDay { (summary) in
                    if let summary = summary {
                        DispatchQueue.main.async {
                            self.globalState.dailySummary = summary
                        }
                    }
                }
            @unknown default:
                fatalError()
            }
        }.alert(isPresented: $globalState.showError) {
            Alert(title: Text("HealthKit Error"), message: Text(globalState.errorMessage), dismissButton: .default(Text("OK")))
        }.sheet(isPresented: $globalState.showAddView) {
            AddView(isPresented: self.$globalState.showAddView)
        }.contextMenu {
            Button(action: {
                self.globalState.preferredUnit = PreferredUnit.milliliters
            }) {
                Text("Liters (mL)")
            }
            Button(action: {
                self.globalState.preferredUnit = PreferredUnit.fluidOunces
            }) {
                Text("Fluid Ounces (fl oz)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
    }
}

//
//  HomeView.swift
//  WaterWatch WatchKit Extension
//
//  Created by Tom Hartnett on 11/30/19.
//  Copyright © 2019 Sleekible LLC. All rights reserved.
//

import HealthKit
import SwiftUI

struct HomeView: View {
    @ObservedObject var globalState = GlobalState()
    
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(globalState.dailySummary.percentOfGoal * 100, specifier: "%.0f")%")
                .font(.title)
            if globalState.preferredUnit == PreferredUnit.fluidOunces {
                HStack {
                    Text("\(globalState.dailySummary.volumeFluidOunces, specifier: "%.0f") / \(globalState.goalFluidOunces) fl oz")
                    Spacer()
                    Text("\(globalState.dailySummary.entryCount)💧")
                }
            } else {
                HStack {
                    Text("\(globalState.dailySummary.volumeMilliliters, specifier: "%.0f") / \(globalState.goalMilliliters) mL")
                    Spacer()
                    Text("\(globalState.dailySummary.entryCount)💧")
                }
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .frame(width: geometry.size.width, height: 12.0)
                        .foregroundColor(Color.white)
                    Capsule(style: .continuous)
                        .frame(width: geometry.size.width * 0.5, height: 12.0)
                        .foregroundColor(Color.blue)
                }
            }
            
            Text("Last: \(globalState.dailySummary.date, formatter: self.timeFormatter)")
                .font(.caption)
            Button(action: {
                self.globalState.showAddView.toggle()
            }) {
                Text("Add")
            }.sheet(isPresented: $globalState.showAddView) {
                if self.globalState.preferredUnit == PreferredUnit.fluidOunces {
                    AddOuncesView(isPresented: self.$globalState.showAddView)
                } else {
                    AddMillilitersView(isPresented: self.$globalState.showAddView)
                }
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
        }.contextMenu {
            Button(action: {
                self.globalState.showGoalEntry = true
            }) {
                Text("Goal ")
            }.sheet(isPresented: $globalState.showGoalEntry) {
                if self.globalState.preferredUnit == PreferredUnit.fluidOunces {
                    GoalOuncesView(isPresented: self.$globalState.showGoalEntry, goalMilliliters: self.$globalState.goalMilliliters)
                } else {
                    GoalMillilitersView(isPresented: self.$globalState.showGoalEntry, goalMilliliters: self.$globalState.goalMilliliters)
                }
            }
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

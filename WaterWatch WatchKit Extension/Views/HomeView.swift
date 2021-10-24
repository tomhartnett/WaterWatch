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
    @StateObject var globalState = GlobalState()
    @StateObject var healthStore = HealthKitStore()
    @State private var isPresentingHealthKitAuthView = false
    
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        return formatter
    }()
    
    var progressPercentage: CGFloat {
        let goalPercentage = CGFloat(healthStore.summary.percentOfGoal)
        return min(1.0, goalPercentage)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {

                HealthKitAuthBannerView(status: healthStore.authorizationStatus)
                    .onTapGesture {
                        isPresentingHealthKitAuthView.toggle()
                    }

                Text("\(healthStore.summary.percentOfGoal * 100, specifier: "%.0f")%")
                    .font(.title)
                if globalState.preferredUnit == PreferredUnit.fluidOunces {
                    HStack {
                        Text("\(healthStore.summary.volumeFluidOunces, specifier: "%.0f") / \(globalState.goalFluidOunces, specifier: "%.0f") fl oz")
                        Spacer()
                        Text("\(healthStore.summary.entryCount)💧")
                    }
                } else {
                    HStack {
                        Text("\(healthStore.summary.volumeMilliliters, specifier: "%.0f") / \(globalState.goalMilliliters, specifier: "%.0f") mL")
                        Spacer()
                        Text("\(healthStore.summary.entryCount)💧")
                    }
                }
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule(style: .continuous)
                            .frame(width: geometry.size.width, height: 12.0)
                            .foregroundColor(Color.white)
                        Capsule(style: .continuous)
                            .frame(width: geometry.size.width * self.progressPercentage, height: 12.0)
                            .foregroundColor(Color.blue)
                    }
                }

                Text("Last: \(healthStore.summary.date, formatter: self.timeFormatter)")
                    .font(.caption)

                Button(action: {
                    self.globalState.showAddView.toggle()
                }) {
                    Text("Add")
                }.sheet(isPresented: $globalState.showAddView) {
                    if self.globalState.preferredUnit == PreferredUnit.fluidOunces {
                        AddOuncesView(isPresented: self.$globalState.showAddView)
                            .environmentObject(healthStore)
                    } else {
                        AddMillilitersView(isPresented: self.$globalState.showAddView)
                            .environmentObject(healthStore)
                    }
                }
                .disabled(healthStore.authorizationStatus != .sharingAuthorized)
            }.onAppear() {
                healthStore.getAuthorizationStatus()
                healthStore.getWaterForCurrentDay()
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
            .sheet(isPresented: $isPresentingHealthKitAuthView) {
                HealthKitAuthView().environmentObject(healthStore)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

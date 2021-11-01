//
//  HomeView.swift
//  WaterWatch WatchKit Extension
//
//  Created by Tom Hartnett on 11/30/19.
//  Copyright © 2019 Sleekible LLC. All rights reserved.
//

import HealthKit
import SwiftUI

enum HomeViewSheet: Identifiable {
    case addMilliliters
    case addOunces
    case healthKitAuthorization

    var id: Int {
        switch self {
        case .addMilliliters:
            return 0
        case .addOunces:
            return 1
        case .healthKitAuthorization:
            return 2
        }
    }
}

struct HomeView: View {
    @StateObject var globalState = GlobalState()
    @StateObject var healthStore = HealthKitStore()
    @State private var selectedSheet: HomeViewSheet? = nil
    
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
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {

                    HealthKitAuthBannerView(status: healthStore.authorizationStatus)
                        .onTapGesture {
                            selectedSheet = .healthKitAuthorization
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
                        selectedSheet = globalState.preferredUnit == .milliliters ? .addMilliliters : .addOunces
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add")
                            Spacer()
                        }
                        .padding(.leading, 15)
                    }
                    .disabled(healthStore.authorizationStatus != .sharingAuthorized)

                    NavigationLink(destination: SettingsView().environmentObject(globalState)) {
                        HStack {
                            Image(systemName: "gearshape")
                            Text("Settings")
                            Spacer()
                        }
                        .padding(.leading, 15)
                    }
                    .padding(.top)

                }.onAppear() {
                    healthStore.getAuthorizationStatus()
                    healthStore.getWaterForCurrentDay()
                }
                .sheet(item: $selectedSheet) { sheet in
                    switch sheet {
                    case .addMilliliters:
                        AddMillilitersView().environmentObject(healthStore)
                    case .addOunces:
                        AddOuncesView().environmentObject(healthStore)
                    case .healthKitAuthorization:
                        HealthKitAuthView().environmentObject(healthStore)
                    }
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

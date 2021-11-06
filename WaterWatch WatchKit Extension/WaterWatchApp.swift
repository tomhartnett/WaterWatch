//
//  WaterWatchApp.swift
//  WaterWatch WatchKit Extension
//
//  Created by Tom Hartnett on 11/6/21.
//  Copyright © 2021 Sleekible LLC. All rights reserved.
//

import SwiftUI

@main
struct WaterWatchApp: App {
    @Environment(\.scenePhase) var scenePhase

    @StateObject var healthStore = HealthKitStore()

    init() {}

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(healthStore)
        }
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .active:
                healthStore.getAuthorizationStatus()
                healthStore.getWaterForCurrentDay()
            default:
                break
            }
        }
    }
}

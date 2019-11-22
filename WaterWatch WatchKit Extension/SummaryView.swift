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
    var body: some View {
        VStack {
            Text("Thu, Nov 21")
            Text("2.55 L")
                .font(.title)
            Text("6 entries")
            Button(action: {}) {
                Text("Add Entry")
            }
        }.onAppear() {
            guard HKHealthStore.isHealthDataAvailable() else { return }
            guard let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else { return }
            let hkTypesToWrite: Set<HKSampleType> = [waterType]
            let hkTypesToRead: Set<HKObjectType> = [waterType]
            let hs = HKHealthStore()
            let status = hs.authorizationStatus(for: waterType)
            if status == .notDetermined {
                HKHealthStore().requestAuthorization(toShare: hkTypesToWrite, read: hkTypesToRead) { (authorized, error) in
                    print("done")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
    }
}

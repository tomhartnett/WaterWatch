//
//  HealthDataStore.swift
//  WaterWatch WatchKit Extension
//
//  Created by Tom Hartnett on 10/1/21.
//

import ClockKit
import HealthKit
import SwiftUI

class HealthKitStore: ObservableObject {
    @Published var authorizationStatus: AuthorizationStatus = .notAvailable
    @Published var summary = Summary()

    private var healthStore: HKHealthStore?

    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }

    // MARK: - Authorization

    func getAuthorizationStatus() {
        guard let store = healthStore else {
            authorizationStatus = .notAvailable
            return
        }

        guard let type = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
            authorizationStatus = .notAvailable
            return
        }

        let status = store.authorizationStatus(for: type)

        DispatchQueue.main.async { [self] in
            switch status {
            case .notDetermined:
                authorizationStatus = .notDetermined
            case .sharingDenied:
                authorizationStatus = .sharingDenied
            case .sharingAuthorized:
                authorizationStatus = .sharingAuthorized
            @unknown default:
                fatalError("Encountered @unknown HKAuthorizationStatus case.")
            }
        }
    }

    func requestAuthorization() {
        guard let store = healthStore else {
            return
        }

        guard let type = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
            return
        }

        store.requestAuthorization(toShare: [type], read: [type]) { [weak self] _, _ in
            self?.getAuthorizationStatus()
        }
    }

    // MARK: - Reading/Writing Data

    func getWaterForCurrentDay() {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .dietaryWater),
            let interval = Calendar.current.dateInterval(of: .day, for: Date()) else {
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: interval.start,
                                                    end: interval.end,
                                                    options: .strictStartDate)

        let query = HKSampleQuery(sampleType: sampleType,
                                  predicate: predicate,
                                  limit: 100,
                                  sortDescriptors: nil) { query, samples, error in

            if let samples = samples {
                let sum = samples.reduce(0) { (result, sample) -> Double in
                    if let quantitySample = sample as? HKQuantitySample {
                        return result + quantitySample.quantity.doubleValue(for: HKUnit.literUnit(with: .milli))
                    } else {
                        return result
                    }
                }

                var goal = UserDefaults.standard.integer(forKey: "UDK_goal")
                if goal == 0 {
                    goal = 3000
                }

                let percentOfGoal = sum / Double(goal)

                let lastUpdated = UserDefaults.standard.object(forKey: "UDK_lastUpdated") as? Date ?? Date.distantPast

                let previousCount = UserDefaults.standard.integer(forKey: "UDKey_entryCount")
                if previousCount != samples.count {
                    UserDefaults.standard.set(samples.count, forKey: "UDKey_entryCount")
                    UserDefaults.standard.set(sum, forKey: "UDKey_currentVolume")
                    UserDefaults.standard.set(percentOfGoal, forKey: "UDK_percentOfGoal")

                    for complication in CLKComplicationServer.sharedInstance().activeComplications ?? [] {
                        CLKComplicationServer.sharedInstance().reloadTimeline(for: complication)
                    }
                }

                DispatchQueue.main.async {
                    self.summary = Summary(date: lastUpdated,
                                           volumeMilliliters: sum,
                                           percentOfGoal: percentOfGoal,
                                           entryCount: samples.count)
                }
            }
        }

        HKHealthStore().execute(query)
    }

    func saveWaterSample(sampleSizeFluidOunces: Double, date: Date) {
        let measurement = Measurement(value: sampleSizeFluidOunces, unit: UnitVolume.fluidOunces)
        saveWaterSample(sampleSizeMilliliters: measurement.converted(to: .milliliters).value, date: date)
    }

    func saveWaterSample(sampleSizeMilliliters: Double, date: Date) {
        guard sampleSizeMilliliters > 0 else {
            return
        }

        guard let sampleType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
            return
        }
        let unit = HKUnit.literUnit(with: .milli)
        let quantity = HKQuantity(unit: unit, doubleValue: sampleSizeMilliliters)
        let sample = HKQuantitySample(type: sampleType, quantity: quantity, start: date, end: date)
        HKHealthStore().save(sample) { (success, error) in
            if let error = error {
                print("Error saving sample: \(error.localizedDescription)")
                return
            }
            if success {
                UserDefaults.standard.set(Date(), forKey: "UDK_lastUpdated")
            }
        }
    }
}

extension HealthKitStore {
    enum AuthorizationStatus {
        case notAvailable
        case notDetermined
        case sharingDenied
        case sharingAuthorized
    }
}

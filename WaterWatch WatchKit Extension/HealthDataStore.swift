//
//  HealthDataStore.swift
//  WaterWatch WatchKit Extension
//
//  Created by Tom Hartnett on 11/22/19.
//  Copyright © 2019 Sleekible LLC. All rights reserved.
//

import Foundation
import HealthKit
import WatchKit

class HealthDataStore {
    typealias AuthorizationStatus = HKAuthorizationStatus
    
    func getAuthorizationStatus() -> AuthorizationStatus {
        guard let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
            return .notDetermined
        }
        return HKHealthStore().authorizationStatus(for: waterType)
    }
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
            completion(false, HealthDataStoreError.typeInitializationFailed(message: "Failed to create dietaryWater type."))
            return
        }
        
        HKHealthStore().requestAuthorization(toShare: [waterType], read: [waterType]) { (authorized, error) in
            completion(authorized, error)
        }
    }
    
    func getWaterForCurrentDay(completion: @escaping (Summary?) -> Void) {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .dietaryWater),
            let interval = Calendar.current.dateInterval(of: .day, for: Date()) else {
            completion(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 100, sortDescriptors: nil) { query, samples, error in
            if let _ = error {
                completion(nil)
                return
            }
            if let samples = samples {
                let sum = samples.reduce(0) { (result, sample) -> Double in
                    if let quantitySample = sample as? HKQuantitySample {
                        return result + quantitySample.quantity.doubleValue(for: HKUnit.liter())
                    } else {
                        return result
                    }
                }
                let percentOfGoal = sum / 3.0
                let summary = Summary(date: interval.start, volumeDisplayString: String(format: "%.2f L", sum), percentOfGoal: percentOfGoal, entryCount: samples.count)
                
                let previousCount = UserDefaults.standard.integer(forKey: "UDKey_entryCount")
                if previousCount != samples.count {
                    UserDefaults.standard.set(samples.count, forKey: "UDKey_entryCount")
                    UserDefaults.standard.set(sum, forKey: "UDKey_currentVolume")
                    UserDefaults.standard.set(percentOfGoal, forKey: "UDK_percentOfGoal")
                    UserDefaults.standard.set(Date(), forKey: "UDK_lastUpdated")
                    
                    for complication in CLKComplicationServer.sharedInstance().activeComplications ?? [] {
                        CLKComplicationServer.sharedInstance().reloadTimeline(for: complication)
                    }
                }
                
                completion(summary)
            }
        }
        
        HKHealthStore().execute(query)
    }
    
    func saveWaterSample(sampleSizeMilliliters: Double, date: Date) {
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
                print("Sample saved")
            }
        }
    }
}

extension HealthDataStore {
    enum HealthDataStoreError: Error {
        case typeInitializationFailed(message: String)
    }
}

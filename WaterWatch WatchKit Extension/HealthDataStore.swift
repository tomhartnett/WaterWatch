//
//  HealthDataStore.swift
//  WaterWatch WatchKit Extension
//
//  Created by Tom Hartnett on 11/22/19.
//  Copyright © 2019 Sleekible LLC. All rights reserved.
//

import Foundation
import HealthKit

class HealthDataStore {
    typealias AuthorizationStatus = HKAuthorizationStatus
    
    private var typesToWrite = [HKSampleType]()
    private var typesToRead = [HKObjectType]()
    
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
}

extension HealthDataStore {
    enum HealthDataStoreError: Error {
        case typeInitializationFailed(message: String)
    }
}

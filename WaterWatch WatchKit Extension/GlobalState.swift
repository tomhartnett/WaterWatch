//
//  GlobalState.swift
//  WaterWatch WatchKit Extension
//
//  Created by Tom Hartnett on 11/24/19.
//  Copyright © 2019 Sleekible LLC. All rights reserved.
//

import Foundation

enum PreferredUnit: Int {
    case milliliters
    case fluidOunces
}

class GlobalState: ObservableObject {
    @Published var showAddView: Bool
    @Published var showError: Bool
    @Published var showGoalEntry: Bool
    @Published var preferredUnit: PreferredUnit {
        didSet {
            UserDefaults.standard.set(preferredUnit.rawValue, forKey: "UDK_preferredUnit")
        }
    }
    @Published var goalMilliliters: Double {
        didSet {
            UserDefaults.standard.set(goalMilliliters, forKey: "UDK_goal")
        }
    }

    var errorMessage: String {
        didSet {
            showError = !errorMessage.isEmpty
        }
    }
    
    var goalFluidOunces: Double {
        let measurement = Measurement(value: goalMilliliters, unit: UnitVolume.milliliters)
        return measurement.converted(to: .fluidOunces).value
    }
    
    init() {
        errorMessage = ""
        showAddView = false
        showError = false
        showGoalEntry = false
        preferredUnit = .milliliters
        goalMilliliters = 3000.0
        
        let savedUnitRawValue = UserDefaults.standard.integer(forKey: "UDK_preferredUnit")
        if let savedUnit = PreferredUnit(rawValue: savedUnitRawValue) {
            preferredUnit = savedUnit
        }
        
        let savedGoalMilliliters = UserDefaults.standard.double(forKey: "UDK_goal")
        if savedGoalMilliliters > 0 {
            goalMilliliters = savedGoalMilliliters
        }
    }
}

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
    @Published var dailySummary: Summary
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
        
        let savedCount = UserDefaults.standard.integer(forKey: "UDKey_entryCount")
        let lastUpdated = UserDefaults.standard.object(forKey: "") as? Date ?? Date.distantPast
        
        if savedCount > 0 && Calendar.current.isDateInToday(lastUpdated) {
            let volume = UserDefaults.standard.double(forKey: "UDKey_currentVolume")
            let goal = UserDefaults.standard.double(forKey: "UDK_percentOfGoal")
            dailySummary = Summary(date: lastUpdated, volumeMilliliters: volume, percentOfGoal: goal, entryCount: savedCount)
        } else {
            dailySummary = Summary(date: Calendar.current.startOfDay(for: Date()),
            volumeMilliliters: 0,
            percentOfGoal: 0,
            entryCount: 0)
        }
        
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

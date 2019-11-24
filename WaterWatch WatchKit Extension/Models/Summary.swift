//
//  Summary.swift
//  WaterWatch WatchKit Extension
//
//  Created by Tom Hartnett on 11/22/19.
//  Copyright © 2019 Sleekible LLC. All rights reserved.
//

import Foundation

struct Summary {
    var date: Date
    var volumeMilliliters: Double
    var percentOfGoal: Double
    var entryCount: Int
}

extension Summary {
    var volumeLiters: Double {
        let measurement = Measurement(value: volumeMilliliters, unit: UnitVolume.milliliters)
        return measurement.converted(to: .liters).value
    }
    var volumeFluidOunces: Double {
        let measurement = Measurement(value: volumeMilliliters, unit: UnitVolume.milliliters)
        return measurement.converted(to: .fluidOunces).value
    }
    var volumeGallons: Double {
        let measurement = Measurement(value: volumeMilliliters, unit: UnitVolume.milliliters)
        return measurement.converted(to: .gallons).value
    }
}

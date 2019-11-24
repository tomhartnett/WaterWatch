//
//  ComplicationController.swift
//  WaterWatch WatchKit Extension
//
//  Created by Tom Hartnett on 11/21/19.
//  Copyright © 2019 Sleekible LLC. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        
        var currentVolume: Double = 0.0
        var percentOfGoal: Double = 0.0
        
        let lastUpdated = UserDefaults.standard.value(forKey: "UDK_lastUpdated") as? Date ?? Date.distantFuture
        if Calendar.current.isDateInToday(lastUpdated) {
            currentVolume = UserDefaults.standard.double(forKey: "UDKey_currentVolume")
            percentOfGoal = UserDefaults.standard.double(forKey: "UDK_percentOfGoal")
        }
        
        let displayGoal = String(format: "%.0f", percentOfGoal * 100)

        let volumeMilliliters = Measurement(value: currentVolume, unit: UnitVolume.milliliters)
        let displayVolume: String
        let preferredUnit = PreferredUnit(rawValue: UserDefaults.standard.integer(forKey: "UDK_preferredUnit"))
        if preferredUnit == PreferredUnit.fluidOunces {
            displayVolume = String(format: "%.0f oz", volumeMilliliters.converted(to: .fluidOunces).value)
        } else {
            displayVolume = String(format: "%.1f L", volumeMilliliters.converted(to: .liters).value)
        }
        
        if complication.family == .graphicCorner {
            let template = CLKComplicationTemplateGraphicCornerStackText()
            template.innerTextProvider = CLKSimpleTextProvider(text: "WATER: \(displayGoal)%")
            template.outerTextProvider = CLKSimpleTextProvider(text: "\(displayVolume)")
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        } else {
            handler(nil)
        }
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        
        if complication.family == .graphicCorner {
            let template = CLKComplicationTemplateGraphicCornerStackText()
            template.innerTextProvider = CLKSimpleTextProvider(text: "WATER: 57%")
            template.outerTextProvider = CLKSimpleTextProvider(text: "1.7 L")
            handler(template)
            return
        }
        handler(nil)
    }
    
}

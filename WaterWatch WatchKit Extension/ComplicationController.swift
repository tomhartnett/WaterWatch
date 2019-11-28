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
        
        let displayPercentOfGoal = String(format: "%.0f%%", percentOfGoal * 100)

        let volumeMilliliters = Measurement(value: currentVolume, unit: UnitVolume.milliliters)
        let displayVolume: String
        let preferredUnit = PreferredUnit(rawValue: UserDefaults.standard.integer(forKey: "UDK_preferredUnit"))
        if preferredUnit == PreferredUnit.fluidOunces {
            displayVolume = String(format: "%.0f oz", volumeMilliliters.converted(to: .fluidOunces).value)
        } else {
            displayVolume = String(format: "%.1f L", volumeMilliliters.converted(to: .liters).value)
        }
        
        switch complication.family {
        case .graphicCircular:
            let template = CLKComplicationTemplateGraphicCircularClosedGaugeText()
            template.centerTextProvider = CLKSimpleTextProvider(text: "💧")
            template.gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: UIColor.nowPlayingBlue(), fillFraction: Float(percentOfGoal))
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        case .graphicCorner:
            let template = CLKComplicationTemplateGraphicCornerStackText()
            template.innerTextProvider = CLKSimpleTextProvider(text: "WATER: \(displayPercentOfGoal)")
            template.innerTextProvider.tintColor = UIColor.nowPlayingBlue()
            template.outerTextProvider = CLKSimpleTextProvider(text: "\(displayVolume)")
            template.outerTextProvider.tintColor = UIColor.nowPlayingBlue()
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        case .graphicBezel:
            let template = CLKComplicationTemplateGraphicBezelCircularText()
            let circularTemplate = CLKComplicationTemplateGraphicCircularClosedGaugeText()
            circularTemplate.centerTextProvider = CLKSimpleTextProvider(text: "💧")
            circularTemplate.gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: UIColor.nowPlayingBlue(), fillFraction: Float(percentOfGoal))
            template.circularTemplate = circularTemplate
            template.textProvider = CLKSimpleTextProvider(text: "Water: \(displayVolume) - \(displayPercentOfGoal)")
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallRingText()
            template.textProvider = CLKSimpleTextProvider(text: "💧")
            template.fillFraction = Float(percentOfGoal)
            template.ringStyle = .closed
            template.tintColor = UIColor.nowPlayingBlue()
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: "\(displayPercentOfGoal)")
            template.line2TextProvider = CLKSimpleTextProvider(text: "\(displayVolume)")
            template.tintColor = UIColor.nowPlayingBlue()
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        default:
            handler(nil)
        }
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        
        let percentOfGoal = 50.0
        let displayPercentOfGoal = "50%"
        let preferredUnit = PreferredUnit(rawValue: UserDefaults.standard.integer(forKey: "UDK_preferredUnit"))
        let displayVolume: String
        if preferredUnit == PreferredUnit.fluidOunces {
            displayVolume = "50 oz"
        } else {
            displayVolume = "1.5 L"
        }
        
        switch complication.family {
        case .graphicCircular:
            let template = CLKComplicationTemplateGraphicCircularClosedGaugeText()
            template.centerTextProvider = CLKSimpleTextProvider(text: "💧")
            template.gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: UIColor.nowPlayingBlue(), fillFraction: Float(percentOfGoal))
            handler(template)
        case .graphicCorner:
            let template = CLKComplicationTemplateGraphicCornerStackText()
            template.innerTextProvider = CLKSimpleTextProvider(text: "WATER: \(displayPercentOfGoal)")
            template.innerTextProvider.tintColor = UIColor.nowPlayingBlue()
            template.outerTextProvider = CLKSimpleTextProvider(text: "\(displayVolume)")
            template.outerTextProvider.tintColor = UIColor.nowPlayingBlue()
            handler(template)
        case .graphicBezel:
            let template = CLKComplicationTemplateGraphicBezelCircularText()
            let circularTemplate = CLKComplicationTemplateGraphicCircularClosedGaugeText()
            circularTemplate.centerTextProvider = CLKSimpleTextProvider(text: "💧")
            circularTemplate.gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: UIColor.nowPlayingBlue(), fillFraction: Float(percentOfGoal))
            template.circularTemplate = circularTemplate
            template.textProvider = CLKSimpleTextProvider(text: "Water: \(displayVolume) - \(displayPercentOfGoal)")
            handler(template)
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallRingText()
            template.textProvider = CLKSimpleTextProvider(text: "💧")
            template.fillFraction = Float(percentOfGoal)
            template.ringStyle = .closed
            template.tintColor = UIColor.nowPlayingBlue()
            handler(template)
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallStackText()
            template.line1TextProvider = CLKSimpleTextProvider(text: "\(displayPercentOfGoal)")
            template.line2TextProvider = CLKSimpleTextProvider(text: "\(displayVolume)")
            template.tintColor = UIColor.nowPlayingBlue()
            handler(template)
        default:
            handler(nil)
        }
    }
    
}

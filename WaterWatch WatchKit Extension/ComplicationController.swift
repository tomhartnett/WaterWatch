//
//  ComplicationController.swift
//  WaterWatch WatchKit Extension
//
//  Created by Tom Hartnett on 11/21/19.
//  Copyright © 2019 Sleekible LLC. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {

    // MARK: - Complication Configuration

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: "complication",
                                      displayName: "WaterWatch",
                                      supportedFamilies: [
                                        .modularSmall,
                                        .circularSmall,
                                        .graphicCorner,
                                        .graphicBezel,
                                        .graphicCircular
                                      ])
        ]

        handler(descriptors)
    }

    // MARK: - Timeline Configuration
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        let now = Date()
        if let interval = Calendar.current.dateInterval(of: .day, for: now) {
            handler(interval.end)
        } else {
            handler(nil)
        }
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population

    func getTemplate(complication: CLKComplication,
                     fillFraction: Float,
                     displayPercentOfGoal: String,
                     displayVolume: String) -> CLKComplicationTemplate? {

        var template: CLKComplicationTemplate?

        switch complication.family {
        case .graphicCircular:
            template = CLKComplicationTemplateGraphicCircularClosedGaugeText(
                gaugeProvider: CLKSimpleGaugeProvider(style: .fill,
                                                      gaugeColor: UIColor.nowPlayingBlue(),
                                                      fillFraction: fillFraction),
                centerTextProvider: CLKSimpleTextProvider(text: "💧")
            )

        case .graphicCorner:
            let innerTextProvider = CLKSimpleTextProvider(text: "WATER: \(displayPercentOfGoal)")
            innerTextProvider.tintColor = UIColor.nowPlayingBlue()
            let outerTextProvider = CLKSimpleTextProvider(text: "\(displayVolume)")
            outerTextProvider.tintColor = UIColor.nowPlayingBlue()
            template = CLKComplicationTemplateGraphicCornerStackText(
                innerTextProvider: innerTextProvider,
                outerTextProvider: outerTextProvider
            )
        case .graphicBezel:
            let circularTemplate = CLKComplicationTemplateGraphicCircularClosedGaugeText(
                gaugeProvider: CLKSimpleGaugeProvider(style: .fill,
                                                      gaugeColor: UIColor.nowPlayingBlue(),
                                                      fillFraction: fillFraction),
                centerTextProvider: CLKSimpleTextProvider(text: "💧")
            )

            template = CLKComplicationTemplateGraphicBezelCircularText(
                circularTemplate: circularTemplate,
                textProvider: CLKSimpleTextProvider(text: "Water: \(displayVolume) - \(displayPercentOfGoal)")
            )

        case .circularSmall:
            template = CLKComplicationTemplateCircularSmallRingText(
                textProvider: CLKSimpleTextProvider(text: "💧"),
                fillFraction: fillFraction,
                ringStyle: .closed
            )
            template?.tintColor = UIColor.nowPlayingBlue()

        case .modularSmall:
            template = CLKComplicationTemplateModularSmallRingText(
                textProvider: CLKSimpleTextProvider(text: "💧"),
                fillFraction: fillFraction,
                ringStyle: .closed
            )

        default:
            break
        }

        return template
    }

    func getCurrentTimelineEntry(for complication: CLKComplication,
                                 withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void)
    {
        
        var currentVolume: Double = 0.0
        var percentOfGoal: Double = 0.0
        
        let lastUpdated = UserDefaults.standard.value(forKey: "UDK_lastUpdated") as? Date ?? Date.distantFuture
        if Calendar.current.isDateInToday(lastUpdated) {
            currentVolume = UserDefaults.standard.double(forKey: "UDKey_currentVolume")
            percentOfGoal = UserDefaults.standard.double(forKey: "UDK_percentOfGoal")
        }
        let fillFraction = Float(min(1.0, percentOfGoal))
        
        let displayPercentOfGoal = String(format: "%.0f%%", percentOfGoal * 100)

        let volumeMilliliters = Measurement(value: currentVolume, unit: UnitVolume.milliliters)
        let displayVolume: String
        let preferredUnit = PreferredUnit(rawValue: UserDefaults.standard.integer(forKey: "UDK_preferredUnit"))
        if preferredUnit == PreferredUnit.fluidOunces {
            displayVolume = String(format: "%.0f oz", volumeMilliliters.converted(to: .fluidOunces).value)
        } else {
            displayVolume = String(format: "%.1f L", volumeMilliliters.converted(to: .liters).value)
        }

        var entry: CLKComplicationTimelineEntry?

        if let template = getTemplate(complication: complication,
                                      fillFraction: fillFraction,
                                      displayPercentOfGoal: displayPercentOfGoal,
                                      displayVolume: displayVolume) {
            entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
        }

        handler(entry)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication,
                                      withHandler handler: @escaping (CLKComplicationTemplate?) -> Void)
    {
        
        let percentOfGoal = 0.5
        let fillFraction = Float(percentOfGoal)
        let displayPercentOfGoal = "50%"
        let preferredUnit = PreferredUnit(rawValue: UserDefaults.standard.integer(forKey: "UDK_preferredUnit"))
        let displayVolume: String
        if preferredUnit == PreferredUnit.fluidOunces {
            displayVolume = "50 oz"
        } else {
            displayVolume = "1.5 L"
        }
        
        let template = getTemplate(complication: complication,
                                   fillFraction: fillFraction,
                                   displayPercentOfGoal: displayPercentOfGoal,
                                   displayVolume: displayVolume)

        handler(template)
    }
    
}

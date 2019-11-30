//
//  AddView.swift
//  WaterWatch WatchKit Extension
//
//  Created by Tom Hartnett on 11/21/19.
//  Copyright © 2019 Sleekible LLC. All rights reserved.
//

import SwiftUI

struct GoalOuncesView: View {
    @Binding var isPresented: Bool
    @Binding var goalMilliliters: Int
    @State private var sampleSize = 100.0
    
    var body: some View {
        VStack {
            Text("\(sampleSize, specifier: "%.0f") oz")
                .padding(.all, 8.0)
                .font(.system(size: 28, weight: Font.Weight.semibold, design: Font.Design.rounded))
                .focusable(true)
                .digitalCrownRotation($sampleSize, from: 30.0, through: 128.0, by: 1.0, sensitivity: .medium, isContinuous: false, isHapticFeedbackEnabled: true)
            Button(action: {
                let measurement = Measurement(value: self.sampleSize, unit: UnitVolume.fluidOunces)
                let milliliters = measurement.converted(to: .milliliters).value
                self.goalMilliliters = Int(milliliters)
                self.isPresented = false
            }) {
                Text("Set")
                    .font(.system(size: 20, weight: Font.Weight.regular, design: Font.Design.rounded))
            }
        }.onAppear() {
            let measurement = Measurement(value: Double(self.goalMilliliters), unit: UnitVolume.milliliters)
            let goalOunces = measurement.converted(to: .fluidOunces).value
            self.sampleSize = goalOunces
        }
    }
}

struct GoalOuncesView_Previews: PreviewProvider {
    static var previews: some View {
        GoalOuncesView(isPresented: .constant(true), goalMilliliters: .constant(3000))
    }
}

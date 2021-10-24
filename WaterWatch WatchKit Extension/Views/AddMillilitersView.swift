//
//  AddView.swift
//  WaterWatch WatchKit Extension
//
//  Created by Tom Hartnett on 11/21/19.
//  Copyright © 2019 Sleekible LLC. All rights reserved.
//

import SwiftUI

struct AddMillilitersView: View {
    @EnvironmentObject var healthStore: HealthKitStore
    @Binding var isPresented: Bool
    @State private var sampleSize = 355.0
    
    var body: some View {
        VStack {
            Text("\(sampleSize, specifier: "%.0f") mL")
                .padding(.all, 8.0)
                .font(.system(size: 28, weight: Font.Weight.semibold, design: Font.Design.rounded))
                .focusable(true)
                .digitalCrownRotation($sampleSize, from: 25.0, through: 1000.0, by: 5.0, sensitivity: .medium, isContinuous: false, isHapticFeedbackEnabled: true)
            HStack {
                Button(action: {
                    self.sampleSize -= 25
                }) {
                    Image(systemName: "minus")
                }
                Button(action: {
                    self.sampleSize += 25
                }) {
                    Image(systemName: "plus")
                }
            }
            Button(action: {
                healthStore.saveWaterSample(sampleSizeMilliliters: self.sampleSize, date: Date())
                self.isPresented = false
            }) {
                Text("Add")
                    .font(.system(size: 20, weight: Font.Weight.regular, design: Font.Design.rounded))
            }
        }
    }
}

struct AddMillilitersView_Previews: PreviewProvider {
    static var previews: some View {
        AddMillilitersView(isPresented: .constant(true))
    }
}


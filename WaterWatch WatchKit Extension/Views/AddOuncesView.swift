//
//  AddOuncesView.swift
//  WaterWatch WatchKit Extension
//
//  Created by Tom Hartnett on 11/24/19.
//  Copyright © 2019 Sleekible LLC. All rights reserved.
//

import SwiftUI

struct AddOuncesView: View {
    @EnvironmentObject var healthStore: HealthKitStore
    @Binding var isPresented: Bool
    @State private var sampleSize = 12.0
    
    var body: some View {
        VStack {
            Text("\(sampleSize, specifier: "%.0f") oz")
                .padding(.all, 8.0)
                .font(.system(size: 28, weight: Font.Weight.semibold, design: Font.Design.rounded))
                .focusable(true)
                .digitalCrownRotation($sampleSize, from: 1.0, through: 128.0, by: 1.0, sensitivity: .medium, isContinuous: false, isHapticFeedbackEnabled: true)
            HStack {
                Button(action: {
                    self.sampleSize -= 2
                    if self.sampleSize <= 0 {
                        self.sampleSize = 1
                    }
                }) {
                    Image(systemName: "minus")
                }
                Button(action: {
                    self.sampleSize += 2
                    if self.sampleSize >= 128 {
                        self.sampleSize = 128
                    }
                }) {
                    Image(systemName: "plus")
                }
            }
            Button(action: {
                if self.sampleSize > 0 {
                    healthStore.saveWaterSample(sampleSizeFluidOunces: self.sampleSize, date: Date())
                }
                self.isPresented = false
            }) {
                Text("Add")
                    .font(.system(size: 20, weight: Font.Weight.regular, design: Font.Design.rounded))
            }
        }
    }
}


struct AddOuncesView_Previews: PreviewProvider {
    static var previews: some View {
        AddOuncesView(isPresented: .constant(true))
    }
}

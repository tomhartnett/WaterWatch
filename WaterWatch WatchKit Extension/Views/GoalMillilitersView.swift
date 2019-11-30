//
//  AddView.swift
//  WaterWatch WatchKit Extension
//
//  Created by Tom Hartnett on 11/21/19.
//  Copyright © 2019 Sleekible LLC. All rights reserved.
//

import SwiftUI

struct GoalMillilitersView: View {
    @Binding var isPresented: Bool
    @Binding var goalMilliliters: Int
    @State private var sampleSize = 3000.0
    
    var body: some View {
        VStack {
            Text("\(sampleSize, specifier: "%.0f") mL")
                .padding(.all, 8.0)
                .font(.system(size: 28, weight: Font.Weight.semibold, design: Font.Design.rounded))
                .focusable(true)
                .digitalCrownRotation($sampleSize, from: 1000.0, through: 4000.0, by: 100.0, sensitivity: .high, isContinuous: false, isHapticFeedbackEnabled: true)
            Button(action: {
                self.goalMilliliters = Int(self.sampleSize)
                self.isPresented = false
            }) {
                Text("Set")
                    .font(.system(size: 20, weight: Font.Weight.regular, design: Font.Design.rounded))
            }
        }.onAppear() {
            self.sampleSize = Double(self.goalMilliliters)
        }
    }
}

struct GoalMillilitersView_Previews: PreviewProvider {
    static var previews: some View {
        GoalMillilitersView(isPresented: .constant(true), goalMilliliters: .constant(3000))
    }
}


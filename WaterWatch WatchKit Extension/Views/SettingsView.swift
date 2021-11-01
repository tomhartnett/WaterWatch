//
//  SettingsView.swift
//  WaterWatch WatchKit Extension
//
//  Created by Tom Hartnett on 11/1/21.
//  Copyright © 2021 Sleekible LLC. All rights reserved.
//

import SwiftUI

struct RadioButtonView: View {
    var isSelected: Bool
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.primary, lineWidth: 2)
                .frame(width: 25, height: 25)

            Circle()
                .frame(width: 20, height: 20)
                .foregroundColor(isSelected ? .primary : .clear)
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var globalState: GlobalState
    @State private var isPresentingGoal = false

    var goalText: String {
        switch globalState.preferredUnit {
        case .milliliters:
            return String(format: "%.0f mL", globalState.goalMilliliters)
        case .fluidOunces:
            return String(format: "%.0f fl oz", globalState.goalFluidOunces)
        }
    }

    var body: some View {
        List {
            Button(action: {
                isPresentingGoal.toggle()
            }) {
                Text("Goal: \(goalText)")
            }

            HStack {
                RadioButtonView(isSelected: globalState.preferredUnit == .milliliters)
                Text("Liters (mL)")
                    .padding(.leading)
                Spacer()
            }
            .padding(.vertical)
            .onTapGesture {
                globalState.preferredUnit = PreferredUnit.milliliters
            }

            HStack {
                RadioButtonView(isSelected: globalState.preferredUnit == .fluidOunces)
                Text("Fluid Ounces (fl oz)")
                    .padding(.leading)
                Spacer()
            }
            .onTapGesture {
                globalState.preferredUnit = PreferredUnit.fluidOunces
            }
        }
        .sheet(isPresented: $isPresentingGoal) {
            if globalState.preferredUnit == PreferredUnit.fluidOunces {
                GoalOuncesView(goalMilliliters: $globalState.goalMilliliters)
            } else {
                GoalMillilitersView(goalMilliliters: $globalState.goalMilliliters)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(GlobalState())
    }
}

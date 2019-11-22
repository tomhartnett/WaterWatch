//
//  AddView.swift
//  WaterWatch WatchKit Extension
//
//  Created by Tom Hartnett on 11/21/19.
//  Copyright © 2019 Sleekible LLC. All rights reserved.
//

import SwiftUI

struct AddView: View {
    @Binding var isPresented: Bool
    @State private var sampleSize = 425.0
    
    var body: some View {
        VStack {
            Text("\(sampleSize, specifier: "%.0f") mL")
                .padding(.all, 8.0)
                .font(.system(size: 28, weight: Font.Weight.semibold, design: Font.Design.rounded))
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
                HealthDataStore().saveWaterSample(sampleSizeMilliliters: self.sampleSize, date: Date())
                self.isPresented = false
            }) {
                Text("Add")
                    .font(.system(size: 20, weight: Font.Weight.regular, design: Font.Design.rounded))
            }
        }
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView(isPresented: .constant(true))
    }
}


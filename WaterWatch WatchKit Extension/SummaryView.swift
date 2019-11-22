//
//  SummaryView.swift
//  WaterWatch WatchKit Extension
//
//  Created by Tom Hartnett on 11/21/19.
//  Copyright © 2019 Sleekible LLC. All rights reserved.
//

import SwiftUI

struct SummaryView: View {
    var body: some View {
        VStack {
            Text("Today")
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            Text("2.55 L / 0.67 gal")
            Text("6 servings")
            Button(action: {}) {
                Text("Add Entry")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            SummaryView()
            AddView()
        }
    }
}

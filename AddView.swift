//
//  AddView.swift
//  WaterWatch WatchKit Extension
//
//  Created by Tom Hartnett on 11/21/19.
//  Copyright © 2019 Sleekible LLC. All rights reserved.
//

import SwiftUI

struct AddView: View {
    var body: some View {
        VStack {
            Text("425 mL")
                .padding(.all, 8.0)
                .font(.system(size: 28, weight: Font.Weight.semibold, design: Font.Design.rounded))
            HStack {
                Button(action: {}) {
                    Image(systemName: "minus")
                }
                Button(action: {}) {
                    Image(systemName: "plus")
                }
            }
            Button(action: {}) {
                Text("Add")
                    .font(.system(size: 20, weight: Font.Weight.regular, design: Font.Design.rounded))
            }
        }
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView()
    }
}


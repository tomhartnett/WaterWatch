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
                .border(/*@START_MENU_TOKEN@*/Color.white/*@END_MENU_TOKEN@*/, width: 1)
                .font(.title)
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
            }
        }
    }
}

struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView()
    }
}


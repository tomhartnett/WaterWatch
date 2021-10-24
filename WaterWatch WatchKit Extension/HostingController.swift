//
//  HostingController.swift
//  WaterWatch WatchKit Extension
//
//  Created by Tom Hartnett on 11/21/19.
//  Copyright © 2019 Sleekible LLC. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<HomeView> {
    @StateObject var healthStore = HealthKitStore()

    override var body: HomeView {
        return HomeView()
    }
}

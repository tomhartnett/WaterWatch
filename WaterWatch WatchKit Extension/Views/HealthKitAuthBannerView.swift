//
//  HealthKitAuthBannerView.swift
//  Potion WatchKit Extension
//
//  Created by Tom Hartnett on 10/6/21.
//

import SwiftUI

struct HealthKitAuthBannerView: View {
    var status: HealthKitStore.AuthorizationStatus

    var systemImageName: String {
        switch status {
        case .notAvailable:
            return "heart.slash"
        case .notDetermined:
            return "questionmark.diamond"
        case .sharingDenied:
            return "heart.slash"
        case .sharingAuthorized:
            return "checkmark.circle"
        }
    }

    var authorizationMessage: String {
        switch status {
        case .notAvailable:
            return "Not Available"
        case .notDetermined:
            return "Not Determined"
        case .sharingDenied:
            return "Denied"
        case .sharingAuthorized:
            return "Authorized"
        }
    }

    var body: some View {
        if status != .sharingAuthorized {

            HStack {
                Image(systemName: systemImageName)
                    .font(.system(size: 28))
                    .foregroundColor(.secondary)

                VStack(alignment: .leading) {
                    Text("HealthKit Access")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(authorizationMessage)
                }
            }

        } else {
            EmptyView()
        }
    }
}

struct HealthKitAuthBannerView_Previews: PreviewProvider {
    static var previews: some View {
        HealthKitAuthBannerView(status: .notAvailable)
    }
}

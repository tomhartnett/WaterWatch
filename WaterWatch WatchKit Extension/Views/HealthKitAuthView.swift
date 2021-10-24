//
//  HealthKitAuthView.swift
//  Potion WatchKit Extension
//
//  Created by Tom Hartnett on 9/29/21.
//

import SwiftUI

struct HealthKitAuthView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var healthStore: HealthKitStore

    var authorizationImage: Image {
        switch healthStore.authorizationStatus {
        case .notAvailable:
            return Image(systemName: "heart.slash")
        case .notDetermined:
            return Image(systemName: "questionmark.diamond")
        case .sharingDenied:
            return Image(systemName: "heart.slash")
        case .sharingAuthorized:
            return Image(systemName: "checkmark.circle")
        }
    }

    var authorizationStatus: String {
        switch healthStore.authorizationStatus {
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

    var fontColor: Color {
        switch healthStore.authorizationStatus {
        case .notAvailable:
            return Color.yellow
        case .notDetermined:
            return Color.gray
        case .sharingDenied:
            return Color.red
        case .sharingAuthorized:
            return Color.green
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("HEALTHKIT ACCESS")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.top)

                HStack {
                    authorizationImage
                    Text(authorizationStatus)
                        .font(.system(size: 20))
                }
                .padding(.vertical)

                Divider()

                if healthStore.authorizationStatus == .sharingDenied {
                    Text("You must grant access on your iPhone in the Health app")
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top)
                } else if healthStore.authorizationStatus == .notAvailable {
                    Text("HealthKit not available on this device")
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top)
                } else if healthStore.authorizationStatus == .sharingAuthorized {
                    Text("This app is authorized to access HealthKit. To revoke access, use the Health app on your iPhone.")
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top)
                } else {
                    Button(action: {
                        // TODO: dismiss this form after requesting authorization if authorization was granted.
                        healthStore.requestAuthorization()
                    }) {
                        Text("Request access")
                    }
                    .padding(.top)
                    .disabled(healthStore.authorizationStatus != .notDetermined)
                }

                Text("This app saves water consumption data to HealthKit.")
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top)

                Spacer()
            }
        }
        .onAppear {
            healthStore.getAuthorizationStatus()
        }
    }
}

struct HealthKitHome_Previews: PreviewProvider {
    static var previews: some View {
        HealthKitAuthView()
            .environmentObject(HealthKitStore())
    }
}

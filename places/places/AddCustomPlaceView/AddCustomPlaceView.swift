//
//  AddCustomPlaceView.swift
//  places
//
//  Created by olia on 5/28/26.
//

import SwiftUI
import MapKit

struct AddCustomPlaceView: View {
    var body: some View {
        Map {
            Marker(coordinate: .init(latitude: 0, longitude: 0)) {
                Label("", systemImage: "mappin")
            }
        }
    }
}

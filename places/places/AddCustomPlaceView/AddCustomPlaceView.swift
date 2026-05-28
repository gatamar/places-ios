//
//  AddCustomPlaceView.swift
//  places
//
//  Created by olia on 5/28/26.
//

import SwiftUI
import MapKit

struct AddCustomPlaceView: View {
    private let viewModel = AddCustomPlaceViewModel()
    @State private var selectedLocationCoord: CLLocationCoordinate2D?

    var body: some View {
        MapReader { reader in
            Map {
                if let selectedLocationCoord = selectedLocationCoord {
                    Marker(coordinate: selectedLocationCoord) {
                        Label("", systemImage: "mappin")
                    }
                }
            }
            .onTapGesture(coordinateSpace: .local) { point in
                if let coord = reader.convert(point, from: .local) {
                    selectedLocationCoord = coord
                }
            }
        }
        .onChange(of: viewModel.currentLocationCoord, { _, newValue in
            selectedLocationCoord = newValue
        })
        .task {
            viewModel.loadCurrentLocation()
        }
    }
}

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

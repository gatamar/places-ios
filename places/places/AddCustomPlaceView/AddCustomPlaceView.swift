//
//  AddCustomPlaceView.swift
//  places
//
//  Created by olia on 5/28/26.
//

import SwiftUI
import MapKit

struct AddCustomPlaceView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLocationCoord: CLLocationCoordinate2D?
    @State private var viewModel: AddCustomPlaceViewModel
    init(dependencies: PlacesDependencies) {
        _viewModel = State(initialValue: AddCustomPlaceViewModel(dependencies: dependencies))
    }

    var body: some View {
        NavigationStack {
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
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.saveCustomChosenPlace(selectedLocationCoord)
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
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

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
    @State private var viewModel: AddCustomPlaceViewModel
    private let onSave: (Location?) -> Void
    init(
        dependencies: PlacesDependencies,
        onSave: @escaping (Location?) -> Void
    ) {
        _viewModel = State(initialValue: AddCustomPlaceViewModel(dependencies: dependencies))
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            MapReader { reader in
                Map(
                    bounds: .cityLevelZoom,
                    interactionModes: [.pan, .zoom]
                ) {
                    if let selectedLocationCoord = viewModel.selectedLocationCoord {
                        Marker(coordinate: selectedLocationCoord) {
                            Label("\(viewModel.selectedCity ?? "")", systemImage: "mappin")
                        }
                    }
                }
                .onTapGesture(coordinateSpace: .local) { point in
                    if let coord = reader.convert(point, from: .local) {
                        viewModel.selectedLocationCoord = coord
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Cancel")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            let savedLocation = await viewModel.saveSelectedPlace()
                            dismiss()
                            onSave(savedLocation)
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            
                    }
                    .disabled(viewModel.selectedLocationCoord == nil)
                    .accessibilityHidden(viewModel.selectedLocationCoord == nil)
                    .accessibilityLabel("Choose \(viewModel.selectedCity ?? "place")")
                    .accessibilityHint("Complete custom location selection")
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

private extension MapCameraBounds {
    static var cityLevelZoom: Self {
        .init(minimumDistance: 15_000)
    }
}

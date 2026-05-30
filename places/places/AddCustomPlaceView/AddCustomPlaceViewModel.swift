//
//  AddCustomPlaceViewModel.swift
//  places
//
//  Created by olia on 5/28/26.
//

import Observation
import CoreLocation
import SwiftUI
import os

@MainActor @Observable
final class AddCustomPlaceViewModel {
    private let logger = Logger.make(for: .viewModel(.addCustomPlace))

    @MainActor var currentLocationCoord: CLLocationCoordinate2D {
        service.currentLocationCoord
    }
    
    var locationsRepository: LocationRepository {
        dependencies.locationsRepository
    }

    private let dependencies: PlacesDependencies
    private let service: CurrentLocationService
    init(
        dependencies: PlacesDependencies,
        service: CurrentLocationService = CurrentLocationServiceImpl()
    ) {
        self.dependencies = dependencies
        self.service = service
    }

    func loadCurrentLocation() {
        service.start()
    }
    
    func saveCustomChosenPlace(_ coord: CLLocationCoordinate2D?) {
        logger.debug("save custom place")
        guard let coord else {
            logger.error("nothing to save")
            return
        }
        locationsRepository.appendCustom(location: Location(coord))
        logger.debug("custom place saved")
    }
}

private extension Location {
    init(_ coord: CLLocationCoordinate2D) {
        self.init(
            name: nil,
            latitude: coord.latitude,
            longitude: coord.longitude,
            isCustom: true
        )
    }
}

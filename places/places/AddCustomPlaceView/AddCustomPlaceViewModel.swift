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

    @MainActor var currentLocationCoord: CLLocationCoordinate2D? {
        currentLocationService.currentLocationCoord
    }
    private var locationsRepository: LocationRepository {
        dependencies.locationsRepository
    }
    private var locationNameDetector: LocationNameDetector {
        dependencies.locationNameDetector
    }
    private var currentLocationService: CurrentLocationService {
        dependencies.currentLocationService
    }
    private let dependencies: PlacesDependencies
    init(dependencies: PlacesDependencies) {
        self.dependencies = dependencies
    }

    func loadCurrentLocation() {
        currentLocationService.startDetectingCurrentLocation()
    }
    
    func saveCustomChosenPlace(_ coord: CLLocationCoordinate2D?) {
        Task {
            await saveCustomChosenPlaceAsync(coord)
        }
    }

    private func saveCustomChosenPlaceAsync(_ coord: CLLocationCoordinate2D?) async {
        logger.debug("save custom place")
        guard let coord else {
            logger.error("nothing to save")
            return
        }
        let name = await locationNameDetector.detectLocationName(by: coord)
        locationsRepository.appendCustom(location: Location(coord, name: name))
        logger.debug("custom place saved")
    }
}

private extension Location {
    init(_ coord: CLLocationCoordinate2D, name: String?) {
        self.init(
            id: UUID().uuidString,
            name: name,
            latitude: coord.latitude,
            longitude: coord.longitude,
            isCustom: true
        )
    }
}

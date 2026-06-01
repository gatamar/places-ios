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
    private var nameDetectionTask: Task<Void, Never>?

    private(set) var selectedCity: String?
    var selectedLocationCoord: CLLocationCoordinate2D? {
        didSet {
            selectedCity = nil
            detectNameOfSelectedCity()
        }
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
        
        withObservationTracking({
            _ = currentLocationService.currentLocationCoord
        }, onChange: {
            Task { @MainActor [weak self] in
                guard let self else { return }
                if selectedLocationCoord == nil {
                    logger.debug("setting selected location to the current one")
                    selectedLocationCoord = currentLocationService.currentLocationCoord
                } else {
                    logger.debug("ignoring current detected location because the user was faster")
                }
            }
        })
    }
    
    func saveSelectedPlace() {
        Task {
            await saveCustomChosenPlaceAsync(selectedLocationCoord)
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
    
    private func detectNameOfSelectedCity() {
        guard let coord = selectedLocationCoord else { return }
        if nameDetectionTask != nil {
            logger.debug("cancelling the existing task in favour of the new one")
            nameDetectionTask?.cancel()
        }
        nameDetectionTask = Task { [weak self] in
            guard let self else { return }
            let name = await self.locationNameDetector.detectLocationName(by: coord)
            self.selectedCity = name
            self.nameDetectionTask = nil
        }
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

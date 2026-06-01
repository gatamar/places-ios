//
//  PlacesListViewModel.swift
//  places
//
//  Created by olia on 5/27/26.
//

import Observation
import Foundation
import os
import UIKit // for UIApplication.shared.openURL
import SwiftUI
import CoreLocation

@MainActor @Observable
final class PlacesListViewModel {
    private(set) var isFetchingData: Bool = false
    var locations: [Location] {
        locationsRepository.locations
            .filter { $0.name != nil }
            .sorted()
    }
    var userFacingError: UserFacingError?
    
    private let logger = Logger.make(for: .viewModel(.placesList))
    private var locationsRepository: LocationRepository {
        dependencies.locationsRepository
    }
    private var placesNavigator: PlacesNavigator {
        dependencies.placesNavigator
    }
    private var locationNameDetector: LocationNameDetector {
        dependencies.locationNameDetector
    }
    private let dependencies: PlacesDependencies
    init(dependencies: PlacesDependencies) {
        self.dependencies = dependencies
    }
    
    func name(for location: Location) -> String {
        guard let name = location.name else {
            logger.error("location name missing: lat=\(location.latitude) long=\(location.longitude) isCustom=\(location.isCustom)")
            return "untitled"
        }
        return name
    }

    func fetchData() async {
        isFetchingData = true
        observeLocationRepoErrors()
        await locationsRepository.fetchFromBackend()
        isFetchingData = false
        await backfillUnnamedLocationsIfNeeded()
    }
    
    func handleTap(on location: Location) {
        logger.debug("handle tap")
        guard placesNavigator.openPlace(location) else {
            userFacingError = UserFacingError(message: "Please install the Wiki app in order to learn more about this place!")
            return
        }
    }
    
    // MARK: Private
    private func observeLocationRepoErrors() {
        withObservationTracking {
            _ = locationsRepository.latestFetchError
        } onChange: {
            Task { @MainActor [weak self] in
                guard let self else { return }
                if let errorMessage = locationsRepository.latestFetchError?.description {
                    userFacingError = UserFacingError(message: errorMessage)
                }

                // yeah, Apple could do better :)
                // in case you don't like this recursive pattern, see https://github.com/swiftlang/swift-evolution/blob/main/proposals/0395-observability.md
                self.observeLocationRepoErrors()
            }
        }
    }
    
    private func backfillUnnamedLocationsIfNeeded() async {
        let locationsToBackfill = locationsRepository.locations
            .filter {
                $0.name == nil
                && !$0.isCustom // custom locations should have reverse geocoding applied
            }
        let backfilled = await locationNameDetector.detectNames(for: locationsToBackfill)
        locationsRepository.updateExisting(locations: backfilled)
    }
}

extension Location: Comparable {
    static func < (lhs: Location, rhs: Location) -> Bool {
        guard lhs.isCustom == rhs.isCustom else {
            return lhs.isCustom
        }
        
        guard let lhsName = lhs.name else {
            return false
        }
        
        guard let rhsName = rhs.name else {
            return false
        }
        
        return lhsName.localizedCaseInsensitiveCompare(rhsName) == .orderedAscending
    }
}

struct UserFacingError: LocalizedError {
    let message: String

    var errorDescription: String? {
        message
    }
}

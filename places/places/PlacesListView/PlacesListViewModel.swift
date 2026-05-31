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

@MainActor @Observable
final class PlacesListViewModel {
    private(set) var isFetchingData: Bool = false
    var locations: [Location] {
        locationsRepository.locations.sorted()
    }
    var userFacingError: UserFacingError?
    
    private let logger = Logger.make(for: .viewModel(.placesList))
    private var locationsRepository: LocationRepository {
        dependencies.locationsRepository
    }
    private var placesNavigator: PlacesNavigator {
        dependencies.placesNavigator
    }
    private let dependencies: PlacesDependencies
    init(dependencies: PlacesDependencies) {
        self.dependencies = dependencies
    }
    
    func fetchData() async {
        isFetchingData = true
        observeLocationRepoErrors()
        await locationsRepository.fetchFromBackend()
        isFetchingData = false
    }
    
    func handleTap(on location: Location) {
        logger.debug("handle tap")
        guard placesNavigator.openPlace(location) else {
            userFacingError = UserFacingError(message: "Please install the Wiki app in order to learn more about this place!")
            return
        }
    }
    
    // MARK: Private
    func observeLocationRepoErrors() {
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

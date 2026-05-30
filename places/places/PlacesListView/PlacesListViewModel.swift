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
    private let logger = Logger.make(for: .viewModel(.placesList))
    
    var locationsRepository: LocationRepository {
        dependencies.locationsRepository
    }

    var locations: [Location] {
        locationsRepository.locations
    }
    var errorText: String? {
        locationsRepository.latestFetchError?.description
    }
    
    var placesNavigator: PlacesNavigator {
        dependencies.placesNavigator
    }

    private let dependencies: PlacesDependencies
    init(dependencies: PlacesDependencies) {
        self.dependencies = dependencies
    }
    
    func fetchData() async {
        await locationsRepository.fetchFromBackend()
    }
    
    func handleTap(on location: Location) {
        logger.debug("handle tap")
        guard placesNavigator.openPlace(location) else {
            // TODO: show an error
            return
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

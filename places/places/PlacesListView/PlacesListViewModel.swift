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

@MainActor @Observable
final class PlacesListViewModel {
    private let logger = Logger.make(for: .viewModel(.placesList))
    private let placesNavigator: PlacesNavigator
    private let locationsRepository: LocationRepository

    var locations: [Location] {
        locationsRepository.locations
    }
    var errorText: String? {
        locationsRepository.latestFetchError?.description
    }
    
    init(
        placesNavigator: PlacesNavigator = UIApplication.shared,
        locationsRepository: LocationRepository = LocationRepositoryImpl()
    ) {
        self.placesNavigator = placesNavigator
        self.locationsRepository = locationsRepository
    }
    
    func fetchData() async {
        await locationsRepository.fetchFromBackend()
    }
    
    func handleTap(on location: Location) {
        logger.debug("handle tap")
        placesNavigator.openPlace(location)
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

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
    private let locationsAPI: LocationsAPI
    private let placesNavigator: PlacesNavigator

    private(set) var locations: [Location] = []
    private(set) var errorText: String?
    
    init(
        locationsAPI: LocationsAPI = LocationsAPIImpl(),
        placesNavigator: PlacesNavigator = UIApplication.shared
    ) {
        self.locationsAPI = locationsAPI
        self.placesNavigator = placesNavigator
    }
    
    func fetchData() async {
        logger.debug("start fetching data")
        switch await locationsAPI.fetch() {
        case .success(let locations):
            logger.debug("data fetched successfully")
            self.locations = locations.map(Location.init).sorted()
            self.errorText = nil
        case .failure(let error):
            // TODO: add proper Error handling instead of localizedDescription!
            logger.error("failed to fetch data: \(error.localizedDescription)")
            self.errorText = error.localizedDescription
            self.locations = []
        }
    }
    
    func handleTap(on location: Location) {
        logger.debug("handle tap")
        placesNavigator.openPlace(location)
    }
}

private extension Location {
    init(with dto: LocationDTO) {
        self.init(
            name: dto.name,
            latitude: dto.lat,
            longitude: dto.long,
            isCustom: false
        )
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

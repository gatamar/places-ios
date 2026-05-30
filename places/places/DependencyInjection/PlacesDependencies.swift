//
//  PlacesDependencies.swift
//  places
//
//  Created by olia on 5/30/26.
//

import UIKit // for UIApplication.shared.openURL
import os

final class PlacesDependencies {
    let locationsRepository: LocationRepository
    let placesNavigator: PlacesNavigator
    let currentLocationService: CurrentLocationService
    
    init(
        locationsRepository: LocationRepository = LocationRepositoryImpl(),
        placesNavigator: PlacesNavigator = UIApplication.shared,
        currentLocationService: CurrentLocationService = CurrentLocationServiceImpl()
    ) {
        self.locationsRepository = locationsRepository
        self.placesNavigator = placesNavigator
        self.currentLocationService = currentLocationService
    }
}

private let logger = Logger.make(for: .navigator)
extension UIApplication: PlacesNavigator {
    func openPlace(_ location: Location) {
        let url = PlacesDeeplinkFormatter.makeDeeplinkURL(for: location)
        logger.debug("Opening deeplink: \(url)")
        open(url) { opened in
            if !opened {
                logger.error("Failed to open \(url)")
            }
        }
    }
}

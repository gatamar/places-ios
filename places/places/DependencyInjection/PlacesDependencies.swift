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
    let locationNameDetector: LocationNameDetector
    
    init(
        locationsRepository: LocationRepository = LocationRepositoryImpl(),
        placesNavigator: PlacesNavigator = UIApplication.shared,
        currentLocationService: CurrentLocationService = CurrentLocationServiceImpl(),
        locationNameDetector: LocationNameDetector = LocationNameDetectorImpl()
    ) {
        self.locationsRepository = locationsRepository
        self.placesNavigator = placesNavigator
        self.currentLocationService = currentLocationService
        self.locationNameDetector = locationNameDetector
    }
}

private let logger = Logger.make(for: .navigator)
extension UIApplication: PlacesNavigator {
    func openPlace(_ location: Location) -> Bool {
        let url = PlacesDeeplinkFormatter.makeDeeplinkURL(for: location)
        guard canOpenURL(url) else {
            logger.error("Deeplink not supported: \(url)")
            return false
        }
        logger.debug("Opening deeplink: \(url)")
                
        open(url)
        return true
    }
}

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
        placesNavigator: PlacesNavigator = PlacesNavigatorImpl(),
        currentLocationService: CurrentLocationService = CurrentLocationServiceImpl(),
        locationNameDetector: LocationNameDetector = LocationNameDetectorImpl()
    ) {
        self.locationsRepository = locationsRepository
        self.placesNavigator = placesNavigator
        self.currentLocationService = currentLocationService
        self.locationNameDetector = locationNameDetector
    }
}

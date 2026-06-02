//
//  CurrentLocationService.swift
//  places
//
//  Created by olia on 5/28/26.
//

import CoreLocation
import os

protocol CurrentLocationService {
    @MainActor var currentLocationCoord: CLLocationCoordinate2D? { get }
    func startDetectingCurrentLocation()
}

@Observable
final class CurrentLocationServiceImpl: NSObject, CurrentLocationService, CLLocationManagerDelegate {
    private let logger = Logger.make(for: .service(.currentLocation))

    @MainActor private(set) var currentLocationCoord: CLLocationCoordinate2D?
    
    private let locationManager: CLLocationManager
    init(locationManager: CLLocationManager = .init()) {
        self.locationManager = locationManager
    }
    
    func startDetectingCurrentLocation() {
        logger.debug("load current location")
        if locationManager.delegate == nil {
            logger.debug("set location manager delegate")
            locationManager.delegate = self
        }

        logger.debug("request authorization")
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        logger.debug("manager did update locations")
        guard let receivedLocation = locations.first?.coordinate else {
            return
        }
        Task { @MainActor in
            currentLocationCoord = receivedLocation
            logger.debug("stop updating current location")
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        logger.error("manager failed with error: \(error)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        logger.debug("manager changed authorization: \(manager.authorizationStatus.rawValue)")

        switch manager.authorizationStatus {
        case .notDetermined:
            break
        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
}

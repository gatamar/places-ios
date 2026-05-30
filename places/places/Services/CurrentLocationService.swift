//
//  CurrentLocationService.swift
//  places
//
//  Created by olia on 5/28/26.
//

import CoreLocation
import os

protocol CurrentLocationService {
    @MainActor var currentLocationCoord: CLLocationCoordinate2D { get }
    func startDetectingCurrentLocation()
    func detectLocationName(by coord: CLLocationCoordinate2D) async -> String?
}

@Observable
final class CurrentLocationServiceImpl: NSObject, CurrentLocationService, CLLocationManagerDelegate {
    private let logger = Logger.make(for: .service(.currentLocation))

    @MainActor private(set) var currentLocationCoord: CLLocationCoordinate2D = .init(latitude: 0, longitude: 0)
    
    private let geocoder = CLGeocoder()
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
    
    func detectLocationName(by coord: CLLocationCoordinate2D) async -> String? {
        logger.debug("geocode")
        var placemark: CLPlacemark?
        do {
            placemark = try await geocoder.reverseGeocodeLocation(
                .init(
                    latitude: coord.latitude,
                    longitude: coord.longitude
                )
            ).first
        } catch {
            logger.error("failed to perform reverse geocoding: \(error)")
        }
        
        return placemark?.locality
    }

    // MARK: CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        logger.error("manager did update locations")
        currentLocationCoord = locations.first!.coordinate
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

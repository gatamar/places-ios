//
//  LocationNameDetector.swift
//  places
//
//  Created by olia on 6/1/26.
//

import CoreLocation
import os

protocol LocationNameDetector {
    func detectLocationName(by coord: CLLocationCoordinate2D) async -> String?
    func detectNames(for locations: [Location]) async -> [Location]
}

final class LocationNameDetectorImpl: LocationNameDetector {
    private let logger = Logger.make(for: .service(.nameDetector))
    private let geocoder = CLGeocoder()
    
    func detectLocationName(by coord: CLLocationCoordinate2D) async -> String? {
        logger.debug("start reverse geocoding")
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
    
    func detectNames(for locations: [Location]) async -> [Location] {
        guard !locations.isEmpty else { return [] }
        return await withTaskGroup(of: Location.self) { group in
            for location in locations {
                group.addTask { [weak self] in
                    guard let self else { return location }
                    let name = await self.detectLocationName(by: .init(with: location))
                    return Location(
                        id: location.id,
                        name: name,
                        latitude: location.latitude,
                        longitude: location.longitude,
                        isCustom: location.isCustom
                    )
                }
            }
            var detected = [Location]()

            for await value in group {
                detected.append(value)
            }

            return detected
        }
    }
}

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
    private enum Constants {
        static let maxConcurrentGeocodeTasks = 4
    }
    private let logger = Logger.make(for: .service(.nameDetector))
    
    func detectLocationName(by coord: CLLocationCoordinate2D) async -> String? {
        await CLGeocoder().detectLocationName(by: coord, logger: logger)
    }
    
    func detectNames(for locations: [Location]) async -> [Location] {
        guard !locations.isEmpty else { return [] }
        return await withTaskGroup(of: Location.self) { group in
            var addedTasks = 0
            for location in locations {
                if addedTasks > Constants.maxConcurrentGeocodeTasks {
                    logger.debug("task cap reached, await for the next one")
                    _ = await group.next()
                }
                addedTasks += 1
                group.addTask { [logger] in
                    logger.debug("add a new task")

                    let name = await CLGeocoder().detectLocationName(
                        by: .init(with: location),
                        logger: logger
                    )
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

private extension CLGeocoder {
    func detectLocationName(
        by coord: CLLocationCoordinate2D,
        logger: os.Logger
    ) async -> String? {
        logger.debug("start reverse geocoding")
        var placemark: CLPlacemark?
        do {
            placemark = try await reverseGeocodeLocation(
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
}

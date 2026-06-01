//
//  LocationRepository.swift
//  places
//
//  Created by olia on 5/30/26.
//

import os
import Observation
import Foundation

protocol LocationRepository: Observable {
    var locations: [Location] { get }
    var latestFetchError: LocationFetchError? { get }

    func fetchFromBackend() async
    func appendCustom(location: Location)
    func updateExisting(locations: [Location])
}

@Observable
final class LocationRepositoryImpl: LocationRepository {
    private let logger = Logger.make(for: .repository(.location))
    private(set) var locations: [Location] = []
    private(set) var latestFetchError: LocationFetchError?
    private let api: LocationsAPI

    init(api: LocationsAPI = LocationsAPIImpl()) {
        self.api = api
    }
    
    func fetchFromBackend() async {
        logger.debug("start fetching data")
        switch await api.fetch() {
        case .success(let locations):
            logger.debug("data fetched successfully")
            self.locations = locations.map(Location.init)
            self.latestFetchError = nil
        case .failure(let error):
            logger.error("failed to fetch data: \(error)")
            self.latestFetchError = error
            self.locations = []
        }
    }
    
    func appendCustom(location: Location) {
        logger.debug("append location")
        locations.append(location)
    }
    
    func updateExisting(locations: [Location]) {
        logger.debug("update existing")
        
        for location in locations {
            if let index = self.locations.firstIndex(where: { $0.id == location.id}) {
                self.locations[index] = location
            }
        }
    }
}

private extension Location {
    init(with dto: LocationDTO) {
        self.init(
            id: UUID().uuidString,
            name: dto.name,
            latitude: dto.lat,
            longitude: dto.long,
            isCustom: false
        )
    }
}


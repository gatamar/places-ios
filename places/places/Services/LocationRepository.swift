//
//  LocationRepository.swift
//  places
//
//  Created by olia on 5/30/26.
//

import os
import Observation

protocol LocationRepository: Observable {
    var locations: [Location] { get }
    var latestFetchError: LocationFetchError? { get }

    func fetchFromBackend() async
    func appendCustom(location: Location)
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


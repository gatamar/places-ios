//
//  LocationsAPI.swift
//  places
//
//  Created by olia on 5/27/26.
//

import Foundation

// MARK: - API

protocol LocationsAPI {
    func fetch() async -> Result<[LocationDTO], Error>
}

final class LocationsAPIImpl: LocationsAPI {
    private let decoder = JSONDecoder()

    func fetch() async -> Result<[LocationDTO], Error> {
        let url = URL(string: "https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/main/locations.json")!
        let request = URLRequest(url: url)
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let result = try decoder.decode(LocationsResponse.self, from: data)
            return .success(result.locations)
        } catch {
            return .failure(error)
        }
    }
}

// MARK: - DTO

private struct LocationsResponse: Decodable {
    let locations: [LocationDTO]
}

struct LocationDTO: Decodable {
    let name: String?
    let lat: Double
    let long: Double
}

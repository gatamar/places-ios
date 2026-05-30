//
//  LocationsAPI.swift
//  places
//
//  Created by olia on 5/27/26.
//

import Foundation

// MARK: - Error

enum LocationFetchError: Error, CustomStringConvertible {
    case network(Error)
    case decoding(Error)
    
    // TODO: add proper Error handling instead of localizedDescription!
    var description: String {
        switch self {
        case .network(let error):
            return "network: " + error.localizedDescription
        case .decoding(let error):
            return "decoding: " + error.localizedDescription
        }
    }
}

// MARK: - API

protocol LocationsAPI {
    func fetch() async -> Result<[LocationDTO], LocationFetchError>
}

final class LocationsAPIImpl: LocationsAPI {
    private let decoder = JSONDecoder()

    func fetch() async -> Result<[LocationDTO], LocationFetchError> {
        let url = URL(string: "https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/main/locations.json")!
        let request = URLRequest(url: url)
        var data: Data
        do {
            data = try await URLSession.shared.data(for: request).0
        } catch {
            return .failure(.network(error))
        }
        
        do {
            let result = try decoder.decode(LocationsResponse.self, from: data)
            return .success(result.locations)
        } catch {
            return .failure(.decoding(error))
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

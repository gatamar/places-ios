//
//  PlacesDeeplinkFormatter.swift
//  places
//
//  Created by olia on 5/28/26.
//

import Foundation

enum PlacesDeeplinkFormatter {
    static func makeDeeplinkURL(for location: Location) -> URL {
        var wiki = URLComponents()
        wiki.scheme = "wikipedia"
        wiki.host = "places"

        var coord = URLComponents()
        coord.queryItems = location.toQueryItems
        
        wiki.queryItems = [
            URLQueryItem(name: "WMFCoord", value: coord.query)
        ]
        let url = wiki.url!
        return url
    }
}

private extension Location {
    var toQueryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "long", value: String(long)),
            name.flatMap { URLQueryItem(name: "name", value: $0) }
        ].compactMap { $0 }
    }
}

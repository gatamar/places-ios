//
//  Location.swift
//  places
//
//  Created by olia on 5/28/26.
//

import Foundation
import CoreLocation

struct Location: Hashable, Identifiable {
    let id: String
    let name: String?
    let latitude: Double
    let longitude: Double
    let isCustom: Bool
}

extension CLLocationCoordinate2D {
    init(with location: Location) {
        self.init(
            latitude: location.latitude,
            longitude: location.longitude
        )
    }
}

extension Location {
    func withUpdatedName(_ name: String?) -> Self {
        .init(
            id: self.id,
            name: name,
            latitude: self.latitude,
            longitude: self.longitude,
            isCustom: self.isCustom
        )
    }
}

//
//  Location.swift
//  places
//
//  Created by olia on 5/28/26.
//

import Foundation

struct Location: Hashable {
    let name: String?
    let latitude: Double
    let longitude: Double
    let isCustom: Bool
}

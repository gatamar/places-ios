//
//  Logger.swift
//  places
//
//  Created by olia on 5/28/26.
//

import os

enum PlacesLogCategory: String {
    case viewModel
    case navigator
}

extension Logger {
    static func make(for category: PlacesLogCategory) -> Self {
        Logger(subsystem: "com.gatamar.places", category: category.rawValue)
    }
}

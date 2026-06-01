//
//  Logger.swift
//  places
//
//  Created by olia on 5/28/26.
//

import os

enum PlacesLogCategory: CustomStringConvertible {
    enum ViewModel: String {
        case addCustomPlace
        case placesList
    }
    enum Service: String {
        case currentLocation
        case nameDetector
    }
    enum Repository: String {
        case location
    }
    case viewModel(ViewModel)
    case navigator
    case repository(Repository)
    case service(Service)
    
    var description: String {
        switch self {
        case .viewModel(let model):
            return "viewModel.\(model.rawValue)"
        case .navigator:
            return "navigator"
        case .repository(let repository):
            return "repository.\(repository.rawValue)"
        case .service(let service):
            return "service.\(service.rawValue)"
        }
    }
}

extension Logger {
    static func make(for category: PlacesLogCategory) -> Self {
        Logger(subsystem: "com.gatamar.places", category: category.description)
    }
}

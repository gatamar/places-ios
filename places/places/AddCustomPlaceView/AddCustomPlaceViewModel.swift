//
//  AddCustomPlaceViewModel.swift
//  places
//
//  Created by olia on 5/28/26.
//

import Observation
import CoreLocation

@MainActor @Observable
final class AddCustomPlaceViewModel {
    @MainActor var currentLocationCoord: CLLocationCoordinate2D {
        service.currentLocationCoord
    }
    
    private let service: CurrentLocationService
    init(service: CurrentLocationService = CurrentLocationServiceImpl()) {
        self.service = service
    }

    func loadCurrentLocation() {
        service.start()
    }
}

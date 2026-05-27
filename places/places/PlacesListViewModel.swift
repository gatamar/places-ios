//
//  PlacesListViewModel.swift
//  places
//
//  Created by olia on 5/27/26.
//

import Observation
import Foundation

@MainActor @Observable
final class PlacesListViewModel {
    private(set) var locations: [Location] = []
    private(set) var errorText: String?
    
    private let locationsAPI: LocationsAPI
    init(locationsAPI: LocationsAPI = LocationsAPIImpl()) {
        self.locationsAPI = locationsAPI
    }
    
    func fetchData() async {
        switch await locationsAPI.fetch() {
        case .success(let locations):
            self.locations = locations
            self.errorText = nil
        case .failure(let error):
            self.errorText = error.localizedDescription
            self.locations = []
        }
    }
    
    func handleTap(on location: Location) {
        // TODO: navigate to the Wiki app via a deeplink
    }
}

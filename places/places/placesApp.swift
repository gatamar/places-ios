//
//  placesApp.swift
//  places
//
//  Created by olia on 5/27/26.
//

import SwiftUI

@main
struct placesApp: App {
    @State private var dependencies = PlacesDependencies()

    var body: some Scene {
        WindowGroup {
            PlacesListView(dependencies: dependencies)
        }
    }
}

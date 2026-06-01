//
//  PlacesNavigator.swift
//  places
//
//  Created by olia on 6/1/26.
//

import os
import UIKit

protocol PlacesNavigator {
    func openPlace(_ location: Location) -> Bool
}

final class PlacesNavigatorImpl: PlacesNavigator {
    private let logger = Logger.make(for: .navigator)

    func openPlace(_ location: Location) -> Bool {
        guard let url = PlacesDeeplinkFormatter.makeDeeplinkURL(for: location) else {
            logger.error("Failed to create a deeplink url")
            return false
        }

        guard UIApplication.shared.canOpenURL(url) else {
            logger.error("Deeplink not supported: \(url)")
            return false
        }
        logger.debug("Opening deeplink: \(url)")
                
        UIApplication.shared.open(url, options: [:])
        return true
    }
}

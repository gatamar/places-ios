//
//  PlacesNavigator.swift
//  places
//
//  Created by olia on 5/28/26.
//

import os
import UIKit // for UIApplication.shared.openURL

private let logger = Logger.make(for: .navigator)

protocol PlacesNavigator {
    func openPlace(_ location: Location)
}

extension UIApplication: PlacesNavigator {
    func openPlace(_ location: Location) {
        let url = PlacesDeeplinkFormatter.makeDeeplinkURL(for: location)
        logger.debug("Opening deeplink: \(url)")
        open(url) { opened in
            if !opened {
                logger.error("Failed to open \(url)")
            }
        }
    }
}

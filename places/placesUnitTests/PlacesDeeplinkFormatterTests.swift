//
//  PlacesDeeplinkFormatterTests.swift
//  placesUnitTests
//
//  Created by olia on 5/28/26.
//

import XCTest
@testable import places

final class PlacesDeeplinkFormatterTests: XCTestCase {
    func testExample() throws {
        let location = Location(name: "Test", lat: 0.00023, long: -0.040)
        let url = PlacesDeeplinkFormatter.makeDeeplinkURL(for: location)
        XCTAssertEqual(
            url.absoluteString,
            "wikipedia://places?WMFCoord=lat%3D0.00023%26long%3D-0.04%26name%3DTest"
        )
    }
}

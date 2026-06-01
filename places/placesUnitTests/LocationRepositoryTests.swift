//
//  LocationRepositoryTests.swift
//  places
//
//  Created by olia on 5/31/26.
//

import XCTest
@testable import places

final class LocationRepositoryTests: XCTestCase {
    private var sut: LocationRepositoryImpl!
    private var locationAPI: LocationsAPIMock!
    override func setUp() {
        super.setUp()
        locationAPI = LocationsAPIMock()
        sut = LocationRepositoryImpl(api: locationAPI)
    }

    func testFetchFromBackendSuccess() async {
        locationAPI.stubbedResult = .success([.mock])
        await sut.fetchFromBackend()
        XCTAssertNil(sut.latestFetchError)
        XCTAssertEqual(sut.locations.count, 1)
    }
    
    func testFetchFromBackendFailure() async throws {
        locationAPI.stubbedResult = .failure(.network(CancellationError()))
        await sut.fetchFromBackend()
        let error = try XCTUnwrap(sut.latestFetchError)
        switch error {
        case .decoding:
            XCTFail("Expected network error")
        case .network(let innerError):
            XCTAssert(innerError is CancellationError)
        }
        XCTAssertEqual(sut.locations.count, 0)
    }
    
    func testUpdateExisting() async {
        locationAPI.stubbedResult = .success([.init(name: "test1", lat: 0.1, long: 0.2)])
        await sut.fetchFromBackend()
        var locations = sut.locations.map { $0.withUpdatedName("test2") }
        sut.updateExisting(locations: locations)
        XCTAssertEqual(sut.locations.count, 1)
        XCTAssertEqual(sut.locations[0].name, "test2")
        XCTAssertEqualWithAccuracy(sut.locations[0].latitude, 0.1, accuracy: 0.0001)
    }
}

private final class LocationsAPIMock: LocationsAPI {
    var stubbedResult: Result<[LocationDTO], LocationFetchError> = .success([])
    func fetch() async -> Result<[LocationDTO], LocationFetchError> {
        stubbedResult
    }
}

private extension LocationDTO {
    static var mock: Self {
        .init(name: "test", lat: 0, long: 0)
    }
}

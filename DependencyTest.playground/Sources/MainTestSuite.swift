//
//  MainTestSuite.swift
//  
//
//  Created by 程信傑 on 2022/12/17.
//

import Foundation
import XCTest

public class TheatherTest: XCTestCase {
    private var sut: MovieViewModel!

    override public func setUp() {
        super.setUp()
    }

    override public func tearDown() {
        super.tearDown()
    }

    func testUpdateByMockService() async throws {
        let stub = [Movie]
            .stub(withCount: 3)
            .setting(\.name, to: "hello")
        let loader = NetworkingMock()
        sut = MovieViewModel(service: MovieService(loader: loader))

        XCTAssertNotEqual(stub, sut.movies)

        loader.result = try .success(JSONEncoder().encode(stub))
        try await sut.updateByService()
        XCTAssertEqual(stub, sut.movies)
    }

    func testUpdateByClosure() async throws {
        let stub = [Movie]
            .stub(withCount: 3)
            .setting(\.name, to: "hello")
        sut = MovieViewModel(loading: { [stub] in stub })

        XCTAssertNotEqual(stub, sut.movies)

        try await sut.updateByClosure()
        XCTAssertEqual(stub, sut.movies)
    }

    func testGetLoggedState() {
        sut = MovieViewModel()

        var state = sut.getLoggedState()
        XCTAssertEqual(state, false)

        DependencyContainer.register(true)
        state = sut.getLoggedState()
        XCTAssertEqual(state, true)
    }
}

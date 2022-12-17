//
//  MainTestSuite.swift
//
//
//  Created by 程信傑 on 2022/12/17.
//

import Foundation
import XCTest

public class TheatherTest: XCTestCase {
    // MARK: 測試包含三個項目，測試MovieViewModel的更新功能是否正常

    // 1. 用傳統的mock作法，驗證updateByService是否能夠正常更新電影列表
    // 2. 用新的closure作法，驗證updateByClosure是否能夠正常更新電影列表
    // 3. 透過propertyWrapper，注入想要的結果，驗證getLoggedState，是否有正確回傳登入狀態

    private var sut: MovieViewModel!

    override public func setUp() {
        super.setUp()
    }

    override public func tearDown() {
        super.tearDown()
    }

    // MARK: 用傳統的mock作法，驗證updateByService是否能夠正常更新電影列表

    func testUpdateByMockService() async throws {
        // 利用"Extension_STUB.swift"中定義的協定，快速產生測試資料
        // 這筆資料代表目前線上的最新資料
        let stub = [Movie]
            .stub(withCount: 3)
            .setting(\.name, to: "hello")

        // 建立mock，模擬從網路存取資料
        let loader = NetworkingMock()

        // 存取電影資料的行為，封裝在MovieService，指定它使用mockLoader，避免從真實網路抓資料
        sut = MovieViewModel(service: MovieService(loader: loader))

        // 先檢查目前viewmodel中的資料不是最新的
        XCTAssertNotEqual(stub, sut.movies)

        // 將前面定義的最新資料，作為mockLoader的回傳值
        loader.result = try .success(JSONEncoder().encode(stub))

        // 要求viewmodel更新資料
        try await sut.updateByService()

        // 檢查viewmodel中的資料是否為最新資料
        XCTAssertEqual(stub, sut.movies)
    }

    // MARK: 用新的closure作法，驗證updateByClosure是否能夠正常更新電影列表

    func testUpdateByClosure() async throws {
        // 利用"Extension_STUB.swift"中定義的協定，快速產生測試資料
        // 這筆資料代表目前線上的最新資料
        let stub = [Movie]
            .stub(withCount: 3)
            .setting(\.name, to: "hello")

        // 直接透過closure定義viewmodel中，"更新資料的行為該是什麼"，這邊就是直接回傳最新資料
        sut = MovieViewModel(loading: { [stub] in stub })
        /*
          這邊一樣可以透過原先定義的service去抓取資料，只要在閉包內呼叫service定義的方法即可
         service = MovieService()
         sut = MovieViewModel(loading: { try await service.reload() })
          */

        // 先檢查目前viewmodel中的資料不是最新的
        XCTAssertNotEqual(stub, sut.movies)

        // 要求viewmodel更新資料
        try await sut.updateByClosure()

        // 檢查viewmodel中的資料是否為最新資料
        XCTAssertEqual(stub, sut.movies)
    }

    // MARK: 透過propertyWrapper，注入想要的結果，驗證getLoggedState，是否有正確回傳登入狀態

    func testGetLoggedState() {
        sut = MovieViewModel()

        // 檢查注入值之前的登入狀態是否為false
        var state = sut.getLoggedState()
        XCTAssertEqual(state, false)

        // 利用"Extension_DI.swift"定義的方法注入新值(使用上可以參考view model的實作)
        DependencyContainer.register(true)

        // 檢查注入值之前的登入狀態是否為false
        state = sut.getLoggedState()
        XCTAssertEqual(state, true)
    }
}

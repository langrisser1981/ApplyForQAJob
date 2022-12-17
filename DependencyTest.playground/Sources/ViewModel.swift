//
//  ViewModel.swift
//
//
//  Created by 程信傑 on 2022/12/17.
//

import Foundation

// 負責實際取得電影資料
class MovieService {
    // 可替換的loader，支援mockLoader(stub) & URLSession
    private let loader: DataLoader

    // loader預設為URLSession，如此在release版中就不需要另外指定
    init(loader: DataLoader = URLSession.shared) {
        self.loader = loader
    }

    // 抓最新電影列表
    func reload() async throws -> [Movie] {
        let url = URL(string: "localhost")
        let (data, _) = try await loader.data(from: url!)
        return try JSONDecoder().decode([Movie].self, from: data)
    }
}

class MovieViewModel {
    // 第一種測試，使用傳統的apiService管理資料，同時藉由注入不同的loader，來控制由真實網路或是mock取得資料
    var service: MovieService

    // 第二種測試，定義一個closure，規範好該功能的實際行為(例如接收參數與回傳類型)，後續就交由外部實作此closure
    typealias Loading = () async throws -> [Movie] // 此處模擬更新電影列表的行為，不需要參數，回傳[Movie]
    var loading: Loading

    // 第三種測試，透過property wrapper，來做到關係注入
    @Dependency var isLoggedIn = false

    var movies: [Movie] = []

    init(service: MovieService = MovieService(),
         loading: @escaping Loading = { [] })
    {
        self.service = service
        self.loading = loading
    }

    // 利用loader取得資料，供測試1驗證
    func updateByService() async throws {
        let result = try await service.reload()
        movies = result
    }

    // 利用closure直接取得資料，供測試2驗證
    func updateByClosure() async throws {
        let result = try await loading()
        movies = result
    }

    // 取得登入狀態，供測試3驗證
    func getLoggedState() -> Bool {
        return isLoggedIn
    }
}

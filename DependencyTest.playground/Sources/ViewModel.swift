//
//  ViewModel.swift
//  
//
//  Created by 程信傑 on 2022/12/17.
//

import Foundation

class MovieService {
    private let loader: DataLoader

    init(loader: DataLoader = URLSession.shared) {
        self.loader = loader
    }

    func reload() async throws -> [Movie] {
        let url = URL(string: "localhost")
        let (data, _) = try await loader.data(from: url!)
        return try JSONDecoder().decode([Movie].self, from: data)
    }
}

class MovieViewModel {
    typealias Loading = () async throws -> [Movie]

    @Dependency var isLoggedIn = false
    var movies: [Movie] = []
    var service: MovieService
    var loading: Loading

    init(service: MovieService = MovieService(),
         loading: @escaping Loading = { [] })
    {
        self.service = service
        self.loading = loading
    }

    func updateByService() async throws {
        let result = try await service.reload()
        movies = result
    }

    func updateByClosure() async throws {
        let result = try await loading()
        movies = result
    }

    func getLoggedState() -> Bool {
        return isLoggedIn
    }
}

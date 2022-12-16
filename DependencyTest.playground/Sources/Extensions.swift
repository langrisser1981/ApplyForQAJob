//
//  Extensions.swift
//
//
//  Created by 程信傑 on 2022/12/17.
//

import Foundation

protocol Stubbable {
    static func stub() -> Self
}

extension Stubbable {
    func setting<T>(_ keyPath: WritableKeyPath<Self, T>, to value: T) -> Self {
        var stub = self
        stub[keyPath: keyPath] = value
        return stub
    }
}

extension Array where Element: Stubbable {
    static func stub(withCount count: Int) -> Self {
        let loop = (0 ..< count)
        let tar = Element.self
        return loop.map { _ in
            tar.stub()
        }
    }
}

extension MutableCollection where Element: Stubbable {
    func setting<T>(_ keyPath: WritableKeyPath<Element, T>, to value: T) -> Self {
        var collection = self
        for index in collection.indices {
            let element = collection[index]
            collection[index] = element.setting(keyPath, to: value)
        }
        return collection
    }
}

protocol DataLoader {
    func data(from: URL) async throws -> (Data, URLResponse)
}

extension URLSession: DataLoader {}

class NetworkingMock: DataLoader {
    var result: Result<Data, Error> = .success(Data())

    func data(from: URL) async throws -> (Data, URLResponse) {
        return try (result.get(), URLResponse())
    }
}

@propertyWrapper
struct Dependency<T> {
    var wrappedValue: T {
        get {
            DependencyContainer.resolve()
        }
        set {
            DependencyContainer.register(newValue)
        }
    }

    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
}

class DependencyContainer {
    private var dependencies = [String: AnyObject]()
    private static var shared = DependencyContainer()

    init() {}

    static func register<T>(_ dependency: T) {
        shared.register(dependency)
    }

    static func resolve<T>() -> T {
        shared.resolve()
    }

    private func register<T>(_ dependency: T) {
        let key = String(describing: T.self)
        dependencies[key] = dependency as AnyObject
    }

    private func resolve<T>() -> T {
        let key = String(describing: T.self)
        let dependency = dependencies[key] as? T

        precondition(dependency != nil, "no value for that key")
        return dependency!
    }
}

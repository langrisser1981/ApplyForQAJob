import Foundation

// MARK: 利用propertyWrapper來完成D.I.

// 宣告一個屬性包裝，存取都會透過唯一的容器(DependencyContainer)
@propertyWrapper
struct Dependency<T> {
    var wrappedValue: T {
        get {
            // 取得注入值
            DependencyContainer.resolve()
        }
        set {
            // 注入新值
            DependencyContainer.register(newValue)
        }
    }

    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
}

// 建立一個類別來保存注入內容
// 對外暴露兩個靜態方法，在靜態方法中透過單例做存取
// 注入: DependencyContainer.register(value)
// 讀取: let value = DependencyContainer.resolve()
class DependencyContainer {
    // 建立一個Dict透過key:value保存；key:注入值的型別，value:注入值
    // 如果注入3，Dict保存的就是{Int:3}；注入fasle，保存的是{Bool:false}
    private var dependencies = [String: AnyObject]()
    private static var shared = DependencyContainer() // 讓外部只能透過單例存取，保持唯一性

    init() {}

    static func register<T>(_ dependency: T) {
        shared.register(dependency)
    }

    static func resolve<T>() -> T {
        shared.resolve()
    }

    private func register<T>(_ dependency: T) {
        let key = String(describing: T.self)
        dependencies[key] = dependency as AnyObject // 將存入的值轉型為AnyObject
    }

    private func resolve<T>() -> T {
        let key = String(describing: T.self) // 透過泛型，從外部的實作得知型別(T)，以此作為key
        let dependency = dependencies[key] as? T // 透過泛型，從外部的實作得知型別(T)，取出對應的value，並對value做轉型

        precondition(dependency != nil, "no value for that key") // 回傳前檢查值是否為空，如果空的話就讓系統崩潰
        return dependency!
    }
}

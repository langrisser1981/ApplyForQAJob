import Foundation

// MARK: 利用自訂Stubbable協定，建立假資料

// 建立單筆資料: Model.stub()
// 修改單筆資料屬性:   .setting(keyPath:value:)
// 建立資料陣列: [Model].stub(withCount:)
// 建立資料陣列        .setting(keyPath:value:)

// 定義一個protocol，讓所有需要被測試的資料套用，用來代表該資料型別能夠產生stub
// 需要實作靜態方法stub，會回傳測試資料
protocol Stubbable {
    static func stub() -> Self
}

// 定義一個setting方法，可以透過keypath修改屬性
extension Stubbable {
    func setting<T>(_ keyPath: WritableKeyPath<Self, T>, to value: T) -> Self {
        var stub = self // 因為struct特性，無法從內部修改自己的屬性，所以複製出一個替身，修改完屬性後，回傳該替身
        stub[keyPath: keyPath] = value
        return stub
    }
}

// 擴充Array，定義一個靜態方法，可以傳入數量，回傳一個假資料陣列
// let books = [Book].stub(withCount: 3)
extension Array where Element: Stubbable {
    static func stub(withCount count: Int) -> Self {
        let loop = (0 ..< count) // 利用Range<Int>，表達要建立的資料筆數
        let tar = Element.self // 取得陣列元素的metaType
        return loop.map { _ in // 透過map轉換，建立假資料陣列，也可以用$0存取索引，作為資料的id識別
            tar.stub() // 透過metaType呼叫靜態方法stub，來建立單筆假資料
        }
    }
}

// 擴充MutableCollection，定義一個setting方法，可以透過keypath一次修改集合中所有元件的屬性
extension MutableCollection where Element: Stubbable {
    func setting<T>(_ keyPath: WritableKeyPath<Element, T>, to value: T) -> Self {
        var collection = self // 同上，因為struct無法從內部修改自己的屬性，所以複製出一個替身，修改完屬性後，回傳該替身
        for index in collection.indices {
            let element = collection[index]
            collection[index] = element.setting(keyPath, to: value) // 呼叫element的setting方法(定義在Stubbable)修改屬性，重新指定回collection
            // 注意:這邊的setting，是回傳element修改後的替身，而不是直接修改element，所以要把回傳結果重新指定回collection
        }
        return collection
    }
}

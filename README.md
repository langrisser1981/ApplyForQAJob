# 做一個unit test，使用幾個常用的功能驗證能否取得電影列表

## 1. 利用自訂Stubbable協定，建立假資料

> 實作請參考 Sources/Extension_Stub.swift

<br>

利用stub方法，快速建立一個Bundle類型，並指定其預設值(也可以建立陣列)

```swift
let bundle = Book.Bundle
    .stub(withID: "fantasy")                 // 建立stub
    .setting(\.name, to: "Fantasy Bundle")   // 利用keypath，設定name屬性
    .setting(\.books, to: [Book]
        .stub(withCount: 5)                  // 設定books屬性為stub陣列，內容為五本書
        .setting(\.genres, to: [.fantasy])   // 將五本書的genres屬性都設定為.fantasy
    )
```

<br><br>

## 2. 建立兩種mock，一種是protocol+extension，一種是closure

> 實作請參考 Sources/Extension_Mock.swift & Sources/ViewModel.swift

<br>

第一種是常見的做法，用protocol定義一個公開介面，讓原本的網路通訊類別與自己的mock套用，後續再根據情境，傳入要使用的loader

```swift
// 先建立通用protocol，包含需要模擬的網路請求方法
protocol DataLoader {
    func data(from: URL) async throws -> (Data, URLResponse)
}

// 讓原先真正做網路請求的URLSession也套用該通用protocol
extension URLSession: DataLoader {}

// 建立mock
class NetworkingMock: DataLoader {
    // 可以讓外部指定回傳值，回傳類型是Result，預設回傳成功
    var result: Result<Data, Error> = .success(Data())

    func data(from: URL) async throws -> (Data, URLResponse) {
        // 回傳預先設定好的資料
        return try (result.get(), URLResponse())
    }
}
```

<br>

第二種是利用typealias & closure，定義行為的內容 (接收的參數與回傳值)，由外部實作閉包內容，所以可以直接傳入stub資料，也可以呼叫上面定義的mockLoader，只要回傳內容相同就可以

```swift
    // 先在viewmodel定義好功能的實際行為
    typealias Loading = () async throws -> [Movie] // 此處模擬更新電影列表，不需要參數，回傳[Movie]

    // 建立viewmodel的時候，在closure實作閉包
    // 直接透過closure定義viewmodel中，"更新資料的行為該是什麼"，這邊就是直接回傳最新資料
    MovieViewModel(loading: { stub })
    // 一樣可以透過原先定義的service去抓取資料，只要在閉包內呼叫service定義的方法即可
    service = MovieService()
    MovieViewModel(loading: { try await service.reload() })

```

<br><br>

## 3. 透過Property Wrapper做到Dependency Injection

> 實作請參考 Sources/Extension_DI.swift

<br>

將一個Bool值注入isLoggedIn，後續可以透過DependencyContainer改變注入內容

```swift
@Dependency var isLoggedIn = false // 宣告isLoggedIn接收外部注入
DependencyContainer.register(true) // 注入true，此時isLoggedIn == true
```

<br><br>

---

### 測試結果

```console
Test Suite 'TheatherTest' started at 2022-12-17 23:25:57.518
Test Case '-[DependencyTest_Sources.TheatherTest testGetLoggedState]' started.
Test Case '-[DependencyTest_Sources.TheatherTest testGetLoggedState]' passed (0.024 seconds).
Test Case '-[DependencyTest_Sources.TheatherTest testUpdateByClosure]' started.
Test Case '-[DependencyTest_Sources.TheatherTest testUpdateByClosure]' passed (0.027 seconds).
Test Case '-[DependencyTest_Sources.TheatherTest testUpdateByMockService]' started.
Test Case '-[DependencyTest_Sources.TheatherTest testUpdateByMockService]' passed (0.025 seconds).
Test Suite 'TheatherTest' passed at 2022-12-17 23:25:57.598.
  Executed 3 tests, with 0 failures (0 unexpected) in 0.076 (0.080) seconds

```

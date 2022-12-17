import Foundation

// MARK: 一般的mock作法

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

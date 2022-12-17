//
//  Model.swift
//
//
//  Created by 程信傑 on 2022/12/17.
//

struct Movie: Identifiable, Codable, Equatable {
    var id: Int
    var name: String
    var category: [String]
}

// 透過實作Stubbable協定，提供一個靜態方法，可以回傳一筆預設資料
// 後續可以透過.setting(_:to:)，傳入keypath與值，修改資料的屬性
extension Movie: Stubbable {
    static func stub() -> Movie {
        return self.init(id: 0, name: "testMovie", category: [])
    }
}

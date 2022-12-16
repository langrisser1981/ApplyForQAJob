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

extension Movie: Stubbable {
    static func stub() -> Movie {
        return self.init(id: 0, name: "testMovie", category: [])
    }
}

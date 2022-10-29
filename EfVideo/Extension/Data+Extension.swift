//
//  Data+Extension.swift
//  EfVideo
//
//  Created by user on 23.10.2022.
//

import Foundation

extension Data {
    func decode() -> [String: Any] {
        let obj = try? JSONSerialization.jsonObject(with: self, options: .fragmentsAllowed)
        return obj as? [String: Any] ?? [:]
    }
    
    func decode<T: Decodable>(type: T.Type) -> T? {
        let obj = try? JSONSerialization.jsonObject(with: self, options: .fragmentsAllowed)
        
        guard
            let dict = obj as? [String: Any],
            let data = dict.asData() else {
            return nil
        }
        
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: data)
    }
}

extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
    func asData() -> Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: .fragmentsAllowed)
    }
}

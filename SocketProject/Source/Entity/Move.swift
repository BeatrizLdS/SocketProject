//
//  Move.swift
//  SocketProject
//
//  Created by Beatriz Leonel da Silva on 06/03/24.
//

import Foundation

struct Move: Codable {
    let moveFrom: Int?
    let moveTo: Int?
    let removed: Int?
    
    let endGame: Bool?
    let retartGame: Bool?
    
    func encodeToJson() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(self)
    }
    
    static func decodeFromJson(data: Data) throws -> Move {
        let decoder = JSONDecoder()
        return try decoder.decode(Move.self, from: data)
    }
}

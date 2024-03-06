//
//  NetworkProtocols.swift
//  SocketProject
//
//  Created by Beatriz Leonel da Silva on 27/02/24.
//

import Foundation

protocol Comunication {
    func sendMessage(_ message: Data, completion: @escaping ((Bool) -> Void))
//    func receiveMessage()
}

protocol ServerProtocol: Comunication {
    associatedtype Listener
    associatedtype Connection
    var listener: Listener? { get set }
    var connection: Connection? { get set }
}

protocol ClientProtocol: Comunication {
    associatedtype Connection
    var connection: Connection? { get set }
}

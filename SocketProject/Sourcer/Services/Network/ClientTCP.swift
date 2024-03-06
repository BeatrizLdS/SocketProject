//
//  ClientTCP.swift
//  SocketProject
//
//  Created by Beatriz Leonel da Silva on 27/02/24.
//

import Foundation
import Network
import Combine

protocol ClientTCPProtocol: ClientProtocol where Connection == NWConnection {
    var statePublisher: PassthroughSubject<NWConnection.State, Never> { get set }
    var messagePublisher: PassthroughSubject<Data, Never> { get set }
    func connect(to host: String, port: String)
}

class ClientTCP: ClientTCPProtocol {
    var connection: NWConnection?
    var statePublisher = PassthroughSubject<NWConnection.State, Never>()
    var messagePublisher = PassthroughSubject<Data, Never>()
    
    func connect(to host: String, port: String) {
        let parameters = NWParameters(tls: nil, tcp: .init())
        
        if let port = NWEndpoint.Port(port) {
            connection = NWConnection(
                host: NWEndpoint.Host(host),
                port: port,
                using: parameters
            )
        }
        
        connection?.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                self.receiveMessage()
                self.statePublisher.send(newState)
            default:
                self.statePublisher.send(newState)
            }
        }
                
        connection?.start(queue: .main)
    }
    
    func sendMessage(_ message: Data, completion: @escaping ((Bool) -> Void) ) {
        connection?.send(content: message, completion: .contentProcessed({ error in
            if let error = error {
                print("Error sending message: \(error)")
            } else {
                print("Message sent sucessfully!")
            }
        }))
    }
    
    func receiveMessage() {
        if let connection = connection {
            connection.receive(minimumIncompleteLength: 1, maximumLength: 8192) { [weak self] (content, contentContext, isComplete, error) in
                if let data = content {
                    self?.messagePublisher.send(data)
                    self?.receiveMessage()
                } else if let error = error {
                    print(error)
                }
            }
        }
    }
}

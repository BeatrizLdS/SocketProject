//
//  Network.swift
//  SocketProject
//
//  Created by Beatriz Leonel da Silva on 27/02/24.
//

import Foundation
import Network
import Combine

protocol ServerTCPProtocol: ServerProtocol where Connection == NWConnection, Listener == NWListener {
    var statePublisher : PassthroughSubject<NWListener.State, Never> { get set }
    var connectionPublisher: PassthroughSubject<NWConnection.State, Never> { get set }
    var messagePublisher: PassthroughSubject<Data, Never> { get set }
    func startServer()
}

class ServerTCP: ServerTCPProtocol {
    var listener: NWListener?
    var connection: NWConnection?
    
    var statePublisher = PassthroughSubject<NWListener.State, Never>()
    var connectionPublisher = PassthroughSubject<NWConnection.State, Never>()
    var messagePublisher = PassthroughSubject<Data, Never>()
      
    func startServer() {
        let parameters = NWParameters(tls: nil, tcp: .init())
        
        listener = try? NWListener(using: parameters, on: 8080)
        
        // Starting Server
        listener?.stateUpdateHandler = { newState in
            self.statePublisher.send(newState)
        }
        
        // Handler Connection
        listener?.newConnectionHandler = { [weak self] newConnection in
            self?.connection = newConnection
                        
            self?.connection?.stateUpdateHandler = { newState in
                self?.connectionPublisher.send(newState)
            }
            
            self?.receiveMessage(for: newConnection)
            
            self?.connection?.start(queue: .main)
            
        }
        listener?.start(queue: .main)
    }
    
    func receiveMessage(for connection: NWConnection) {
        connection.receiveMessage { content, contentContext, isComplete, error in
            if let _ = content {
                print("recebeu algo pqp!")
            }
            if let _ = error {
                print("Executou, mas deu alguma coisa errada")
            }
        }
    }
    
    func sendMessage(_ message: Data, completion: @escaping ((Bool) -> Void)) {
        self.connection?.send(content: message, completion: .contentProcessed({ error in
            if let error = error {
                print("Error sending response: \(error)")
            } else {
                print("Response sent successfully.")
            }
        }))
    }
}

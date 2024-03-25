//
//  ClientUDP.swift
//  SocketProject
//
//  Created by Beatriz Leonel da Silva on 04/03/24.
//

import Foundation
import Network

protocol ClientUDPProtocol: ClientProtocol where Connection == NWConnection {
    func discoverServer(port: String, completion: @escaping (Result<Data ,Error>) -> Void)
}

class ClientUDP: ClientUDPProtocol {
    var connection: NWConnection?
    
    func discoverServer(port: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let discoveryAddress = NWEndpoint.hostPort(
            host: NWEndpoint.Host("127.0.0.1"),
            port: NWEndpoint.Port(port)!
        )
        let parameter = NWParameters.udp
        parameter.allowLocalEndpointReuse = true
        
        let data = MessagesType.requestServer.rawValue.data(using: .utf8)
        
        connection = NWConnection(to: discoveryAddress, using: parameter)
        
        connection?.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.sendMessage(data!, completion: { wasSentSuccessfully in
                    if wasSentSuccessfully {
                        print("Deu bom enviar")
                    } else {
                        print("Deu Ruim enviar")
                    }
                })
                
                self?.receiveResponse(completion: { result in
                    switch result {
                    case .success(let data):
                        completion(.success(data))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                })
                
            case .waiting(let error):
                print(error)
                print(error.localizedDescription)
                
            default:
                print("Deu algo inesperado com o Cliente UDP")
            }
        }
        
        connection?.start(queue: .main)
    }
    
    func sendMessage(_ message: Data, completion: @escaping ((Bool) -> Void)) {
        if let connection = connection {
            connection.send(content: message, completion: NWConnection.SendCompletion.contentProcessed({ error in
                if let _ = error {
                    completion(false)
                } else {
                    completion(true)
                }
            }))
        }
    }
    
    private func receiveResponse(completion: @escaping ((Result<Data, Error>) -> Void)) {
        if let connection = connection {
            connection.receiveMessage { (content, contentContext, isComplete, error) in
                if let error = error {
                    completion(.failure(error))
                } else if let data = content {
                    completion(.success(data))
                }
            }
        }
    }
}

extension ClientUDP {
    enum MessagesType: String {
        case requestServer = "REQUEST_SERVER"
        case serverUnavailable = "NO_SERVERS_AVAILABLE"
    }
}

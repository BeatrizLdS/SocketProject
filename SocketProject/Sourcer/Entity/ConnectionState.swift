//
//  ConnectionState.swift
//  SocketProject
//
//  Created by Beatriz Leonel da Silva on 29/02/24.
//

import Foundation

enum ConnectionState {
    case noServer
    case serverReady
    case waitingConnection
    
    case loadingConnection
    case connectionReady
    case connectionError
    case connectionCancelled
    
    case serverDisconnected
    case serverError
    
    var description: String {
        switch self {
        case .noServer:
            return "Server wasn't started"
        case .serverReady:
            return "Server ready to connection"
        case .waitingConnection:
            return "Server waiting Connection"
        case .connectionReady:
            return "Client was connected"
        case .serverDisconnected:
            return "Server was Disconnected"
        case .serverError:
            return "Server Error"
        case .loadingConnection:
            return "Loading Connection"
        case .connectionError:
            return "Connection Error"
        case .connectionCancelled:
            return "Connection was Cancelled"
        }
    }
}

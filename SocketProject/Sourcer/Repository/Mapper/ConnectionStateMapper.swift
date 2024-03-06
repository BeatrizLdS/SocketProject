//
//  ConnectionStateMapper.swift
//  SocketProject
//
//  Created by Beatriz Leonel da Silva on 29/02/24.
//

import Foundation
import Network

protocol ServerStateMapperProtocol: DomainEntityMapper where DTO == NWListener.State, DomainEntity == ConnectionState { }
protocol ClientStateMapperProtocol: DomainEntityMapper where DTO == NWConnection.State, DomainEntity == ConnectionState { }

class ServerStateMapper: ServerStateMapperProtocol {
    func mapToDomain(_ dto: NWListener.State) -> ConnectionState {
        switch dto {
        case .waiting(let error):
            return .serverError
        case .ready:
            return .serverReady
        case .failed(let error):
            let mapperError = mapError(error)
            if mapperError == .alredyServerConnected {
                return .waitingConnection
            }
            return .serverError
        case .cancelled:
            return .serverDisconnected
        default:
            return .serverError
        }
    }
    
    private func mapError(_ error: NWError) -> ErrorType {
        switch error {
        case .posix(let errorCode):
            if errorCode.rawValue == 48 {
                return .alredyServerConnected
            }
            return .otherError
        default:
            return .otherError
        }
    }
    
    enum ErrorType {
        case alredyServerConnected
        case otherError
    }
}

class ClientStateMapper: ClientStateMapperProtocol {
    func mapToDomain(_ dto: NWConnection.State) -> ConnectionState {
        switch dto {
        case .preparing:
            return .loadingConnection
        case .ready:
            return .connectionReady
        case .cancelled:
            return .connectionCancelled
        default:
            return .connectionError
        }
    }
}

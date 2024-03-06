//
//  Repository.swift
//  SocketProject
//
//  Created by Beatriz Leonel da Silva on 28/02/24.
//

import Foundation
import Network
import Combine

protocol NetworkRepositoryProtocol {
    init(
        clientUDP: any ClientUDPProtocol,
        client: any ClientTCPProtocol,
        clientMappeer: any ClientStateMapperProtocol
    )
    
    var statePublisher: PassthroughSubject<ConnectionState, Never> { get set }
    var chatMessagePublisher: PassthroughSubject<ChatMessage, Never> { get set }
    var movePublisher: PassthroughSubject<Move, Never> { get set }
    
    func connect()
    func clientSendMessage(_ message: ChatMessage)
    
    func sendMove(_ move: Move)
}

class NetworkRepository: NetworkRepositoryProtocol {
    private var client: any ClientTCPProtocol
    private var clientUPD: any ClientUDPProtocol
    
    private var serverIP: String? {
        didSet {
            if let address = serverIP {
                self.connectTCP(address)
            }
        }
    }
    
    private var clientMapper: any ClientStateMapperProtocol
        
    private var cancellables = Set<AnyCancellable>()
    
    var statePublisher = PassthroughSubject<ConnectionState, Never>()
    var chatMessagePublisher = PassthroughSubject<ChatMessage, Never>()
    var movePublisher = PassthroughSubject<Move, Never>()
        
    required init(
        clientUDP: any ClientUDPProtocol,
        client: any ClientTCPProtocol,
        clientMappeer: any ClientStateMapperProtocol)
    {
        self.clientUPD = clientUDP
        self.client = client
        self.clientMapper = clientMappeer
        
        setSubscriptions()
    }
    
    func sendMove(_ move: Move) {
        do {
            let data = try move.encodeToJson()
            client.sendMessage(data) { hasSent in
                if hasSent {
                    print("Envio feito com Sucesso!")
                } else {
                    print("Deu Ruim Enviar!")
                }
            }
        } catch {
            print(error)
        }
    }
    
    func connect() {
        clientUPD.discoverServer(port: CommunicationPorts.broker.rawValue) { [ weak self ] result in
            switch result {
            case .success(let data):
                if let resultString = String(data: data, encoding: .utf8) {
                    self?.serverIP = resultString
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func connectTCP(_ host: String) {
        client.connect(to: host, port: CommunicationPorts.tcpServer.rawValue)
    }
    
    
    func clientSendMessage(_ message: ChatMessage) {
        if let messageData = message.content.data(using: .utf8) {
            client.sendMessage(messageData) { _ in }
        }
    }
    
    private func setSubscriptions() {
        self.client.statePublisher
            .sink { [weak self] state in
                if let newState = self?.clientMapper.mapToDomain(state) {
                    self?.statePublisher.send(newState)
                }
            }
            .store(in: &cancellables)
        
        self.client.messagePublisher
            .sink { [weak self] data in
                
                do {
                    let move = try Move.decodeFromJson(data: data)
                    self?.movePublisher.send(move)
                } catch {
                    print(error)
                    if let content = String(data: data, encoding: .utf8) {
                        if let status = MessagesType(rawValue: content) {
                            switch status {
                            case .START_GAME:
                                self?.statePublisher.send(.connectionReady)
                            case .FIRST_TO_CONNECT:
                                self?.statePublisher.send(.waitingConnection)
                            }
                        } else {
                            let newMessage = ChatMessage(
                                sender: .remoteUser,
                                content: content
                            )
                            self?.chatMessagePublisher.send(newMessage)
                        }
                    }
                }
                
                
            }
            .store(in: &cancellables)
    }
}

extension NetworkRepository {
    enum MessagesType: String {
        case START_GAME
        case FIRST_TO_CONNECT
    }
    
    enum CommunicationPorts: String {
        case broker = "1050"
        case tcpServer = "1100"
    }
}

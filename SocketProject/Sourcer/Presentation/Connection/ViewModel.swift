//
//  ViewModel.swift
//  SocketProject
//
//  Created by Beatriz Leonel da Silva on 28/02/24.
//

import Foundation
import Combine

class ViewModel: ObservableObject {
    @Published var viewState: ViewState = .notStarted
    @Published var messages: [ChatMessage] = []
    @Published var inputUser: String = ""
    @Published var boardSpaces: [Int] = Array(repeating: 1, count: 33)
    @Published var selectedPiace: Int?
    @Published var avaliableMoviments: [Int]?
    
    var isFirst: Bool = false
    var isTurn: Bool = false
    var isWinner: Bool = false
    
    var neighBorOfSelected: [Int?]?    
    
    private var connectionState: ConnectionState? {
        didSet {
            switch connectionState {
            case .waitingConnection:
                viewState = .waitingPlayer
                isTurn = true
                isFirst = true
            case .serverReady:
                viewState = .waitingPlayer
            case .connectionReady:
                viewState = .inGame
            case .loadingConnection:
                viewState = .loading
            default:
                break
            }
        }
    }
    var repository: any NetworkRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: any NetworkRepositoryProtocol) {
        self.repository = repository
        setSubscriptions()
    }
    
    func start() {
        repository.connect()
    }
    
    func sendMessage() {
        let newMessage = ChatMessage(
            sender: .localUser,
            content: inputUser)
        repository.clientSendMessage(newMessage)
        self.messages.append(newMessage)
        inputUser = ""
    }
    
    private func setSubscriptions() {
        repository.statePublisher
            .sink { [weak self] state in
                self?.connectionState = state
            }
            .store(in: &cancellables)
        
        repository.chatMessagePublisher
            .sink { newMessage in
                self.messages.append(newMessage)
            }
            .store(in: &cancellables)
        
        repository.movePublisher.sink { [weak self] move in
            self?.receiveMove(move)
        }
        .store(in: &cancellables)
    }
}

extension ViewModel {
    enum ViewState {
        case notStarted
        case loading
        case waitingPlayer
        case inGame
        case endGame
    }
}

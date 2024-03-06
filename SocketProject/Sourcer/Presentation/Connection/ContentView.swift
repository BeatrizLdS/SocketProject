//
//  ContentView.swift
//  SocketProject
//
//  Created by Beatriz Leonel da Silva on 27/02/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var viewModel: ViewModel = ViewModel(
        repository: NetworkRepository(
            clientUDP: ClientUDP(),
            client: ClientTCP(),
            clientMappeer: ClientStateMapper()
        ))
    
    @State var text: String = ""
        
    var body: some View {
        VStack {
            switch viewModel.viewState {
            case .notStarted :
                Button {
                    viewModel.start()
                } label: {
                    Text("Start")
                }
            case .loading:
                ProgressView()
            case .waitingPlayer:
                Text("Esperando outro jogador")
            case .inGame:
                BoardView(
                    board: $viewModel.boardSpaces,
                    selectedPeace: $viewModel.selectedPeace
                )
//                ChatView(
//                    text: $viewModel.inputUser,
//                    messages: $viewModel.messages) {
//                        viewModel.sendMessage()
//                    }
            }
        }
    }
}

#Preview {
    ContentView()
}

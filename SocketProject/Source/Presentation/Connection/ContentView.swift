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
        GeometryReader { geometry in
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
                    VStack {
                        BoardView(
                            viewModel: viewModel
                        )
                        .background(Color.white)
                        ChatView(
                            text: $viewModel.inputUser,
                            messages: $viewModel.messages) {
                                viewModel.sendMessage()
                            }
                    }
                    .overlay(alignment: .topTrailing) {
                        Button {
                            viewModel.playAgain()
                        } label: {
                            Image(systemName: "arrow.counterclockwise.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                                .background {
                                    Circle()
                                        .fill(.blue)
                                        .frame(width: 30, height: 30)
                                }
                                .padding(.trailing, 10)
                        }
                        .shadow(color:.black.opacity(25), radius: 3)
                    }
                case .endGame:
                    Text(viewModel.isWinner ? "You Win" : "You Lose")
                    Button {
                        viewModel.playAgain()
                    } label: {
                        Text("Play again")
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.white)
        }
    }
}

#Preview {
    ContentView()
}

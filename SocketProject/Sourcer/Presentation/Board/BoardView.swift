//
//  BoardView.swift
//  SocketProject
//
//  Created by Beatriz Leonel da Silva on 05/03/24.
//

import SwiftUI

struct BoardView: View {
    @ObservedObject var viewModel: ViewModel
    @State private var peaceRadius: CGFloat?
        
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            VStack (alignment: .center) {
                ForEach (0..<7) { row in
                    HStack (alignment: .center) {
                        let rate = row > 1 && row < 5 ? 7 : 3
                        ForEach (0..<rate) { col in
                            let counter = viewModel.getCurrentSpaceInBoard(
                                row: row,
                                col: col,
                                rate: rate)
                            getSpace(counter, hasPiece: viewModel.boardSpaces[counter])
                                .frame(width: peaceRadius, height: peaceRadius)
                                .padding(5)
                        }
                    }
                }
            }
            .onAppear{
                getPeaceRadius(width: width, height: height)
                viewModel.startGame()
            }
            .frame(width: width, height: height)
        }
    }
    
    func getSpace(_ currentSpace: Int, hasPiece: Int) -> some View {
        if hasPiece == 1 {
            let color: Color = currentSpace == viewModel.selectedPiace ? Color.blue : Color.teal
            return AnyView(
                Circle()
                    .fill(color)
                    .onTapGesture {
                        if viewModel.isTurn {
                            viewModel.selectPiece(currentSpace)                            
                        }
                    }
            )
        }
        var color: Color = Color.teal.opacity(0.2)
        if let contains = viewModel.avaliableMoviments?.contains(currentSpace), contains {
            color = .green
        }
        return AnyView(
            Circle()
                .fill(color)
                .overlay {
                    Circle()
                        .stroke(Color.gray, lineWidth: 5)
                }
                .onTapGesture {
                    withAnimation {
                        viewModel.moveTo(currentSpace)
                    }
                }
        )
    }
    
    func getPeaceRadius(width: CGFloat, height: CGFloat) {
        let maxWidth = width/10 - 5
        let maxHeight = height/10 - 5
        peaceRadius = maxWidth > maxHeight ? maxHeight : maxWidth
    }
}

#Preview {
    BoardView(
        viewModel: ViewModel(repository: NetworkRepository(
            clientUDP: ClientUDP(),
            client: ClientTCP(),
            clientMappeer: ClientStateMapper()))
    )
}

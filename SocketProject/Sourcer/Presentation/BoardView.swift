//
//  BoardView.swift
//  SocketProject
//
//  Created by Beatriz Leonel da Silva on 05/03/24.
//

import SwiftUI

struct BoardView: View {
    @Binding var board: [Int]
    @Binding var selectedPeace: Int?
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
                            let counter = getCounter(
                                row: row,
                                col: col,
                                rate: rate)
                            getSpace(counter, hasPiece: board[counter])
                                .frame(width: peaceRadius, height: peaceRadius)
                                .padding(5)
                                .onTapGesture {
                                    selectedPeace = counter
                                }
                        }
                    
                    }
                }
            }
            .onAppear{
                getPeaceRadius(width: width, height: height)
                board[16] = 0
            }
            .frame(width: width, height: height)
        }
    }
    
    func getCounter(row: Int, col: Int, rate: Int) -> Int {
        var value = 0
        if row < 2 {
            value = (row * rate) + col
        } else if rate == 7 {
            let factor = (row - 1)
            value = col + (rate * factor) - 1
        } else {
            let factor = row - 5
            value = (7 * 4 - 1) + (col) + (factor * rate)
            print(value)
        }
        return value
    }
    
    func getSpace(_ currentSpace: Int, hasPiece: Int) -> some View {
        if hasPiece == 1 {
            return AnyView(
                Circle()
                    .fill(currentSpace == selectedPeace ? Color.blue : Color.teal)
            )
        }
        return AnyView(
            Circle()
                .fill(Color.teal.opacity(0.2))
                .overlay {
                    Circle()
                        .stroke(Color.gray, lineWidth: 5)
                }
        )
    }
    
    func peace() -> some View {
        Circle()
            .fill(Color.teal)
    }
    
    func emptyPlace() -> some View {
        Circle()
            .fill(Color.teal.opacity(0.2))
            .overlay {
                Circle()
                    .stroke(Color.gray, lineWidth: 5)
            }

    }
    
    func getPeaceRadius(width: CGFloat, height: CGFloat) {
        let maxWidth = width/10 - 5
        let maxHeight = height/10 - 5
        peaceRadius = maxWidth > maxHeight ? maxHeight : maxWidth
    }
}

#Preview {
    BoardView(
        board: .constant(Array(repeating: 1, count: 33)),
        selectedPeace: .constant(5)
    )
}

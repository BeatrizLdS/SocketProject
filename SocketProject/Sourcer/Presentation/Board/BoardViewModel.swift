//
//  BoardViewModel.swift
//  SocketProject
//
//  Created by Beatriz Leonel da Silva on 06/03/24.
//

import Foundation

protocol BoardViewModelProtocol: ObservableObject {
    func getCurrentSpaceInBoard(row: Int, col: Int, rate: Int) -> Int
    func startGame()
    func selectPiece(_ newPieceIndex: Int)
    func moveTo(_ space: Int)
    func receiveMove(_ move: Move)
}

extension ViewModel: BoardViewModelProtocol {
    struct Neighbor {
        let left: Int?
        let right: Int?
        let top: Int?
        let down: Int?
        
        var array: [Int?] {
            return [left, right, top, down]
        }
    }
    
    func getCurrentSpaceInBoard(row: Int, col: Int, rate: Int) -> Int {
        var value = 0
        if row < 2 {
            value = (row * rate) + col
        } else if rate == 7 {
            let factor = (row - 1)
            value = col + (rate * factor) - 1
        } else {
            let factor = row - 5
            value = (7 * 4 - 1) + (col) + (factor * rate)
        }
        return value
    }
    
    func startGame() {
        isWinner = false
        boardSpaces = Array(repeating: 1, count: 33)
        boardSpaces[16] = 0
    }
    
    func playAgain() {
        let move = Move(moveFrom: nil, moveTo: nil, removed: nil, endGame: nil, retartGame: true)
        repository.sendMove(move)
        viewState = .inGame
    }
    
    func selectPiece(_ newPieceIndex: Int) {
        selectedPiace = newPieceIndex
        let neighbors = findNeighbors(newPieceIndex)
        self.neighBorOfSelected = neighbors.array
        var localAvailableMoviments: [Int]? = []
        if let left = neighbors.left, boardSpaces[left] == 1 {
            if let space = findHorizontalNeighbors(of: left, side: .left), boardSpaces[space] == 0 {
                localAvailableMoviments?.append(space)
            }
        }
        if let righ = neighbors.right, boardSpaces[righ] == 1 {
            if let space = findHorizontalNeighbors(of: righ, side: .right), boardSpaces[space] == 0 {
                localAvailableMoviments?.append(space)
            }
        }
        if let top = neighbors.top, boardSpaces[top] == 1 {
            if let space = findVerticalNeighbors(of: top, side: .top), boardSpaces[space] == 0 {
                localAvailableMoviments?.append(space)
            }
        }
        if let down = neighbors.down, boardSpaces[down] == 1 {
            if let space = findVerticalNeighbors(of: down, side: .down), boardSpaces[space] == 0 {
                localAvailableMoviments?.append(space)
            }
        }
        self.avaliableMoviments = localAvailableMoviments
    }
    
    func moveTo(_ space: Int) {
        let canDeadPiaces = findNeighbors(space)
        
        let set1: Set<Int?> = Set(canDeadPiaces.array)
        let set2: Set<Int?> = Set(self.neighBorOfSelected ?? [])

        let deadPiece = Array(set1.intersection(set2))[0]!
        boardSpaces[deadPiece] = 0
        boardSpaces[selectedPiace!] = 0
        boardSpaces[space] = 1
        
        let hasWin = hasWin()
        isWinner = hasWin
        if hasWin {
            viewState = .endGame
        }
        
        let currentMove = Move(
            moveFrom: selectedPiace,
            moveTo: space,
            removed: deadPiece,
            endGame: hasWin,
            retartGame: nil
        )
        
        self.repository.sendMove(currentMove)
        
        selectedPiace = nil
        avaliableMoviments = []
        
        isTurn = false
    }
    
    func hasWin() -> Bool {
        let countPieces = boardSpaces.filter { hasPiece in
            return hasPiece == 1
        }.count
        return countPieces == 1
    }
    
    func receiveMove(_ move: Move) {
        if let deadPiece = move.removed,
            let toSpace = move.moveTo,
           let fromSpace = move.moveFrom {
            boardSpaces[deadPiece] = 0
            boardSpaces[fromSpace] = 0
            boardSpaces[toSpace] = 1
            isTurn = true
        }
        
        if let hasLose = move.endGame {
            if hasLose {
                viewState = .endGame                
            }
        }
        
        if let isRestarting = move.retartGame {
            if isRestarting {
                viewState = .inGame
            }
        }
    }
    
    private func findNeighbors(_ newPieceIndex: Int) -> Neighbor {
        var neighbors: [Int?] = [nil, nil, nil, nil]
        if let leftNeighbor = findHorizontalNeighbors(of: newPieceIndex,side: .left) {
            neighbors[0] = leftNeighbor
        }
        if let rightNeighbor = findHorizontalNeighbors(of: newPieceIndex, side: .right) {
            neighbors[1] = rightNeighbor
        }
        if let topNeighbor = findVerticalNeighbors( of: newPieceIndex, side: .top) {
            neighbors[2] = topNeighbor
        }
        if let downNeighbor = findVerticalNeighbors( of: newPieceIndex, side: .down) {
            neighbors[3] = downNeighbor
        }
        return Neighbor(
            left: neighbors[0],
            right: neighbors[1],
            top: neighbors[2],
            down: neighbors[3]
        )
    }
    
    private func findHorizontalNeighbors(of index: Int, side: NeighborSide) -> Int? {
        let inRateThree = Array(0...5) + Array(27...32)
        let inRateSeven = Array(6...26)
        
        let currentRateArray = inRateThree.contains(index) ? inRateThree : inRateSeven
        let rate = currentRateArray.count % 7 == 0 ? 7 : 3
        
        switch side {
        case .left:
            let hasLeft = rate == 3 ? !(index % rate == 0) : !((index + 1) % rate == 0)
            if hasLeft {
                return index - 1
            }
        case .right:
            let hasRight = rate == 3 ? !((index + 1) % rate == 0) : !((index + 2) % rate == 0 )
            if hasRight {
                return index + 1
            }
        default:
            break
        }
        return nil
    }
    
    private func findVerticalNeighbors(of index: Int, side: NeighborSide) -> Int? {
        let inRateThree = Array(0...5) + Array(27...32)
        let inRateSeven = Array(6...26)
        
        let rate = inRateThree.contains(index) ? 3 : 7
        let currentArray = rate == 3 ? inRateThree : inRateSeven
        let otherArray = rate == 3 ? inRateSeven : inRateThree
        
        switch side {
        case .top:
            if ![6,7,11,12].contains(index) {
                var possibleTop = index - rate
                if !currentArray.contains(possibleTop) {
                    possibleTop = rate == 7 ? possibleTop + 2 : possibleTop - 2
                    if otherArray.contains(possibleTop)  {
                        return possibleTop
                    }
                } else {
                    return possibleTop
                }
            }
        case .down:
            if ![20,21,25,26].contains(index) {
                var possibleDown = index + rate
                if !currentArray.contains(possibleDown){
                    possibleDown = rate == 7 ? possibleDown - 2 : possibleDown + 2
                    if otherArray.contains(possibleDown) {
                        return possibleDown
                    }
                } else {
                    return possibleDown
                }
            }
        default:
            break
        }
        
        return nil
    }
    
    enum NeighborSide {
        case left
        case right
        case top
        case down

    }
}

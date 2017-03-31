//: Playground - noun: a place where people can play

import UIKit

enum Portal {
    case snake(UInt)
    case ladder(UInt)
}

enum Action {
    case invalidMove
    case moveTo(UInt)
    case win
}

extension Action: Equatable {
    static func == (lhs: Action, rhs: Action) -> Bool {
        switch lhs {
        case .moveTo(let move): return rhs == .moveTo(move)
        case .invalidMove: return rhs == .invalidMove
        case .win: return rhs == .win
        }
    }
}

// start -> end
struct Board {
    let size: UInt = 100
    let portals: [UInt: Portal] =
        [
            2: .ladder(38),
            4: .ladder(14),
            8: .ladder(31),
            21: .ladder(42),
            28: .ladder(84),
            36: .ladder(44),
            47: .snake(26),
            49: .snake(11),
            51: .ladder(67),
            56: .snake(53),
            62: .snake(18),
            64: .snake(60),
            71: .ladder(91),
            80: .ladder(100),
            87: .snake(24),
            93: .snake(73),
            95: .snake(75),
            98: .snake(78)
        ]

    func land(on square: UInt) -> Action {
        let finalSquare = { () -> UInt in
            switch self.portals[square] {
            case .some(.ladder(let target)):
                return target
            case .some(.snake(let target)):
                return target
            default:
                return square
            }
        }()
        switch finalSquare {
        case let x where x > size || x < 0:
            return .invalidMove
        case size:
            return .win
        default:
            return .moveTo(finalSquare)
        }
    }
}

enum PlayerColor {
    case green
    case blue
    case red
    case yellow
}

struct Turn {
    let player: Player
    let action: Action
}

class Player {
    let color: PlayerColor
    var square: UInt = 1
    init(_ color: PlayerColor) {
        self.color = color
    }
}

func rollDie() -> UInt {
    return UInt(arc4random_uniform(6)) + 1
}

class Game {
    var currentPlayer: UInt = 0
    let players: [Player]
    let board: Board
    let die: () -> UInt

    init(_ players: [Player], board: Board = .init(), die: @escaping () -> UInt = rollDie) {
        self.players = players
        self.board = board
        self.die = die
    }

    @discardableResult func takeTurn() -> Turn {
        // Get current player
        let player = players[Int(currentPlayer)]

        // Take turn
        let action = board.land(on: player.square + die())
        switch action {
        case let .moveTo(target):
            player.square = target
        default:
            break
        }

        // Change player
        currentPlayer = (currentPlayer + 1) % UInt(players.count)

        // Return turn
        return Turn(player: player, action: action)
    }
}

class RiggedDie {
    var number: UInt = 1

    var generate: () -> UInt {
        return { self.number }
    }
}

func testBoard() {
    let board = Board()
    board.land(on: 1)   == .moveTo(1)
    board.land(on: 2)   == .moveTo(38)
    board.land(on: 47)  == .moveTo(26)
    board.land(on: 100) == .win
    board.land(on: 80)  == .win
    board.land(on: 101) == .invalidMove
}

func testPlayerTurn() {
    let game = Game([Player(.blue), Player(.green)])
    game.currentPlayer  == 0
    game.takeTurn()
    game.currentPlayer  == 1
    game.takeTurn()
    game.currentPlayer  == 0
}

func testGame() {
    let die = RiggedDie()
    die.number = 1

    let game = Game([Player(.blue), Player(.green)], die: die.generate)

    let turn = game.takeTurn()
    turn.player.color == .blue
    turn.action == .moveTo(38)

    die.number = 2

    let secondTurn = game.takeTurn()
    secondTurn.player.color == .green
    secondTurn.action == .moveTo(3)
}

let game = Game([Player(.blue), Player(.green)])
var stillPlaying = true
while stillPlaying {
    let turn = game.takeTurn()
    switch turn.action {
    case .win:
        print("\(turn.player.color) is the winner")
        stillPlaying = false
    case .invalidMove:
        print("\(turn.player.color) made an invalid move")
    case let .moveTo(target):
        print("\(turn.player.color) moved to \(target) square")
    }
}

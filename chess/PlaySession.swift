//
//  main.swift
//  chess
//
//  Created by Félix on 16-02-12.
//  Copyright © 2016 Félix Cloutier. All rights reserved.
//

import Foundation

private let codePoints: [Piece: Int] = [
	.Pawn: 0x2659,
	.Rook: 0x2656,
	.Knight: 0x2658,
	.Bishop: 0x2657,
	.Queen: 0x2655,
	.King: 0x2654,
]

private func pieceChar(player: Player, piece: Piece) -> Character {
	let codePoint = codePoints[piece]! + (player == .Black ? 6 : 0)
	return Character(UnicodeScalar(codePoint))
}

private func tileBackground(loc: Locator) -> Int {
	return (loc.rank % 2 + loc.file) % 2 == 0 ? 42 : 47
}

enum SpecialStatus {
	case None
	case Check(Player)
	case Checkmate(Player)
}

enum InterpretationResult {
	case Success(SpecialStatus)
	case SelfCheck
	case ParseError
	case Illegal
	case Ambiguous
}

class PlaySession {
	var board = Board()
	var history = [(Locator, Locator)]()
	
	var turn: Player {
		return history.count % 2 == 0 ? .White : .Black
	}
	
	func interpret(move: String) -> InterpretationResult {
		do {
			let player = turn
			let move = try parseAlgebraic(board, player: player, move: move)
			let copy = board.move(move.0, to: move.1)
			if copy.isCheck(player) {
				return .SelfCheck
			}
			
			board = copy
			history.append(move)
			let opponent = player.opponent
			if copy.isCheck(opponent) {
				if copy.isCheckmate(opponent) {
					return .Success(.Checkmate(opponent))
				}
				return .Success(.Check(opponent))
			}
			return .Success(.None)
		} catch AlgebraicError.Ambiguous {
			return .Ambiguous
		} catch AlgebraicError.Illegal {
			return .Illegal
		} catch {
			return .ParseError
		}
	}
	
	func xtermPrint() {
		let rankOrder: [UInt8]
		if turn == .Black {
			rankOrder = Array(0..<8)
		} else {
			rankOrder = Array((0..<8).reverse())
		}
		
		let escape = Character(UnicodeScalar(0x1b))
		for rank in rankOrder {
			print("\(rank+1) ", terminator: "")
			for file in UInt8(0)..<UInt8(8) {
				let loc = Locator.fromCoords(file, rank: rank)!
				print("\(escape)[\(tileBackground(loc))m", terminator: "")
				if case .Occupied(let player, let piece) = board[loc] {
					print("\(pieceChar(player, piece: piece))", terminator: "")
				} else {
					print(" ", terminator: "")
				}
				print(" ", terminator: "")
			}
			print("\(escape)[0m")
		}
		print("  a b c d e f g h")
	}
}

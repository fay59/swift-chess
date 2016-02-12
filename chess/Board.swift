//
//  Board.swift
//  chess
//
//  Created by Félix on 16-02-12.
//  Copyright © 2016 Félix Cloutier. All rights reserved.
//

import Foundation

enum Tile {
	case Empty
	case Occupied(Player, Piece)
}

private func backRow(color: Player) -> [Tile] {
	return [
		.Occupied(color, .Rook),
		.Occupied(color, .Knight),
		.Occupied(color, .Bishop),
		.Occupied(color, .Queen),
		.Occupied(color, .King),
		.Occupied(color, .Bishop),
		.Occupied(color, .Knight),
		.Occupied(color, .Rook),
	]
}

private func pawnRow(color: Player) -> [Tile] {
	return (0..<8).map { _ in .Occupied(color, .Pawn) }
}

private func emptyRows() -> [Tile] {
	return (0..<32).map { _ in .Empty }
}

struct Board {
	private var tiles = [Tile]()
	
	init() {
		tiles += backRow(.White)
		tiles += pawnRow(.White)
		tiles += emptyRows()
		tiles += pawnRow(.Black)
		tiles += backRow(.Black)
	}
	
	subscript(locator: Locator) -> Tile {
		get { return tiles[locator.index] }
		set(value) { tiles[locator.index] = value }
	}
	
	subscript(locator: Locator?) -> Tile? {
		get { return locator.map { self[$0] } }
	}
	
	func move(from: Locator, to: Locator) -> Board {
		var copy = self
		copy[to] = copy[from]
		copy[from] = .Empty
		return copy
	}
	
	private func kingLocator(player: Player) -> Locator {
		for loc in Locator.all {
			if case .Occupied(player, .King) = self[loc] {
				return loc
			}
		}
		fatalError("missing king?")
	}
	
	func isCheck(player: Player) -> Bool {
		let kingLoc = kingLocator(player)
		let moves = Moves.calculate(self, player: player.opponent)
		return moves.goingTo(kingLoc).count != 0
	}
	
	func isCheckmate(player: Player) -> Bool {
		for move in Moves.calculate(self, player: player).all {
			let copy = self.move(move.0, to: move.1)
			if !copy.isCheck(player) {
				return false
			}
		}
		return true
	}
}

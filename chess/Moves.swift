//
//  Moves.swift
//  chess
//
//  Created by Félix on 16-02-12.
//  Copyright © 2016 Félix Cloutier. All rights reserved.
//

import Foundation

private let rookDeltas = [(-1, 0), (1, 0), (0, -1), (0, 1)]
private let bishopDeltas = [(-1, -1), (-1, 1), (1, -1), (1, 1)]
private let knightDeltas = [(-2, 1), (-2, -1), (2, 1), (2, -1), (-1, 2), (-1, -2), (1, 2), (1, -2)]
private let royalDeltas = bishopDeltas + rookDeltas

private func singleSquareMove(board: Board, player: Player, locator: Locator, inout moves: [Locator]) -> Bool {
	if case .Occupied(let occupier, _) = board[locator] {
		if occupier != player {
			moves.append(locator)
		}
		return false
	} else {
		moves.append(locator)
		return true;
	}
}

private func straightLineMoves(board: Board, locator: Locator, dx: Int, dy: Int, inout moves: [Locator]) {
	guard case .Occupied(let player, _) = board[locator] else {
		return
	}
	
	var accu = locator
	while let nextLoc = accu.delta(dx, dy) {
		accu = nextLoc
		if !singleSquareMove(board, player: player, locator: nextLoc, moves: &moves) {
			return
		}
	}
}

private func possibleMoves(board: Board, from: Locator) -> [Locator]? {
	guard case .Occupied(let player, let type) = board[from] else {
		return nil
	}
	
	var moves: [Locator] = []
	switch (type) {
	case .Pawn:
		if let oneForward = from.delta(0, player.direction) {
			if case .Empty = board[oneForward] {
				moves.append(oneForward)
				if let twoForward = oneForward.delta(0, player.direction), case .Empty = board[twoForward] {
					moves.append(twoForward)
				}
			}
			if let oneLeft = oneForward.delta(-1, 0), case .Occupied(player.opponent, _) = board[oneLeft] {
				moves.append(oneLeft)
			}
			if let oneRight = oneForward.delta(1, 0), case .Occupied(player.opponent, _) = board[oneRight] {
				moves.append(oneRight)
			}
		}
		
		// TODO: prise en passant
		
	case .Rook:
		for d in rookDeltas {
			straightLineMoves(board, locator: from, dx: d.0, dy: d.1, moves: &moves)
		}
		
	case .Bishop:
		for d in bishopDeltas {
			straightLineMoves(board, locator: from, dx: d.0, dy: d.1, moves: &moves)
		}
		
	case .Knight:
		for d in knightDeltas {
			if let destination = from.delta(d.0, d.1) {
				singleSquareMove(board, player: player, locator: destination, moves: &moves)
			}
		}
		
	case .Queen:
		for d in royalDeltas {
			straightLineMoves(board, locator: from, dx: d.0, dy: d.1, moves: &moves)
		}
		break
		
	case .King:
		for d in royalDeltas {
			if let destination = from.delta(d.0, d.1) {
				singleSquareMove(board, player: player, locator: destination, moves: &moves)
			}
		}
	}
	return moves
}

struct Moves {
	private let comingFrom: [Locator: [Locator]]
	private let goingTo: [Locator: [Locator]]
	
	static func calculate(board: Board, player: Player) -> Moves {
		var comingFrom = [Locator: [Locator]]()
		var goingTo = [Locator: [Locator]]()
		for loc in Locator.all {
			guard case .Occupied(player, _) = board[loc] else {
				continue
			}
			if let moves = possibleMoves(board, from: loc) {
				comingFrom[loc] = moves
				for move in moves {
					if goingTo[move] == nil {
						goingTo[move] = []
					}
					goingTo[move]!.append(loc)
				}
			}
		}
		return Moves(comingFrom: comingFrom, goingTo: goingTo)
	}
	
	private init(comingFrom: [Locator: [Locator]], goingTo: [Locator: [Locator]]) {
		self.comingFrom = comingFrom
		self.goingTo = goingTo
	}
	
	var all: [(Locator, Locator)] {
		return comingFrom.flatMap { k, v in v.map { (k, $0) } }
	}
	
	func goingTo(locator: Locator) -> [Locator] {
		return goingTo[locator] ?? []
	}
	
	func comingFrom(locator: Locator) -> [Locator] {
		return comingFrom[locator] ?? []
	}
}

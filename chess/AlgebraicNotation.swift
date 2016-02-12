//
//  AlgebraicNotation.swift
//  chess
//
//  Created by Félix on 16-02-12.
//  Copyright © 2016 Félix Cloutier. All rights reserved.
//

import Foundation

enum AlgebraicParserState {
	case CheckHint
	case DestRank
	case DestFile
	case CaptureHint
	case SourceRank
	case SourceFile
	case SourcePiece
	case Finished
}

private struct AlgebraicParser {
	var checkHint: CChar? = nil
	var destRank: UInt8? = nil
	var destFile: UInt8? = nil
	var captureHint = false
	var sourceRank: UInt8? = nil
	var sourceFile: UInt8? = nil
	var sourceType = Piece.Pawn
	var state = AlgebraicParserState.CheckHint
	
	mutating func consume(character: Character) -> Bool {
		switch state {
		case .CheckHint:
			if character == "+" {
				checkHint = 0x2b
				state = .DestRank
				return true
			}
			if character == "#" {
				checkHint = 0x23
				state = .DestRank
				return true
			}
			fallthrough
			
		case .DestRank:
			if let rank = Locator.rank(String(character)) {
				destRank = rank
				state = .DestFile
				return true
			}
			fallthrough
			
		case .DestFile:
			if let file = Locator.file(String(character)) {
				destFile = file
				state = .CaptureHint
				return true
			}
			guard destRank != nil else {
				return false
			}
			fallthrough
			
		case .CaptureHint:
			if character == "x" {
				captureHint = true
				state = .SourceRank
				return true
			}
			fallthrough
			
		case .SourceRank:
			if let rank = Locator.rank(String(character)) {
				sourceRank = rank
				state = .SourceFile
				return true
			}
			fallthrough
			
		case .SourceFile:
			if let file = Locator.file(String(character)) {
				sourceFile = file
				state = .SourcePiece
				return true
			}
			fallthrough
			
		case .SourcePiece:
			switch character {
			case "P": sourceType = .Pawn
			case "R": sourceType = .Rook
			case "N": sourceType = .Knight
			case "B": sourceType = .Bishop
			case "Q": sourceType = .Queen
			case "K": sourceType = .King
			default: return false;
			}
			state = .Finished
			return true
		
		case .Finished: return false
		}
	}
	
	func finished() -> Bool {
		if state != .Finished {
			if sourceRank == nil && sourceFile == nil {
				return false
			}
			
			if destRank == nil && destFile == nil {
				return false
			}
		}
		
		return true
	}
}

enum AlgebraicError: ErrorType {
	case ParseError
	case Illegal
	case Ambiguous
}

func parseAlgebraic(board: Board, player: Player, move: String) throws -> (Locator, Locator) {
	if move == "" {
		throw AlgebraicError.ParseError
	}
	
	var parser = AlgebraicParser()
	let characters = move.characters.reverse()
	for char in characters {
		if !parser.consume(char) {
			throw AlgebraicError.ParseError
		}
	}
	
	var possibleSourceLocs = [Locator]()
	for loc in Locator.all {
		if case .Occupied(player, parser.sourceType) = board[loc] {
			if let sourceRank = parser.sourceRank where sourceRank != loc.rank {
				continue
			}
			if let sourceFile = parser.sourceFile where sourceFile != loc.file {
				continue
			}
			possibleSourceLocs.append(loc)
		}
	}
	
	var source: Locator? = nil
	var destination: Locator? = nil
	let moves = Moves.calculate(board, player: player)
	for sourceLoc in possibleSourceLocs {
		for destLoc in moves.comingFrom(sourceLoc) {
			if let destRank = parser.destRank where destRank != destLoc.rank {
				continue
			}
			if let destFile = parser.destFile where destFile != destLoc.file {
				continue
			}
			
			let captures: Bool
			switch board[destLoc] {
			case .Occupied(_, _): captures = true
			default: captures = false
			}
			
			if captures != parser.captureHint {
				continue
			}
			
			if destination != nil {
				throw AlgebraicError.Ambiguous
			}
			
			source = sourceLoc
			destination = destLoc
			
		}
	}
	
	guard let dest = destination, src = source else {
		throw AlgebraicError.Illegal
	}
	
	return (src, dest)
}

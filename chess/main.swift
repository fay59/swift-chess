//
//  main.swift
//  chess
//
//  Created by Félix on 16-02-12.
//  Copyright © 2016 Félix Cloutier. All rights reserved.
//

let session = PlaySession()

session.xtermPrint()

var winner: Player? = nil
while winner == nil {
	print("(\(session.turn)) ", terminator: "")
	var optMove = readLine(stripNewline: true)
	guard let move = optMove else {
		continue
	}
	
	switch session.interpret(move) {
	case .SelfCheck: print("move would put king in check")
	case .ParseError: print("move is not algebraic notation")
	case .Illegal: print("no piece can make that move")
	case .Ambiguous: print("move is ambiguous")
	case .Success(let special):
		session.xtermPrint()
		switch special {
		case .Check(let player): print("\(player) is checked!")
		case .Checkmate(let player):
			print("\(player) is checkmate!")
			winner = player.opponent
		default: break
		}
	}
}

print("\(winner!) wins")
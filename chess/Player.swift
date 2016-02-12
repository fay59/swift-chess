//
//  Player.swift
//  chess
//
//  Created by Félix on 16-02-12.
//  Copyright © 2016 Félix Cloutier. All rights reserved.
//

import Foundation

enum Player {
	case Black
	case White
	
	var direction: Int {
		return self == .Black ? -1 : 1
	}
	
	var opponent: Player {
		return self == .Black ? .White : .Black
	}
	
	var description: String {
		return self == .Black ? "Black" : "White"
	}
}
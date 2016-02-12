//
//  Locator.swift
//  chess
//
//  Created by Félix on 16-02-12.
//  Copyright © 2016 Félix Cloutier. All rights reserved.
//

import Foundation

private let primes = [
	1987, 1993, 1997, 1999, 2003, 2011, 2017, 2027, 2029, 2039, 2053, 2063, 2069, 2081, 2083, 2087, 2089, 2099, 2111,
	2113, 2129, 2131, 2137, 2141, 2143, 2153, 2161, 2179, 2203, 2207, 2213, 2221, 2237, 2239, 2243, 2251, 2267, 2269,
	2273, 2281, 2287, 2293, 2297, 2309, 2311, 2333, 2339, 2341, 2347, 2351, 2357, 2371, 2377, 2381, 2383, 2389, 2393,
	2399, 2411, 2417, 2423, 2437, 2441, 2447, 2459]

private let fileNames: [Character] = ["a", "b", "c", "d", "e", "f", "g", "h"]

private func intToU8(int: Int) -> UInt8? {
	if int >= 0 && int <= Int(UInt8.max) {
		return UInt8(int)
	}
	return nil
}

struct Locator: Hashable {
	let rank: UInt8
	let file: UInt8
	
	var index: Int {
		return Int(rank * 8 + file)
	}
	
	var hashValue: Int {
		return primes[index]
	}
	
	var description: String {
		return "\(fileNames[Int(file)])\(rank+1)"
	}
	
	private init(rank: UInt8, file: UInt8) {
		self.rank = rank
		self.file = file
	}
	
	static var all: [Locator] {
		return (UInt8(0)..<UInt8(64)).map {
			Locator(rank: $0 / 8, file: $0 % 8)
		}
	}
	
	static func rank(stringVal: String) -> UInt8? {
		if let val = UInt8(stringVal) where val > 0 && val <= 8 {
			return val - 1
		}
		return nil
	}
	
	static func file(stringVal: String) -> UInt8? {
		let view = stringVal.lowercaseString.unicodeScalars
		if view.count != 1 {
			return nil
		}
		let file = view.first!.value - 0x61
		if file < 0 || file >= 8 {
			return nil
		}
		return UInt8(file)
	}
	
	static func fromCoords(file: UInt8?, rank: UInt8?) -> Locator? {
		if let f = file, r = rank where file < 8 && rank < 8 {
			return Locator(rank: r, file: f)
		}
		return nil
	}
	
	static func fromString(stringVal: String) -> Locator? {
		let view = stringVal.characters
		if view.count != 2 {
			return nil
		}
		
		let start = view.startIndex
		let end0 = start.advancedBy(1)
		let end1 = end0.advancedBy(1)
		if let rank = Locator.rank(String(view[start..<end0])), file = Locator.file(String(view[end0..<end1])) {
			return Locator(rank: rank, file: file)
		}
		return nil
	}
	
	func delta(dx: Int, _ dy: Int) -> Locator? {
		return Locator.fromCoords(intToU8(Int(file) + dx), rank: intToU8(Int(rank) + dy))
	}
}

func ==(lhs: Locator, rhs: Locator) -> Bool {
	return lhs.rank == rhs.rank && lhs.file == rhs.file
}

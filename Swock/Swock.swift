//
//  Swock.swift
//  Swock
//
//  Created by Daniel Clelland on 24/07/16.
//  Copyright © 2016 Daniel Clelland. All rights reserved.
//

import Foundation

public indirect enum Noun {
    
    case Atom(UInt)
    
    case Cell(Noun, Noun)
    
    init(_ elements: [Noun]) {
        switch (elements.head, elements.tail) {
        case (let head?, nil):
            self = head
        case (let head?, let tail?):
            self = .Cell(head, Noun(tail))
        default:
            fatalError("Empty noun")
        }
    }
    
}

extension Noun: IntegerLiteralConvertible {
    
    public init(integerLiteral value: UInt) {
        self = .Atom(value)
    }

}

extension Noun: ArrayLiteralConvertible {
    
    public init(arrayLiteral elements: Noun...) {
        self.init(elements)
    }
    
}

extension Noun: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .Atom(let value):
            return String(value)
        case .Cell(let head, let tail):
            return "[\(head.description) \(tail.description)]"
        }
    }
    
}

private extension Array {
    
    var head: Element? {
        return count > 0 ? self[0] : nil
    }
    
    var tail: [Element]? {
        return count > 1 ? Array(self[1..<count]) : nil
    }
    
}

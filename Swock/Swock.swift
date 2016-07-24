//
//  Swock.swift
//  Swock
//
//  Created by Daniel Clelland on 24/07/16.
//  Copyright © 2016 Daniel Clelland. All rights reserved.
//

import Foundation

/// A noun is an atom or a cell.

public indirect enum Noun {
    
    /// A cell is any ordered pair of nouns.
    
    case Cell(Noun, Noun)
    
    /// An atom is any natural number.
    
    case Atom(UInt)
    
    /// Initialise a noun with an array of nouns.
    /// Arrays right-associate into nested cells, e.g. `[a, b, c]` -> `[a, [b, c]]`.
    /// Crashes if the array is empty.
    
    init(_ nouns: [Noun]) {
        switch (nouns.head, nouns.tail) {
        case let (head?, tail?):
            self = .Cell(head, Noun(tail))
        case let (head?, nil):
            self = head
        default:
            fatalError("Empty noun")
        }
    }
    
}

// MARK: - Trivial operators

/// Returns true if the noun is a cell, and false if the noun is an atom.

public func wut(noun: Noun) -> Noun {
    switch noun {
    case .Cell:
        return true
    case .Atom:
        return false
    }
}

/// Returns an incremented atom.
/// Crashes if the noun is a cell.

public func lus(noun: Noun) -> Noun {
    switch noun {
    case let .Cell(a):
        fatalError("Cannot call `lus()` on a cell: \(a)")
    case let .Atom(a):
        return .Atom(a + 1)
    }
}

/// Returns true if the noun is a cell whose head and tail are identical, otherwise, returns false.
/// Crashes if the noun is an atom.

public func tis(noun: Noun) -> Noun {
    switch noun {
    case let .Cell(a, b):
        return a == b ? true : false
    case let .Atom(a):
        fatalError("Cannot call `tis()` on an atom: \(a)")
    }
}

// MARK: - Tree addressing

/// Uses the noun's head to retrieve the contents of the noun's tail, using a tree addressing system where the head of every noun `n` is `2n`, while the tail is `2n + 1`.

public func fas(noun: Noun) -> Noun {
    switch noun {
    case let .Cell(1,  a):
        return a
    case let .Cell(2, .Cell(a, _)):
        return a
    case let .Cell(3, .Cell(_, b)):
        return b
    case let .Cell(.Atom(axis), tree):
        let inner: Noun = .Atom(axis / 2)
        let outer: Noun = .Atom(2 + axis % 2)
        return fas([outer, fas([inner, tree])])
    default:
        fatalError("Invalid `fas()` arguments: \(noun)")
    }
}

// MARK: - Operators

/// Executes the noun's tail (the *formula*) using its head as the argument (the *subject*).

public func tar(noun: Noun) -> Noun {
    switch noun {
    case let .Cell(a, formula):
        switch formula {
        case let .Cell(.Cell(b, c), d):
            return .Cell(tar([a, b, c]), tar([a, d]))
        case let .Cell(0, b):
            return fas([b, a])
        case let .Cell(1, b):
            return b
        case let .Cell(2, .Cell(b, c)):
            return tar([tar([a, b]), tar([a, c])])
        case let .Cell(3, b):
            return wut(tar([a, b]))
        case let .Cell(4, b):
            return lus(tar([a, b]))
        case let .Cell(5, b):
            return tis(tar([a, b]))
        case let .Cell(6, .Cell(b, .Cell(c, d))):
            return tar([a, 2, [0, 1], 2, [1, c, d], [1, 0], 2, [1, 2, 3], [1, 0], 4, 4, b])
        case let .Cell(7, .Cell(b, c)):
            return tar([a, 2, b, 1, c])
        case let .Cell(8, .Cell(b, c)):
            return tar([a, 7, [[7, [0, 1], b], 0, 1], c])
        case let .Cell(9, .Cell(b, c)):
            return tar([a, 7, c, 2, [0, 1], 0, b])
        case let .Cell(10, .Cell(.Cell(_, c), d)):
            return tar([a, 8, c, 7, [0, 3], d])
        case let .Cell(10, .Cell(_, c)):
            return tar([a, c]);
        default:
            fatalError("Invalid `tar()` formula: \(formula)")
        }
    default:
        fatalError("Invalid `tar()` arguments: \(noun)")
    }
}

// MARK: - Boolean literal convertible

extension Noun: BooleanLiteralConvertible {
    
    public init(booleanLiteral value: Bool) {
        self = value ? 0 : 1
    }
    
}

// MARK: - Integer literal convertible

extension Noun: IntegerLiteralConvertible {
    
    public init(integerLiteral value: UInt) {
        self = .Atom(value)
    }

}

// MARK: - Array literal convertible

extension Noun: ArrayLiteralConvertible {
    
    public init(arrayLiteral elements: Noun...) {
        self.init(elements)
    }
    
}

// MARK: - Custom string convertible

extension Noun: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .Cell(let head, let tail):
            return "[\(head.description) \(tail.description)]"
        case .Atom(let value):
            return String(value)
        }
    }
    
}

// MARK: - Equatable

extension Noun: Equatable { }

public func == (left: Noun, right: Noun) -> Bool {
    switch (left, right) {
    case (.Atom(let leftValue), .Atom(let rightValue)):
        return leftValue == rightValue
    case (.Cell(let leftHead, let leftTail), .Cell(let rightHead, let rightTail)):
        return leftHead == rightHead && leftTail == rightTail
    default:
        return false
    }
}

// MARK: - Private extensions

private extension Array {
    
    var head: Element? {
        return count > 0 ? self[0] : nil
    }
    
    var tail: [Element]? {
        return count > 1 ? Array(self[1..<count]) : nil
    }
    
}

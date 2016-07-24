//
//  Swock.swift
//  Swock
//
//  Created by Daniel Clelland on 24/07/16.
//  Copyright © 2016 Daniel Clelland. All rights reserved.
//

import Foundation

public indirect enum Noun {
    
    case Cell(Noun, Noun)
    
    case Atom(UInt)
    
    init(_ elements: [Noun]) {
        switch (elements.head, elements.tail) {
        case let (head?, tail?):
            self = .Cell(head, Noun(tail))
        case let (head?, nil):
            self = head
        default:
            fatalError("Empty noun")
        }
    }
    
}

// MARK: - Booleans

public extension Noun {
    
    static let yes: Noun = 0
    
    static let no: Noun = 1
    
}

// MARK: - Nock operators

public func wut(noun: Noun) -> Noun {
    switch noun {
    case .Cell:
        return .yes
    case .Atom:
        return .no
    }
}

public func lus(noun: Noun) -> Noun {
    switch noun {
    case .Cell:
        fatalError("Cannot call `lus()` on a cell")
    case let .Atom(a):
        return .Atom(a + 1)
    }
}

public func tis(noun: Noun) -> Noun {
    switch noun {
    case let .Cell(a, b):
        return a == b ? .yes : .no
    case .Atom:
        fatalError("Cannot call `tis()` on an atom")
    }
}

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
        fatalError("Invalid `fas()` arguments")
    }
}

public func tar(noun: Noun) -> Noun {
    switch noun {
    case let .Cell(a, formula):
        switch formula {
            
        // If the head of the formula is a cell, Nock treats both head and tail as formulas, resolves each against the subject, and produces the cell of their products.
        // *[a [b c] d] -> [*[a b c] *[a d]]
            
        case let .Cell(.Cell(b, c), d):
            return .Cell(tar([a, b, c]), tar([a, d]))
            
        // A formula [0 b] produces the noun at tree address b in the subject.
        // *[a 0 b] -> /[b a]
            
        case let .Cell(0, b):
            return fas([b, a])
            
        // A formula [1 b] produces the constant noun b.
        // *[a 1 b] -> b
            
        case let .Cell(1, b):
            return b
            
        // A formula [2 b c] treats b and c as formulas, resolves each against the subject, then computes Nock again with the product of b as the subject, c as the formula.
        // *[a 2 b c] -> *[*[a b] *[a c]]
            
        case let .Cell(2, .Cell(b, c)):
            return tar([tar([a, b]), tar([a, c])])
            
        // A formula [3 b], [4 b], and [5 b], b is another formula, whose product against the subject becomes the input to an axiomatic operator. 3 is ?, 4 is +, 5 is =.
        // *[a 3 b] -> ?*[a b]
            
        case let .Cell(3, b):
            return wut(tar([a, b]))
            
        // *[a 4 b] -> +*[a b]
            
        case let .Cell(4, b):
            return lus(tar([a, b]))
            
        // *[a 5 b] -> =*[a b]
            
        case let .Cell(5, b):
            return tis(tar([a, b]))
            
        // [6 b c d] is if b, then c, else d. Each of b, c, d is a formula against the subject. Remember that 0 is true and 1 is false.
        // *[a 6 b c d] -> *[a 2 [0 1] 2 [1 c d] [1 0] 2 [1 2 3] [1 0] 4 4 b]
            
        case let .Cell(6, .Cell(b, .Cell(c, d))):
            return tar([a, 2, [0, 1], 2, [1, c, d], [1, 0], 2, [1, 2, 3], [1, 0], 4, 4, b])
            
        // [7 b c] composes the formulas b and c.
        // *[a 7 b c] -> *[a 2 b 1 c]
            
        case let .Cell(7, .Cell(b, c)):
            return tar([a, 2, b, 1, c])
            
        // [8 b c] produces the product of formula c, against a subject whose head is the product of formula b with the original subject, and whose tail is the original subject. (Think of 8 as a "variable declaration" or "stack push.")
        // *[a 8 b c] -> *[a 7 [[7 [0 1] b] 0 1] c]
            
        case let .Cell(8, .Cell(b, c)):
            return tar([a, 7, [[7, [0, 1], b], 0, 1], c])
            
        // [9 b c] computes the product of formula c with the current subject; from that product d it extracts a formula e at tree address b, then computes *[d e]. (9 is designed to fit Hoon; d is a core (object), e points to an arm (method).)
        // *[a 9 b c] -> *[a 7 c 2 [0 1] 0 b]
            
        case let .Cell(9, .Cell(b, c)):
            return tar([a, 7, c, 2, [0, 1], 0, b])
            
        // [10 b c] is a hint semantically equivalent to the formula c. If b is an atom, it's a static hint, which is just discarded. If b is a cell, it's a dynamic hint; the head of b is discarded, and the tail of b is executed as a formula against the current subject; the product of this is discarded.
        // *[a 10 [b c] d] -> *[a 8 c 7 [0 3] d]
            
        case let .Cell(10, .Cell(.Cell(_, c), d)):
            return tar([a, 8, c, 7, [0, 3], d])
            
        // *[a 10 b c] -> *[a c]
            
        case let .Cell(10, .Cell(_, c)):
            return tar([a, c]);
        default:
            fatalError("Invalid `tar()` formula")
        }
    default:
        fatalError("Invalid `tar()` arguments")
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

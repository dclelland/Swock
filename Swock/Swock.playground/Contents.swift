/*:
 # Nock in Swift
 */
import Foundation
import Swock
/*:
 ## Nouns
 Nouns can be initialised from booleans, integers, or (non-empty) arrays.
 */
let boolean: Noun = true
let integer: Noun = 42
let array: Noun = [1, 2, 3, 4]
/*:
 ## Trivial operators
 ### `wut`, `?`
 Returns true if the noun is a cell, and false if the noun is an atom.
 ```
 ?[a b]           0
 ?a               1
 ```
 */
wut([1, 2])
wut(1)
/*:
 ### `lus`, `+`
 Increments an atom.
 Crashes if the noun is a cell.
 ```
 +a               1 + a
 ```
 */
lus(1)
lus(43)
/*:
 ### `tis`, `=`
 Compares the head and tail of a cell.
 Crashes if the noun is an atom.
 ```
 =[a a]           0
 =[a b]           1
 ```
 */
tis([1, 1])
tis([1, 2])
/*:
 ## Tree addressing
 ### `fas`, `/`
 Uses the noun's head to retrieve the contents of the noun's tail, using a tree addressing system where the head of every noun `n` is `2n`, while the tail is `2n + 1`.
 ```
 /[1 a]           a
 /[2 a b]         a
 /[3 a b]         b
 /[(a + a) b]     /[2 /[a b]]
 /[(a + a + 1) b] /[3 /[a b]]
 /a               /a
 ```
 */
fas([1, [1, 2]])
fas([2, [1, 2]])
fas([3, [1, 2]])
fas([.Atom(2 + 2), [[1, 2], [3, 4]]])
fas([.Atom(2 + 2 + 1), [[1, 2], [3, 4]]])
/*:
 ## Nock
 ### `tar`, `*`
 Executes the noun's tail (the *formula*) using its head as the argument (the *subject*).
 */

// *[a [b c] d]     [*[a b c] *[a d]]

//tar([1, [2, 3], 4])

// *[a 0 b]         /[b a]
// *[a 1 b]         b
// *[a 2 b c]       *[*[a b] *[a c]]
// *[a 3 b]         ?*[a b]
// *[a 4 b]         +*[a b]
// *[a 5 b]         =*[a b]

// *[a 6 b c d]     *[a 2 [0 1] 2 [1 c d] [1 0] 2 [1 2 3] [1 0] 4 4 b]
// *[a 7 b c]       *[a 2 b 1 c]
// *[a 8 b c]       *[a 7 [[7 [0 1] b] 0 1] c]
// *[a 9 b c]       *[a 7 c 2 [0 1] 0 b]
// *[a 10 [b c] d]  *[a 8 c 7 [0 3] d]
// *[a 10 b c]      *[a c]

// *a               *a



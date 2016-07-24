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
 ### `?`, 'wut'
 Returns true if the noun is a cell, and false if the noun is an atom.
 ```
 ?[a b]           0
 ?a               1
 ```
 */
wut([1, 2])
wut(1)
/*:
 ### `+`, 'lus'
 Increments an atom.
 Crashes if the noun is a cell.
 ```
 +a               1 + a
 ```
 */
lus(1)
lus(43)
/*:
 ### `=`, 'tis'
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
 ### `/`, 'fas'
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
do {
    let tree: Noun = [1, 2]
    
    fas([1, tree])
    fas([2, tree])
    fas([3, tree])
}

do {
    let tree: Noun = [[1, 2], [3, 4]]
    
    fas([4, tree])
    fas([5, tree])
}
/*:
 ## Nock
 ### `*`, 'tar'
 Executes the noun's tail (the *formula*) using its head as the argument (the *subject*).
 
 ```
 *[a [b c] d]     [*[a b c] *[a d]]
 *a               *a
 ```
*/

/*:
 ## Nock opcodes
 ### `0`, 'slot'
 Can be viewed as an alias for `fas`.
 
 A formula `[0 b]` produces the noun at tree address `b` in the subject.
 ```
 *[a 0 b]         /[b a]
 ```
 */
do {
    let tree: Noun = [1, 2]
    let axis: Noun = 3
    
    fas([axis, tree])
    tar([tree, [0, axis]])
}
/*:
 ### `1`, 'constant'
 Produces an argument without reference to the subject.
 
 A formula `[1 b]` produces the constant noun `b`.
 ```
 *[a 1 b]         b
 ```
 */
do {
    let subject: Noun = 12
    let argument: Noun = 34
    
    tar([subject, [1, argument]])
}
/*:
 ### `2`, 'evaluate'
 The Nock instruction itself, like `eval()` in JavaScript.
 
 A formula `[2 b c]` treats `b` and `c` as formulas, resolves each against the subject, then computes Nock again with the product of `b` as the subject, `c` as the formula.
 ```
 *[a 2 b c]       *[*[a b] *[a c]]
 ```
 */
do {
    let tree1: Noun = [[35, 36], 37]
    let tree2: Noun = [41, [42, 43]]
    let axis: Noun = 2
    
    wut(fas([axis, tree1]))
    wut(fas([axis, tree2]))
    
    wut(tar([tree1, 0, axis]))
    wut(tar([tree2, 0, axis]))
    
    // Not sure I really grok this one...
    
    let subject: Noun = 77
    let argument1: Noun = [1, 42]
    let argument2: Noun = [1, 1, 153, 218]
    
    tar([subject, [2, argument1, argument2]])
    tar([tar([subject, argument1]), tar([subject, argument2])])
}
/*:
 ### `3`, `4`, `5`, 'axiomatic functions'
 Aliases for `wut`, `lus`, and `tis`, respectively.
 
 In formulas `[3 b]`, `[4 b]`, and `[5 b]`, `b` is another formula, whose product against the subject becomes the input to an axiomatic operator.
 ```
 *[a 3 b]         ?*[a b]
 *[a 4 b]         +*[a b]
 *[a 5 b]         =*[a b]
 ```
 */
do {
    let tree: Noun = [[35, 36], 37]
    let axis: Noun = 2
    
    wut(fas([axis, tree]))
    wut(tar([tree, [0, axis]]))
    tar([tree, [3, [0, axis]]])
}

do {
    let tree: Noun = [45, 67]
    let axis: Noun = 2
    
    lus(fas([axis, tree]))
    lus(tar([tree, [0, axis]]))
    tar([tree, [4, [0, axis]]])
}

do {
    let tree: Noun = [[88, 88], [88, 89]]
    let axis: Noun = 2
    
    tis(fas([axis, tree]))
    tis(tar([tree, [0, axis]]))
    tar([tree, [3, [0, axis]]])
}
/*:
 ### `6`, 'if-then-else'
 `[6 b c d]` is *if* `b`, *then* `c`, *else* `d`.  Each of `b`, `c`, `d` is a formula against the subject.
 
 Remember that `0` is true and `1` is false.
 ```
 *[a 6 b c d]     *[a 2 [0 1] 2 [1 c d] [1 0] 2 [1 2 3] [1 0] 4 4 b]
 ```
 */

/*:
 ### `7`, 'compose'
 `[7 b c]` composes the formulas `b` and `c`.
 ```
 *[a 7 b c]       *[a 2 b 1 c]
 ```
 */

/*:
 ### `8`, 'extend'
 `[8 b c]` produces the product of formula `c`, against a subject whose head is the product of formula `b` with the original subject, and whose tail is the original subject. (Think of `8` as a "variable declaration" or "stack push.")
 ```
 *[a 8 b c]       *[a 7 [[7 [0 1] b] 0 1] c]
 ```
 */

/*:
 ### `9`, 'invoke'
 `[9 b c]` computes the product of formula `c` with the current subject; from that product `d` it extracts a formula `e` at tree address `b`, then computes `*[d e]`. (`9` is designed to fit Hoon; `d` is a `core` (object), `e` points to an arm (method).)
 ```
 *[a 9 b c]       *[a 7 c 2 [0 1] 0 b]
 ```
 */

/*:
 ### `10`, 'hint'
 `[10 b c]` is a *hint* semantically equivalent to the formula `c`.
 
 If `b` is an atom, it's a *static hint*, which is just discarded.
 
 If `b` is a cell, it's a *dynamic* hint; the head of `b` is discarded, and the tail of `b` is executed as a formula against the current subject; the product of this is discarded.
 ```
 *[a 10 [b c] d]  *[a 8 c 7 [0 3] d]
 *[a 10 b c]      *[a c]
 ```
 */
do {
    let tree: Noun = [45, 67]
    let axis: Noun = 1
    let comment: Noun = 65537
    
    fas([axis, tree])
    tar([tree, 10, comment, [0, axis]]) // should print `65537`
}

do {
    
}
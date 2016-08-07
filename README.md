# Swock

[Nock](https://urbit.org/docs/nock/definition/) implementation in Swift.

Contains an Xcode playground I'm using to teach myself about Nock.

Partially cribbed from the [Nock examples page](https://urbit.org/docs/nock/implementations/swift/).

## Nouns

```swift
let boolean: Noun = true // 0
let integer: Noun = 42 // 42
let array: Noun = [1, 2, 3, 4] // [1 [2 [3 4]]]
```

## Trivial operators

```swift
wut([1, 2]) // 0
wut(1) // 1

lus(1) // 2
lus(43) // 44

tis([1, 1]) // 0
tis([1, 2]) // 1
```

## Tree addressing

```swift
let tree: Noun = [1, 2]

fas([1, tree]) // [1 2]
fas([2, tree]) // 1
fas([3, tree]) // 2
```

## Nock

```swift
let tree: Noun = [45, 67]
let axis: Noun = 2

lus(fas([axis, tree])) // 46
lus(tar([tree, [0, axis]])) // 46
tar([tree, [4, [0, axis]]]) // 46
```
import aoc
import strutils, sequtils, parseutils, options

# TODO: Better `nil` handling for `Node` - can the `not nil` annotation help?

type
  NodeKind = enum
    nkSnailfish
    nkRegular
  Node = ref object
    case kind: NodeKind
    of nkSnailfish:
      left, right: Node
    of nkRegular:
      value: int

func `==`(a, b: Node): bool =
  result = a.kind == b.kind
  if result:
    case a.kind:
      of nkSnailfish:
        result = a.left == b.left and a.right == b.right
      of nkRegular:
        result = a.value == b.value

func `$`(n: Node): string =
  ## String representation of `n` (primarily for debugging)
  if n.isNil: return "nil"
  case n.kind:
    of nkRegular:
      return $n.value
    of nkSnailfish:
      return ("[" & $n.left & "," & $n.right & "]")

func maybeExplode(n: var Node): bool =
  var
    # Previous (e.g. previous depth) node to the left of the current node
    prevLeft = none(Node)
    # Right child value of the pair to explode
    rightNumber = none(int)
    # Did a pair get exploded?
    exploded = false
  func walk(n: var Node, depth = 0) =
    if exploded:
      return
    case n.kind:
      of nkSnailfish:
        if depth == 4 and rightNumber.isNone():
          # This pair needs exploding
          if prevLeft.isSome():
            assert n.left.kind == nkRegular
            assert n.right.kind == nkRegular
            inc(prevLeft.get().value, n.left.value)
          # Replace pair with regular value of 0
          rightNumber = some(n.right.value)
          n = Node(kind: nkRegular, value: 0)
          return
        else:
          walk(n.left, depth = depth+1)
          walk(n.right, depth = depth+1)
      of nkRegular:
        if rightNumber.isNone():
          # Still looking for a pair to explode -> record the current node as the
          # previous left node in case the next pair needs exploding
          prevLeft = some(n)
        else:
          # Pair has already been exploded to the left -> now explode to the right
          inc(n.value, rightNumber.get())
          exploded = true
  walk(n)
  rightNumber.isSome()

func maybeSplit(n: var Node): bool =
  var didSplit = false
  func walk(n: var Node) =
    if didSplit:
      return
    case n.kind:
      of nkSnailfish:
        # Still looking for a regular number to split
        walk(n.left)
        walk(n.right)
      of nkRegular:
        if n.value >= 10:
          # Split this number
          let (x, r) = divmod(n.value, 2)
          n = Node(
            kind: nkSnailfish,
            left: Node(kind: nkRegular, value: x),
            right: Node(kind: nkRegular, value: x + r),
          )
          didSplit = true
  walk(n)
  didSplit

func `+`(a, b: Node): Node =
  var n = Node(kind: nkSnailfish, left: deepCopy(a), right: deepCopy(b))
  # Reduce
  while true:
    if maybeExplode(n):
      # Apply one action at a time
        continue
    if not maybeSplit(n):
      break
  n

func magnitude(n: Node): int =
  case n.kind:
    of nkRegular:
      return n.value
    of nkSnailfish:
      return 3 * magnitude(n.left) + 2 * magnitude(n.right)

func parseSnailfish(s: string): Node =
  ## Note: this assumes well-formed input
  var i = 0
  proc parse(): Node =
    if s[i] == '[':
      inc i
      let l = parse()
      inc i # skip ','
      let r = parse()
      inc i # skip ']'
      return Node(kind: nkSnailfish, left: l, right: r)
    else:
      var x: int
      let n = parseInt(s, x, start = i)
      assert n > 0
      inc(i, n) # Skip digits of x
      return Node(kind: nkRegular, value: x)
  parse()

proc parseInput(s: string): seq[Node] =
  s.strip().splitLines.map(parseSnailfish)

proc part1(numbers: seq[Node]): int =
  numbers.foldl(a + b).magnitude

proc main() =
  const input = staticRead("../inputs/d18.txt")
  let numbers = parseInput(input)
  echo "part 1: ", part1(numbers)
  #echo "part 2: "

when isMainModule:
  when defined(testing):
    import unittest

    test "Node equality":
      check:
        # nkRegular same value
        Node(kind: nkRegular, value: 1) == Node(kind: nkRegular, value: 1)
        # nkRegular different value
        Node(kind: nkRegular, value: 1) != Node(kind: nkRegular, value: 2)
        # nkSnailfish same children
        Node(
          kind: nkSnailfish,
          left: Node(kind: nkRegular, value: 1),
          right: Node(kind: nkRegular, value: 2),
        ) == Node(
          kind: nkSnailfish,
          left: Node(kind: nkRegular, value: 1),
          right: Node(kind: nkRegular, value: 2),
        )
        # nkSnailfish different children
        Node(kind: nkRegular, value: 1) != Node(
          kind: nkSnailfish,
          left: Node(kind: nkRegular, value: 1),
          right: Node(kind: nkRegular, value: 2),
        )

    test "parsing":
      check:
        parseSnailfish("[1,2]") == Node(
          kind: nkSnailfish,
          left: Node(kind: nkRegular, value: 1),
          right: Node(kind: nkRegular, value: 2),
        )
        parseSnailfish("[[1,2],3]") == Node(
          kind: nkSnailfish,
          left: Node(
            kind: nkSnailfish,
            left: Node(kind: nkRegular, value: 1),
            right: Node(kind: nkRegular, value: 2),
          ),
          right: Node(kind: nkRegular, value: 3),
        )

    test "maybeExplode":
      var n = parseSnailfish("[[[[[9,8],1],2],3],4]")
      check:
        maybeExplode(n)
        n == parseSnailfish("[[[[0,9],2],3],4]")

      n = parseSnailfish("[7,[6,[5,[4,[3,2]]]]]")
      check:
        maybeExplode(n)
        n == parseSnailfish("[7,[6,[5,[7,0]]]]")

      n = parseSnailfish("[[6,[5,[4,[3,2]]]],1]")
      check:
        maybeExplode(n)
        n == parseSnailfish("[[6,[5,[7,0]]],3]")

      n = parseSnailfish("[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]")
      check:
        maybeExplode(n)
        n == parseSnailfish("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]")

      n = parseSnailfish("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]")
      check:
        maybeExplode(n)
        n == parseSnailfish("[[3,[2,[8,0]]],[9,[5,[7,0]]]]")

      n = parseSnailfish("[[3,[2,[8,0]]],5]")
      let nCopy = deepCopy(n)
      check:
        not maybeExplode(n)
        n == nCopy

    test "maybeSplit":
      var n = parseSnailfish("[10,1]")
      check:
        maybeSplit(n)
        n == parseSnailfish("[[5,5],1]")

      n = parseSnailfish("[11,1]")
      check:
        maybeSplit(n)
        n == parseSnailfish("[[5,6],1]")

      n = parseSnailfish("[12,1]")
      check:
        maybeSplit(n)
        n == parseSnailfish("[[6,6],1]")

      n = parseSnailfish("[9,1]")
      let nCopy = deepCopy(n)
      check:
        not maybeSplit(n)
        n == nCopy

    test "addition":
      check:
        [
          "[[[[4,3],4],4],[7,[[8,4],9]]]",
          "[1,1]"
        ].map(parseSnailfish).foldl(a + b) == parseSnailfish("[[[[0,7],4],[[7,8],[6,0]]],[8,1]]")

        [
          "[1,1]",
          "[2,2]",
          "[3,3]",
          "[4,4]",
        ].map(parseSnailfish).foldl(a + b) == parseSnailfish("[[[[1,1],[2,2]],[3,3]],[4,4]]")

        [
          "[1,1]",
          "[2,2]",
          "[3,3]",
          "[4,4]",
          "[5,5]",
        ].map(parseSnailfish).foldl(a + b) == parseSnailfish("[[[[3,0],[5,3]],[4,4]],[5,5]]")

        [
          "[1,1]",
          "[2,2]",
          "[3,3]",
          "[4,4]",
          "[5,5]",
          "[6,6]",
        ].map(parseSnailfish).foldl(a + b) == parseSnailfish("[[[[5,0],[7,4]],[5,5]],[6,6]]")

        [
          "[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]",
          "[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]",
          "[[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]",
          "[[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]",
          "[7,[5,[[3,8],[1,4]]]]",
          "[[2,[2,2]],[8,[8,1]]]",
          "[2,9]",
          "[1,[[[9,3],9],[[9,0],[0,7]]]]",
          "[[[5,[7,4]],7],1]",
          "[[[[4,2],2],6],[8,7]]",
        ].map(parseSnailfish).foldl(a + b) == parseSnailfish("[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]")

      test "magnitude":
        check:
          magnitude(parseSnailfish("[[1,2],[[3,4],5]]")) == 143
          magnitude(parseSnailfish("[[[[0,7],4],[[7,8],[6,0]]],[8,1]]")) == 1384
          magnitude(parseSnailfish("[[[[1,1],[2,2]],[3,3]],[4,4]]")) == 445
          magnitude(parseSnailfish("[[[[3,0],[5,3]],[4,4]],[5,5]]")) == 791
          magnitude(parseSnailfish("[[[[5,0],[7,4]],[5,5]],[6,6]]")) == 1137
          magnitude(parseSnailfish("[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]")) == 3488

      test "part 1":
        let input = """[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
          [[[5,[2,8]],4],[5,[[9,9],0]]]
          [6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
          [[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
          [[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
          [[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
          [[[[5,4],[7,7]],8],[[8,3],8]]
          [[9,3],[[9,9],[6,[4,9]]]]
          [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
          [[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
        """.unindent
        check part1(parseInput(input)) == 4140

  else:
    main()


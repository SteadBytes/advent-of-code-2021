import aoc
import strutils, sequtils, tables, options, algorithm

# TODO: Would `case` be more efficient or does Nim optimise these constant
# table lookups into something equivalent?
const pairs = {'(': ')', '[': ']', '{': '}', '<': '>'}.toTable()
const scores = {')': 3, ']': 57, '}': 1197, '>': 25137}.toTable()
const completionScores = {')': 1, ']': 2, '}': 3, '>': 4}.toTable()

# TODO: Is there a useful form of these two that reduces duplication?

func syntaxErrorScore(line: string): int =
  var stack: seq[char]
  for c in line:
    if c in pairs:
      stack.add(c)
    elif c == pairs[stack[^1]]:
      discard stack.pop()
    else:
      return scores[c]

func correctionScore(line: string): Option[int] =
  var stack: seq[char]
  for c in line:
    if c in pairs:
      stack.add(c)
    elif c == pairs[stack[^1]]:
      discard stack.pop()
    else:
      # Corrupted line
      return none(int)
  # Valid line
  if stack.len == 0:
    return none(int)
  # Incomplete line
  # Why does `foldl` have an implementation with a starting value but `foldr` does not?!
  # some(stack.foldr(a * 5 + completionScores[pairs[b]], 0))
  some(stack.reversed().foldl(a * 5 + completionScores[pairs[b]], 0))


proc main() =
  const input = staticRead("../inputs/d10.txt")
  let lines = input.strip().splitLines()

  echo "part 1: ", lines.map(syntaxErrorScore).foldl(a + b)

  let scores = lines.filterMap(correctionScore)
  echo "part 2: ", scores.sorted()[scores.len div 2]

when isMainModule:
  main()

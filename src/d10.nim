import strutils, sequtils, tables

# TODO: Would `case` be more efficient or does Nim optimise these constant
# table lookups into something equivalent?
const pairs = {'(': ')', '[': ']', '{': '}', '<': '>'}.toTable()
const scores = {')': 3, ']': 57, '}': 1197, '>': 25137}.toTable()

func syntaxErrorScore(line: string): int = 
  var stack: seq[char]
  for c in line:
    if c in pairs:
      stack.add(c)
    elif c == pairs[stack[^1]]:
      discard stack.pop()
    else:
      return scores[c]

proc main() =
  const input = staticRead("../inputs/d10.txt")

  echo "part 1: ", input.strip().splitLines().map(syntaxErrorScore).foldl(a + b)
  #echo "part 2: "

when isMainModule:
  main()

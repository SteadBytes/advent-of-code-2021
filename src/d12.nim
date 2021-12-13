import strutils, sequtils, strscans, tables

func parseConnection(s: string): (string, string) =
  let (ok, s1, s2) = scanTuple(s, "$*-$*")
  assert ok
  (s1, s2)

# Note: The small/big cave rules make the problem tractable as without them,
# finding _all_ paths through the graph would be NP hard due to it not being
# acyclic.

func countPaths(g: Table[string, seq[string]], canRevisit: bool = false): int =
  var stack = @[(@["start"], canRevisit)]
  while stack.len > 0:
    let (path, canRevisit) = stack.pop()
    if path[^1] == "end":
      # Complete path found
      inc result
    else:
      # Always explore adjacent big caves or not previously explored small
      # caves
      for n2 in g[path[^1]]:
        if n2[0].isUpperAscii() or n2 notin path:
          stack.add((path & n2, canRevisit))
        # Note: Visiting end only once is already handled above when a
        # complete path is found
        elif canRevisit and n2 != "start":
          stack.add((path & n2, false))

func parseInput(s: string): Table[string, seq[string]] =
  result = initTable[string, seq[string]]()
  for (x, y) in s.strip().splitLines().map(parseConnection):
    result.mgetOrPut(x, @[]).add(y)
    result.mgetOrPut(y, @[]).add(x)

proc main() =
  const input = staticRead("../inputs/d12.txt")
  let g = parseInput(input)
  echo "part 1: ", countPaths(g)
  echo "part 2: ", countPaths(g, canRevisit = true)

when isMainModule:
  main()


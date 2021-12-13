import strutils, sequtils, strscans, tables

func parseConnection(s: string): (string, string) =
  let (ok, s1, s2) = scanTuple(s, "$*-$*")
  assert ok
  (s1, s2)

# Note: The small/big cave rules make the problem tractable as without them,
# finding _all_ paths through the graph would be NP hard due to it not being
# acyclic.

func part1(g: Table[string, seq[string]]): int =
  # Basic DFS to find all paths through the graph. There's a lot of
  # string/array copying going on here which could be optimised by not
  # referencing nodes with strings but this works and executes extremely
  # quickly anyway.
  var stack = @[@["start"]]
  while stack.len > 0:
    let path = stack.pop()
    if path[^1] == "end":
      # Complete path found
      inc result
    else:
      # Continue exploring path to adjacent big caves or not previously
      # explored small caves
      for n2 in g[path[^1]]:
        if n2[0].isUpperAscii() or n2 notin path:
          stack.add(path & n2)

func part2(g: Table[string, seq[string]]): int =
  var stack = @[(@["start"], true)]
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

proc main() =
  const input = staticRead("../inputs/d12.txt")
  let g =
    block:
      var g: Table[string, seq[string]]
      for (x, y) in input.strip().splitLines().map(parseConnection):
        g.mgetOrPut(x, @[]).add(y)
        g.mgetOrPut(y, @[]).add(x)
      g

  echo "part 1: ", part1(g)
  echo "part 2: ", part2(g)

when isMainModule:
  main()


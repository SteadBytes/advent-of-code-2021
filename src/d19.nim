import aoc
import strutils, sequtils, strscans, sugar, sets, tables, algorithm

type
  Coord3D = array[3, int]
  Report = seq[seq[Coord3D]]
  ## Beacon, closest neighbour, second closest neighbour
  Neighbours = (Coord3D, Coord3D, Coord3D)
  ## Beacon signature -> neighbours
  NeighbourMap = Table[int, Neighbours]

template x(c: Coord3D): int = c[0]
template y(c: Coord3D): int = c[1]
template z(c: Coord3D): int = c[2]
template `+`(a, b: Coord3D): Coord3D = [a.x + b.x, a.y + b.y, a.z + b.z]
template `-`(a, b: Coord3D): Coord3D = [a.x - b.x, a.y - b.y, a.z - b.z]
proc abs(c: Coord3D): Coord3D =
  [abs(c.x), abs(c.y), abs(c.z)]

func manhattan(c1, c2: Coord3D): int =
  let c = (c1 - c2).abs()
  c.x + c.y + c.z

func parseBeacon(s: string): Coord3D =
  let (ok, x, y, z) = scanTuple(s, "$i,$i,$i")
  assert ok
  [x, y, z]

func parseInput(s: string): Report =
  s.strip().split("\n\n").mapIt(it.splitLines()[1..^1].map(parseBeacon))

func mapNeighbours(beacons: seq[Coord3D]): NeighbourMap =
  for c in beacons:
    var dist: Table[int, Coord3D]
    for c2 in beacons:
      if c != c2:
        dist[manhattan(c, c2)] = c2
    let (d1, d2) =
      block:
        let x = dist.keys.toSeq.sorted()[0..<2]
        (x[0], x[1])
    let neighbour1 = dist[d1]
    let neighbour2 = dist[d2]
    let sig = (d1 + d2) * manhattan(neighbour1, neighbour2)
    result[sig] = (c, neighbour1, neighbour2)

func findMatch(
  reference: NeighbourMap,
  scanners: Table[int, NeighbourMap]
): (int, Neighbours, Neighbours) =
  ## Finds the first scanner with a beacon signature in `reference`. Returns
  ## the scanner index and the matching beacons/neighbours from `reference` and
  ## the scanner.
  for refSig, refNeighbours in reference:
    for scanner, scannerMap in scanners:
      for scannerSig, scannerNeighbours in scannerMap:
        if scannerSig == refSig:
          return (scanner, refNeighbours, scannerNeighbours)

## 24 possible orientations:
##
## Facing +ve x:
## (x, y, z), (x, z, -y), (x, -y, -z), (x, -z, y)
##
## Facing -ve x:
## (-x, -y, z), (-x, -z, y), (-x, y, -z), (-x, -z, -y)
##
## Facing -ve y:
## (y, z, x), (y, x, -z), (y, -z, -x), (y, -x, z)
##
## Facing -ve y:
## (-y, -z, x), (-y, x, z), (-y, z, -x), (-y, -x, -z)
##
## Facing -ve z:
## (z, x, y), (z, y, -x), (z, -x, -y), (z, -y, x)
##
## Facing -ve z:
## (-z, -x, y), (-z, y, x), (-z, x, -y), (-z, -y, -x)
const orientations = [
  (a: Coord3D) => [a[0], a[1], a[2]],
  (a: Coord3D) => [a[1], a[2], a[0]],
  (a: Coord3D) => [a[2], a[0], a[1]],
  (a: Coord3D) => [-a[0], a[2], a[1]],
  (a: Coord3D) => [a[2], a[1], -a[0]],
  (a: Coord3D) => [a[1], -a[0], a[2]],
  (a: Coord3D) => [a[0], a[2], -a[1]],
  (a: Coord3D) => [a[2], -a[1], a[0]],
  (a: Coord3D) => [-a[1], a[0], a[2]],
  (a: Coord3D) => [a[0], -a[2], a[1]],
  (a: Coord3D) => [-a[2], a[1], a[0]],
  (a: Coord3D) => [a[1], a[0], -a[2]],
  (a: Coord3D) => [-a[0], -a[1], a[2]],
  (a: Coord3D) => [-a[1], a[2], -a[0]],
  (a: Coord3D) => [a[2], -a[0], -a[1]],
  (a: Coord3D) => [-a[0], a[1], -a[2]],
  (a: Coord3D) => [a[1], -a[2], -a[0]],
  (a: Coord3D) => [-a[2], -a[0], a[1]],
  (a: Coord3D) => [a[0], -a[1], -a[2]],
  (a: Coord3D) => [-a[1], -a[2], a[0]],
  (a: Coord3D) => [-a[2], a[0], -a[1]],
  (a: Coord3D) => [-a[0], -a[2], -a[1]],
  (a: Coord3D) => [-a[2], -a[1], -a[0]],
  (a: Coord3D) => [-a[1], -a[0], -a[2]],
]

proc findAlignment(reference, scanner: Neighbours): (Coord3D -> Coord3D) =
  for o in orientations:
    var offsets: HashSet[Coord3D]
    for b1, b2 in fields(reference, scanner):
      offsets.incl(b1 - o(b2))
    if offsets.len == 1:
      let offset = offsets.pop()
      return (a: Coord3D) => o(a) + offset

proc part1(report: Report): int =
  ## The manhattan distance between a pair of beacons is consistent between
  ## rotations.
  ##
  ## Create a "signature" to uniquely identify a beacon and 2 nearest neighbours
  ##
  ## Align scanners to the first scanner in the report (e.g. scanner 0 is the
  ## "reference" oriented at (0, 0, 0))
  ##
  ##
  ## Find matching beacons by searching for equal beacon signatures. The
  ## correct orientation for a scanner can then be found by searching for an orientation
  ## of the matched beacon and neighbours with an equal offset.
  ##
  ## Repeat the matching procedure for each scanner until all scanners have been aligned.
  ##
  ## The total number of beacons is the size of the set of aligned beacons.
  var aligned = report[0].toHashSet()
  var scannerMaps = collect:
    for scanner, beacons in report:
      {scanner: mapNeighbours(beacons)}

  while scannerMaps.len > 0:
    let alignedNeighbours = mapNeighbours(aligned.toSeq)
    let (scanner, fieldNeighbours, scannerNeighbours) = findMatch(
        alignedNeighbours, scannerMaps)
    scannerMaps.del(scanner)
    let align = findAlignment(fieldNeighbours, scannerNeighbours)
    for c in report[scanner].mapIt(align(it)):
      aligned.incl(c)

  aligned.len

func part2(report: Report): int =
  discard

proc main() =
  const input = staticRead("../inputs/d19.txt")
  let report = parseInput(input)
  echo "part 1: ", part1(report)
  echo "part 2: ", part2(report)

when isMainModule:
  when defined(testing):
    import unittest

    test "parseInput":
      let input = """
      --- scanner 0 ---
      404,-588,-901
      528,-643,409
      -838,591,734

      --- scanner 1 ---
      390,-675,-793
      -537,-823,-458
      -485,-357,347
      """.unindent
      check parseInput(input) == @[
        @[[404, -588, -901], [528, -643, 409], [-838, 591, 734]],
        @[[390, -675, -793], [-537, -823, -458], [-485, -357, 347]]
      ]

    const exampleReport = staticRead("../inputs/d19.example.txt").parseInput()
    test "part 1":
      check part1(exampleReport) == 79

    test "part 2":
      check part2(exampleReport) == 3621

  else:
    main()


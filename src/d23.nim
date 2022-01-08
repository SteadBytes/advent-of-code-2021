{.experimental: "caseStmtMacros".}

import strutils, sequtils, sugar, tables, heapqueue

const targetPositions = "AABBCCDD..........."

type
  State = tuple[positions: string, energyCost: int]

const targetRooms = {'A': 0, 'B': 1, 'C': 2, 'D': 3}.toTable()
const energyCosts = {'A': 1, 'B': 10, 'C': 100, 'D': 1000}.toTable()
## Hallway position directly above the room
const roomEntrances = [10, 12, 14, 16]

func roomPositions(room: range[0..3]): seq[int] =
  @[room * 2, room * 2 + 1]

func hallwayClear(positions: string, amphipod, dest: range[7..18]): bool =
  let (i, j) = if amphipod < dest: (amphipod+1, int(dest)) else: (int(dest), amphipod-1)
  return (i..j).allIt(positions[it] == '.')

func moves(positions: string, amphipodPos: range[0..18]): seq[(int, int)] =
  # FIXME: There is definitely a clearer way to implement all of these conditions
  let amphipodType = positions[amphipodPos]
  let targetRoom = targetRooms[amphipodType]
  # If in the hallway, try to enter target room
  let room = roomPositions(targetRoom)
  if amphipodPos > 7:
    # Target room contains an amphipod of another type -> cannot enter
    if room.anyIt(positions[it] notin [amphipodType, '.']):
      return @[]
    # Hallway from amphipod to room is not clear -> cannot enter
    if not hallwayClear(positions, amphipodPos, roomEntrances[targetRoom]):
      return @[]
    # Lowest free space in the target room
    let targetPos = room.filterIt(positions[it] == '.').min
    let energy = (abs(amphipodPos - roomEntrances[targetRoom]) + (
        if targetPos == room[0]: 2 else: 1)) * energyCosts[amphipodType]
    return @[(targetPos, energy)]
  # Amphipod already in the correct room and amphipod below is correct type -> don't move
  if amphipodPos == room[1] and positions[room[0]] == amphipodType:
    return @[]
  # Amphipod is in the correct room but cannot move due to being blocked by another amphipod
  if amphipodPos == room[0] and positions[room[1]] != '.':
    return @[]
  let currentRoom = amphipodPos div 2
  let currentRoomPos = roomPositions(currentRoom)
  # Amphipod is *not* in correct room but cannot move due to being blocked by another amphipod
  if amphipodPos == currentRoomPos[0] and positions[currentRoomPos[1]] != '.':
    return @[]
  # Try all possible hallway positions (not directly above a room)
  assert positions[roomEntrances[currentRoom]] == '.'
  let validMoves = [8, 9, 11, 13, 15, 17, 18].filterIt(hallwayClear(positions,
      roomEntrances[currentRoom], it))
  collect:
    for m in validMoves:
      let energy = (abs(m - roomEntrances[currentRoom]) + (if amphipodPos ==
          currentRoomPos[0]: 2 else: 1)) * energyCosts[amphipodType]
      (m, energy)

func `<`(a, b: State): bool =
  ## Returns the state with the lowest energy cost (for use in a HeapQueue)
  a.energyCost < b.energyCost

proc part1(positions: string): int =
  var
    dist: Table[string, int]
    queue = [(positions: positions, energyCost: 0)].toHeapQueue()

  while queue.len > 0:
    let state = queue.pop()
    if state.positions == targetPositions:
      return state.energyCost
    for i, c in state.positions:
      if c == '.':
        continue
      for (move, energy) in moves(state.positions, i):
        let state2 =
          block:
            var pos = state.positions
            pos[move] = c
            pos[i] = '.'
            (positions: pos, energyCost: state.energyCost + energy)
        if state2.energyCost < dist.getOrDefault(state2.positions, int.high):
          dist[state2.positions] = state2.energyCost
          queue.push(state2)

func parseInput*(s: string): string =
  ## Parse puzzle input into a 1D representation of positions within the burrow:
  ##
  ## .. code-block::
  ##  #############
  ##  #...........#  -> AABBCCDD...........
  ##  ###A#B#C#D###
  ##    #A#B#C#D#
  ##    #########
  ##
  ## The mapping begins with the side room positions - left to right, bottom to top:
  ##
  ## .. code-block:: literal
  ##  #############
  ##  #...........#  -> 01234567...........
  ##  ###1#3#5#7###
  ##    #0#2#4#6#
  ##    #########
  ##
  ## Hallway positions then follow from left to right:
  ##
  ## .. code-block:: literal
  ##
  ##  #############
  ##  #89ABCDEFGHI#  -> 0123456789ABCDEFGHI
  ##  ###1#3#5#7###
  ##    #0#2#4#6#
  ##    #########
  let
    lines = s.splitLines()
    rooms = collect:
      for x in countup(3, 9, 2):
        for y in [3, 2]:
          lines[y][x]
  rooms.join("") & lines[1][1..^2]

proc main() =
  const input = staticRead("../inputs/d23.txt")
  let positions = parseInput(input)
  echo "part 1: ", part1(positions)

when isMainModule:
  when defined(testing):
    import unittest

    const exampleInput = staticRead("../inputs/d23.example.txt")
    test "input parsing":
      check parseInput(exampleInput) == "ABDCCBAD..........."

    test "moves":
      # Solved puzzle -> no moves
      check (0..7).allIt(moves("AABBCCDD...........", it) == [])

      # Trapped beneath another amphipod -> no moves
      check [0, 2, 4, 6].allIt(moves("ABDCCBAD...........", it) == [])

      # Move from upper room position to all possible hallway positions
      check [1, 3, 5, 7].allIt(moves("ABDCCBAD...........", it).mapIt(it[0]) ==
          [8, 9, 11, 13, 15, 17, 18])
      check moves("ABDCCBAD...........", 1) == [(8, 30), (9, 20), (11, 20), (13,
          40), (15, 60), (17, 80), (18, 90)]
      check moves("ABDCCBA.D..........", 1) == [(9, 20), (11, 20), (13, 40), (
          15, 60), (17, 80), (18, 90)]
      check moves("ABDCCB..DA.........", 1) == [(11, 20), (13, 40), (15, 60), (
          17, 80), (18, 90)]


      # In hallway, clear path to target room -> move into room
      check moves("A.DCCBBD.A.........", 9) == [(1, 2)]
      check moves("A.DBC.BD.A.....C...", 15) == [(5, 200)]
      check moves("A.DBC.BD.A.......C.", 17) == [(5, 400)]

      # In hallway, target room blocked -> no moves
      check moves("ABDCCB.D.A.........", 9) == []
      check moves("A.DCCB.D.A.B.......", 11) == []

    test "part 1":
      check part1(parseInput(exampleInput)) == 12521

  else:
    main()


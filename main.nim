import raylib, lenientops, rayutils, tables, sequtils, strutils

type
    Player = object
        pos : Vector2
    Tile = enum
        BASE, AIR

const
    screenWidth = 1280
    screenHeight = 720
    tilesize = 96

InitWindow screenWidth, screenHeight, "Slurf" 

let
    tileTexTable = toTable {BASE : LoadTexture "assets/sprites/BaseTile.png"}

func flipY(i : int | float32) : int =
    int reflect(int i, screenHeight)

# -------------------- #
#    Map Management    #
# -------------------- #

func drawMap(map : seq[seq[Tile]], tileTextable : Table[Tile, Texture], tilesize : int, screenHeight : int) =
    for i in 0..<map.len:
        for j in 0..<map[i].len:
            if map[i, j] == BASE:
                debugEcho makevec2(j * tilesize, reflect(i * tilesize, screenHeight div 2))
                DrawTexture(tileTextable[map[i, j]], j * tilesize, reflect(i * tilesize, screenHeight div 2) - tileTextable[map[i, j]].height, WHITE)

func loadMap(file : string) : seq[seq[Tile]] =
    var res : seq[seq[Tile]]
    for line in file.spsplit('\n'):
        res.add @[]
        for c in line:
            if c == '#':
                res[^1].add BASE
            else: res[^1].add AIR
        while res[^1].len < res[0].len:
            res[^1].add AIR
    for i in 1..res.len:
        result.add @[]
        result[i - 1] = res[^i]

# ----------------------- #
#    Player Management    #
# ----------------------- #

func isOnFloor(plr : var Player, map : seq[seq[Tile]], rayLen : int, tilesize : int, screenHeight : int) : bool =
    let rc = makevec2(plr.pos.x, plr.pos.y + 15)
    let rcrnd = round(rc / tilesize)
    if map[flipy rcrnd.y, rcrnd.x] != AIR:
            plr.pos = round(rc / tilesize) * tilesize
            return true

func movePlayer(plr : var Player, map : seq[seq[Tile]], tilesize : int, sH : int) : Vector2 =
    if plr.isOnFloor(map, 10, tilesize, sH) and IsKeyPressed(KEY_Z):
        result.y += -250
    else: result.y += 10
    result.x += 15

var
    plr = Player(pos : makevec2(0, flipY(0) - tilesize))

while not WindowShouldClose():
    ClearBackground makecolor "242424"

    var velo = movePlayer(plr, map, tilesize, screenHeight)

    for line in loadMap readFile("lvl1.txt"):
        echo line

    BeginDrawing()
    drawMap(loadMap readFile "lvl1.txt", tileTexTable, tilesize, screenHeight)
    EndDrawing()
CloseWindow()

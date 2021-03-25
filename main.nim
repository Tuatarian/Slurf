import raylib, lenientops, rayutils, tables, math, sequtils

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
    plrTex  = LoadTexture "assets/sprites/Plr/plrRun0.png"

func flipY(i : int | float32 | float) : int = int(720 - i)

# -------------------- #
#    Map Management    #
# -------------------- #

func drawMap(map : seq[seq[Tile]], tileTextable : Table[Tile, Texture], tilesize : int, screenHeight : int) =
    for i in 0..<map.len:
        for j in 0..<map[i].len:
            if map[i, j] == BASE:
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

func isOnFloor(plr : var Player, plrTex : Texture, map : seq[seq[Tile]], rayLen : int, tilesize : int, screenHeight : int) : bool =
    let rc = makevec2(plr.pos.x + (plrTex.width div 2), plr.pos.y + plrTex.height + rayLen)
    let rcCell = rc div tilesize
    if map[max(0, flipY(rc.y) div tilesize), rcCell.x] != AIR:
        plr.pos.y = float flipY((max(0, flipY(rc.y) div tilesize) + 1) * tilesize)
        DrawCircleV(plr.pos, 5, GREEN)
        plr.pos.y += -plrTex.height.float
        DrawCircleV(plr.pos, 5, SKYBLUE)
        return true
    

func movePlayer(plr : var Player, plrTex : Texture, map : seq[seq[Tile]], tilesize : int, fJumped : var int, sH : int) : Vector2 =
    if plr.isOnFloor(plrTex, map, 1, tilesize, sH):
        if IsKeyPressed(KEY_Z):
            result.y = -75
            fJumped += 1
        else: fJumped = 0
    else:
        fJumped += 1
        result.y += -75 / (fJumped * 1.25)
        result.y += 0.25
    result = result.round(5)
    result.y = max(result.y, -20)


var
    plr = Player(pos : makevec2(screenWidth div 2, flipY(0) - tilesize - plrTex.height))
    map = loadMap(readFile "lvl1.txt")
    velo : Vector2
    acc : Vector2
    fJumped : int

while not WindowShouldClose():
    ClearBackground BGREY

    velo += movePlayer(plr, plrTex, map, tilesize, fJumped, screenHeight)
    plr.pos += velo
    velo = makevec2(0, 0)

    BeginDrawing()
    drawMap map, tileTexTable, tilesize, screenHeight
    DrawTextureV plrTex, plr.pos, WHITE 
    EndDrawing()
CloseWindow()

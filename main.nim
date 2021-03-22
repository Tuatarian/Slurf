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

# ----------------------- #
#    Player Management    #
# ----------------------- #

func drawMap(map : seq[seq[Tile]], tileTextable : Table[Tile, Texture], tilesize : int, screenHeight : int) =
    for i in 0..<map.len:
        for j in 0..<map[i].len:
            if map[i, j] == BASE:
                debugEcho makevec2(j * tilesize, reflect(i * tilesize, screenHeight div 2))
                DrawTexture(tileTextable[map[i, j]], j * tilesize, reflect(i * tilesize, screenHeight div 2) - tileTextable[map[i, j]].height, WHITE)

func loadMap(file : string) : seq[seq[Tile]] =
    var res : seq[seq[Tile]]
    for line in file.split('\n'):
        res.add @[]
        for c in line:
            if c == '#':
                res[^1].add BASE
            else: res[^1].add AIR
    for i in 1..res.len:
        result.add @[]
        result[i - 1] = res[^i]
        
while not WindowShouldClose():
    ClearBackground makecolor "242424"
    echo loadMap(readFile("lvl1.txt")).len, " x ", loadMap(readFile("lvl1.txt"))            

    BeginDrawing()
    drawMap(loadMap readFile "lvl1.txt", tileTexTable, tilesize, screenHeight)
    EndDrawing()
CloseWindow()

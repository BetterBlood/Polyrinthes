extends Node
class_name BaseGraph

var neighbors = []
var neighborsConnected = []
var colorsIds = []
var depths = []
var lastVisited = 0
var deepest = 0
var visited:Array[bool] = []
var processing:Array[bool] = []

var colorByDepth = true

var size: int
var nbrNeighbors: int
var wallValue: int
var outsideWallValue: int

func _init(mazeSize: int = 3, wallV: int = -1, outWallV: int = -2, nbrN: int = 6, byDepthColor: bool = true):
	size = mazeSize
	nbrNeighbors = nbrN
	wallValue = wallV
	outsideWallValue = outWallV
	colorByDepth = byDepthColor

func getNbrRoom() -> int:
	return pow(size, 3)

func getNbrRoomOnASide() -> int:
	return pow(size, 2)

extends Node3D
const CubeCustom := preload("res://scripts/CubeCustom.gd")
const CubeGraph := preload("res://scripts/cubeGraph.gd")
var wall = preload("res://scenes/wall.tscn")
var cubeGraph

# Called when the node enters the scene tree for the first time.
func _ready(): # (backward, forward, left, right, down, up)
	var size = 10
	var gapBetweenCubeCenter = 10.5
	cubeGraph = CubeGraph.new(size)
	
	var xCoordBase = -(gapBetweenCubeCenter * (size / 2))
	var yCoordBase = 0
	var zCoordBase = 0
	
	var xCoord = xCoordBase
	var yCoord = yCoordBase
	var zCoord = zCoordBase
	print("cubeGraph.getNbrRoom(): ", cubeGraph.getNbrRoom())
	
	for i in range(cubeGraph.getNbrRoom()):
		#print(xCoord, " ", yCoord, " ", zCoord)
		#print(cubeGraph.getNeighbors(i))
		add_child(CubeCustom.new(Vector3(xCoord,yCoord,zCoord), cubeGraph.getNeighbors(i)))
		xCoord += gapBetweenCubeCenter
		
		if i%(size) == size - 1:
			xCoord = xCoordBase
			yCoord += gapBetweenCubeCenter
		
		if i%(size*size) == (size*size) - 1:
			yCoord = yCoordBase
			zCoord -= gapBetweenCubeCenter
	
	xCoordBase = -(gapBetweenCubeCenter * (size / 2)) + gapBetweenCubeCenter * (size + 1)
	yCoordBase = 0
	zCoordBase = 0
	xCoord = xCoordBase
	yCoord = yCoordBase
	zCoord = zCoordBase
	
	for i in range(cubeGraph.getNbrRoom()):
		#print(xCoord, " ", yCoord, " ", zCoord)
		#print(cubeGraph.getNeighbors(i))
		add_child(CubeCustom.new(Vector3(xCoord,yCoord,zCoord), cubeGraph.getNeigborsConnection(i)))
		xCoord += gapBetweenCubeCenter
		
		if i%(size) == size - 1:
			xCoord = xCoordBase
			yCoord += gapBetweenCubeCenter
		
		if i%(size*size) == (size*size) - 1:
			yCoord = yCoordBase
			zCoord -= gapBetweenCubeCenter


func _process(_delta):
	pass

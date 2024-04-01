extends Node3D
const CubeCustom := preload("res://scripts/CubeCustom.gd")
const CubeGraph := preload("res://scripts/cubeGraph.gd")
var wall = preload("res://scenes/wall.tscn")
var cubeGraph

# Called when the node enters the scene tree for the first time.
func _ready(): # (backward, forward, left, right, down, up)
	var size = 3
	var gapBetweenCubeCenter = 10.5
	# -1 = wall
	# -2 = ~ invisible walls
	var wallV = -1
	var outWallV = -1
	cubeGraph = CubeGraph.new(size, wallV, outWallV)
	
	var xCoordBase = -(gapBetweenCubeCenter * (size / 2))
	var yCoordBase = 0
	var zCoordBase = 0
	
	var xCoord = xCoordBase
	var yCoord = yCoordBase
	var zCoord = zCoordBase
	print("cubeGraph.getNbrRoom(): ", cubeGraph.getNbrRoom())
	
	if cubeGraph.size == 3 :
		# floor 1
		cubeGraph.connectNeigbors(18, 19)
		cubeGraph.connectNeigbors(19, 20)
		cubeGraph.connectNeigbors(19, 10)
		cubeGraph.connectNeigbors(20, 11)
		cubeGraph.connectNeigbors(11, 2)
		cubeGraph.connectNeigbors(2, 1)
		cubeGraph.connectNeigbors(1, 0)
		cubeGraph.connectNeigbors(0, 9)
		
		# floor connection from 1 to 2
		cubeGraph.connectNeigbors(9, 12)
		
		# floor 2
		cubeGraph.connectNeigbors(12, 13)
		cubeGraph.connectNeigbors(13, 14)
		cubeGraph.connectNeigbors(14, 23)
		cubeGraph.connectNeigbors(13, 22)
		cubeGraph.connectNeigbors(22, 21)
		cubeGraph.connectNeigbors(14, 5)
		cubeGraph.connectNeigbors(5, 4)
		cubeGraph.connectNeigbors(4, 3)
		
		# floor connection from 2 to 3
		cubeGraph.connectNeigbors(3, 6)
		
		# floor 3
		cubeGraph.connectNeigbors(6, 15)
		cubeGraph.connectNeigbors(15, 24)
		cubeGraph.connectNeigbors(24, 25)
		cubeGraph.connectNeigbors(25, 26)
		cubeGraph.connectNeigbors(26, 17)
		cubeGraph.connectNeigbors(17, 8)
		cubeGraph.connectNeigbors(8, 7)
		cubeGraph.connectNeigbors(7, 16)
	
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

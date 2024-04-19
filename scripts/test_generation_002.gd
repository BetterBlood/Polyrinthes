extends Node3D
const CubeCustom := preload("res://scripts/CubeCustom.gd")
const CubeGraph := preload("res://scripts/cubeGraph.gd")
var wall = preload("res://scenes/wall.tscn")
var cubeGraph

var size = 3
var gapBetweenCubeCenter = 10.5
var wallV = -1 # -1 = wall
var outWallV = -2 # -2 = ~ invisible walls

var thread: Thread
signal end_generate()

# Called when the node enters the scene tree for the first time.
func _ready(): # (backward, forward, left, right, down, up)
	#generate(size)
	pass

func _process(_delta):
	pass

func generate(sizeP:int):
	cubeGraph = CubeGraph.new(sizeP, wallV, outWallV)
	
	print("cubeGraph.getNbrRoom(): ", cubeGraph.getNbrRoom())
	
#	if (cubeGraph.size == 3): exampleDebugforsize3()
	
	# only for normal generation : odd size, middle: cubeGraph.getNbrRoom()/2 
	createPath_deepWay(0)
	
	var xCoordBase = -(gapBetweenCubeCenter * (sizeP / 2))
	var yCoordBase = 0
	var zCoordBase = 0
	
	var xCoord = xCoordBase
	var yCoord = yCoordBase
	var zCoord = zCoordBase
	
	print("\nfirst generation")
	var time_start = Time.get_ticks_msec()
	for i in range(cubeGraph.getNbrRoom()):
		#if i%cubeGraph.size == cubeGraph.size - 1: print((100*i)/cubeGraph.getNbrRoom(), "%")
		#print(xCoord, " ", yCoord, " ", zCoord)
		#print(cubeGraph.getNeighbors(i))
		
		add_child(CubeCustom.new(
			Vector3(xCoord,yCoord,zCoord), 
			cubeGraph.getNeighbors(i),
			cubeGraph.getColor(i), 
			cubeGraph.lastVisited))
		
		xCoord += gapBetweenCubeCenter
		
		if i%(sizeP) == sizeP - 1:
			xCoord = xCoordBase
			yCoord += gapBetweenCubeCenter
		
		if i%(sizeP*sizeP) == (sizeP*sizeP) - 1:
			yCoord = yCoordBase
			zCoord -= gapBetweenCubeCenter
	
	xCoordBase = -(gapBetweenCubeCenter * (sizeP / 2)) + gapBetweenCubeCenter * (sizeP + 1)
	yCoordBase = 0
	zCoordBase = 0
	xCoord = xCoordBase
	yCoord = yCoordBase
	zCoord = zCoordBase
	var time_end = Time.get_ticks_msec()
	print("100% in " + str((time_end - time_start)/1000) + "s "+ str((time_end - time_start)%1000) + "ms.\n\nsecond generation")
	time_start = Time.get_ticks_msec()
	for i in range(cubeGraph.getNbrRoom()):
		#if i%cubeGraph.size == cubeGraph.size - 1: print((100*i)/cubeGraph.getNbrRoom(), "%")
		#print(xCoord, " ", yCoord, " ", zCoord)
		#print(cubeGraph.getNeighbors(i))
		add_child(
			CubeCustom.new(
				Vector3(xCoord,yCoord,zCoord), 
				cubeGraph.getNeighborsConnection(i), 
				cubeGraph.getColor(i), 
				cubeGraph.lastVisited
			)
		)
		xCoord += gapBetweenCubeCenter
		
		if i%(sizeP) == sizeP - 1:
			xCoord = xCoordBase
			yCoord += gapBetweenCubeCenter
		
		if i%(sizeP*sizeP) == (sizeP*sizeP) - 1:
			yCoord = yCoordBase
			zCoord -= gapBetweenCubeCenter
		
		# TODO : WIP, find a way to continue moving while rendering graph
		# this following line slow down the render but regenerate (while generating)
		# could send errors (try to delete not existing node)
		# await get_tree().create_timer(0.001).timeout 
		
	time_end = Time.get_ticks_msec()
	print("100% in " + str((time_end - time_start)/1000) + "s "+ str((time_end - time_start)%1000) + "ms.")

func _on_menu_generation(edgeSize) -> void:
	for i in self.get_children():
		if (i is CubeCustom):
			i.clean()
			self.remove_child(i)
			i.queue_free()
	
	if cubeGraph != null:
		cubeGraph.clean()
	
	generate(edgeSize)

func exampleDebugforsize3():
	if cubeGraph.size == 3 :
		# floor 1
		cubeGraph.connectNeighbors(18, 19)
		cubeGraph.connectNeighbors(19, 10)
		cubeGraph.connectNeighbors(19, 20)
		cubeGraph.connectNeighbors(20, 11)
		cubeGraph.connectNeighbors(11, 2)
		cubeGraph.connectNeighbors(2, 1)
		cubeGraph.connectNeighbors(1, 0)
		cubeGraph.connectNeighbors(0, 9)

		# floor connection from 1 to 2
		cubeGraph.connectNeighbors(9, 12)

		# floor 2
		cubeGraph.connectNeighbors(12, 13)
		cubeGraph.connectNeighbors(13, 22)
		cubeGraph.connectNeighbors(22, 21)
		cubeGraph.connectNeighbors(13, 14)
		cubeGraph.connectNeighbors(14, 23)
		cubeGraph.connectNeighbors(14, 5)
		cubeGraph.connectNeighbors(5, 4)
		cubeGraph.connectNeighbors(4, 3)

		# floor connection from 2 to 3
		cubeGraph.connectNeighbors(3, 6)

		# floor 3
		cubeGraph.connectNeighboreighbors(6, 15)
		cubeGraph.connectNeighbors(15, 24)
		cubeGraph.connectNeighbors(24, 25)
		cubeGraph.connectNeighbors(25, 26)
		cubeGraph.connectNeighbors(26, 17)
		cubeGraph.connectNeighbors(17, 8)
		cubeGraph.connectNeighbors(8, 7)
		cubeGraph.connectNeighbors(7, 16)

func createPath_deepWay(beginId: int = 0):
	var neighborsToExplo = []
	var stack = []
	stack.append(beginId)
	cubeGraph.setVisited(beginId) # not really interesting to comment this line
	
	var currId = beginId
	
	while not stack.is_empty():
		neighborsToExplo.clear()
		neighborsToExplo.append_array(cubeGraph.getNotVisitedNeighbors(currId))
		#print(neighborsToExplo)
		
		if len(neighborsToExplo) == 0 :
			currId = stack.pop_back()
			continue
		
		stack.append(currId)
		neighborsToExplo.shuffle()
		
		var newId = neighborsToExplo.pop_front()
		cubeGraph.connectNeighbors(currId, newId)
		cubeGraph.setVisited(newId)
		currId = newId

# Inconclusive
func createPath_deepWay_alt_1(beginId: int = 0):
	var neighborsToExplo = []
	var stack = []
	stack.append(beginId)
	cubeGraph.setVisited(beginId)
	
	var currId = beginId
	var i = 0
	var newId
	
	while not stack.is_empty():
		neighborsToExplo.clear()
		neighborsToExplo.append_array(cubeGraph.getNotVisitedNeighbors(currId))
		#print(neighborsToExplo)
		
		if len(neighborsToExplo) == 0 :
			currId = stack.pop_back()
			continue
		
		stack.append(currId)
		neighborsToExplo.shuffle()
		
		newId = neighborsToExplo.pop_front()
		cubeGraph.connectNeighbors(currId, newId)
		cubeGraph.setVisited(newId)
		var prevId = currId
		currId = newId
		i += 1
		
		if i >= cubeGraph.getNbrRoomOnASide() && not neighborsToExplo.is_empty():
			#print("alt Way ?")
			stack.append(currId)
			neighborsToExplo.shuffle()
			
			newId = neighborsToExplo.pop_front()
			cubeGraph.connectNeighbors(prevId, newId)
			cubeGraph.setVisited(newId)
			currId = newId
			i = 0

func createPath_deepWay_layer_by_layer(beginId: int = 0):
	var neighborsToExplo = []
	var stack = []
	
	stack.append(beginId)
	cubeGraph.setVisited(beginId)

	var currId = beginId
	var lastUpdated = currId

	while not stack.is_empty():
		neighborsToExplo.clear()
		# with "true" get only neighbors on the same layer
		neighborsToExplo.append_array(cubeGraph.getNotVisitedNeighbors(currId, true))
		#print(neighborsToExplo)
		
		if len(neighborsToExplo) == 0:
			currId = stack.pop_back()
			# when all nodes are allready visited (stack empty) and we are 
			# back to the begining, connect the last updated node (means the 
			# last dead end) with the upper layer if exist
			if stack.is_empty() && cubeGraph.hasUpNeighbors(lastUpdated):
				stack.append(cubeGraph.getUpNeighbors(lastUpdated))
				cubeGraph.connectNeighbors(lastUpdated, stack.back())
				cubeGraph.setVisited(stack.back())
				currId = stack.back()
			continue
		
		stack.append(currId)
		neighborsToExplo.shuffle()
		
		var newId = neighborsToExplo.pop_front()
		cubeGraph.connectNeighbors(currId, newId)
		cubeGraph.setVisited(newId)
		currId = newId
		lastUpdated = currId

func createPath_deepWay_layer_by_layer_alt_1(beginId: int = 0):
	var neighborsToExplo = []
	var stack = []
	
	stack.append(beginId)
	#cubeGraph.setVisited(beginId) # uncomment this to have a linear begin

	var currId = beginId
	var lastUpdated = currId

	while not stack.is_empty():
		neighborsToExplo.clear()
		# with "true" get only neighbors on the same layer
		neighborsToExplo.append_array(cubeGraph.getNotVisitedNeighbors(currId, true))
		#print(neighborsToExplo)
		
		if len(neighborsToExplo) == 0:
			currId = stack.pop_back()
			# when all nodes are allready visited (stack empty) and we are 
			# back to the begining, connect the last updated node (means the 
			# last dead end) with the upper layer if exist
			if stack.is_empty() && cubeGraph.hasUpNeighbors(lastUpdated):
				stack.append(cubeGraph.getUpNeighbors(lastUpdated))
				cubeGraph.connectNeighbors(lastUpdated, stack.back())
				cubeGraph.setVisited(stack.back())
				currId = stack.back()
			continue
		
		stack.append(currId)
		neighborsToExplo.shuffle()
		
		var newId = neighborsToExplo.pop_front()
		cubeGraph.connectNeighbors(currId, newId)
		cubeGraph.setVisited(newId)
		currId = newId
		lastUpdated = currId

func createPath_wideWay(beginId: int = 0):
	pass

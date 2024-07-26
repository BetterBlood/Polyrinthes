extends Node3D
const CubeCustom := preload("res://scripts/CubeCustom.gd")
const TruncatedOctahedronCustom := preload("res://scripts/TruncatedOctahedronCustom.gd")
const CubeGraph := preload("res://scripts/cubeGraph.gd")
var wall = preload("res://scenes/wall.tscn")
var cubeGraph

const TruncatedOctahedron := preload("res://scenes/octaedre_tronque.tscn")

var mazeAll:Dictionary= {}
var maze:Dictionary= {}

var size = 3 # default size
var gapBetweenCubeCenter = 21 # 10.5 : normal spacing for cube rooms
var wallV = -1 # -1 = wall
var outWallV = -2 # -2 = ~ invisible walls (for debug)

var thread: Thread
signal end_generate()

var debug: bool = true
var newConnectionDebug: bool = true


# Called when the node enters the scene tree for the first time.
func _ready(): # (backward, forward, left, right, down, up)
	#generate(size)
	
	var truncOcta = TruncatedOctahedron.instantiate()
	truncOcta.position = Vector3(0, 0, 50)
	add_child(truncOcta)
	
	pass

func _process(_delta):
	pass

func generate(sizeP:int):
	var colorBasedOnDepth = true
	cubeGraph = CubeGraph.new(sizeP, wallV, outWallV, 6, colorBasedOnDepth)
	var sizeBase = cubeGraph.size
	var sizeFace = cubeGraph.getNbrRoomOnASide()
	var sizeTotal = cubeGraph.getNbrRoom()
	
	var showWall:bool = true # will show walls marked as -1 (wallV or outWallV)
	var triColor:bool = true
	
#	if (sizeBase == 3): exampleDebugforsize3()
	
	var beginId = 0
	# only for normal generation : odd size, middle: cubeGraph.getNbrRoom()/2 
	#createPath_deepWay(beginId) # colorBasedOnDepth should be false or TODO
	#createPath_deepWay_layer_by_layer(beginId) # colorBasedOnDepth should be false or TODO
	#createPath_deepWay_layer_by_layer_alt_1(beginId) # colorBasedOnDepth should be false or TODO
	#createPath_deepWay_layer_by_layer_alt_2(beginId)
	#createPath_deepWay_layer_by_layer_alt_3(beginId)
	#createPath_deepWay_layer_by_layer_alt_4(beginId)
	createPath_deepWay_layer_by_layer_alt_5(beginId)
	
	var depthReached = cubeGraph.lastVisited
	
	if colorBasedOnDepth:
		cubeGraph.setColorFromDepth()
	
	var xCoordBase = -(gapBetweenCubeCenter * (sizeBase / 2))
	var yCoordBase = 0
	var zCoordBase = 0
	
	var xCoord = xCoordBase
	var yCoord = yCoordBase
	var zCoord = zCoordBase
	
	print("\nfirst generation")
	var time_start = Time.get_ticks_msec()
	for i in range(sizeTotal):
		#if i%cubeGraph.size == cubeGraph.size - 1: print((100*i)/cubeGraph.getNbrRoom(), "%")
		#print(xCoord, " ", yCoord, " ", zCoord)
		#print(cubeGraph.getNeighbors(i))
		var cube = CubeCustom.new(
				Vector3(xCoord,yCoord,zCoord), 
				cubeGraph.getNeighbors(i),
				cubeGraph.getColor(i), 
				depthReached,
				debug,
				showWall,
				triColor
			)
		
		add_child(cube)
		mazeAll[i] = cube
		
		xCoord += gapBetweenCubeCenter
		
		if i%(sizeBase) == sizeBase - 1:
			xCoord = xCoordBase
			yCoord += gapBetweenCubeCenter
		
		if i%(sizeFace) == (sizeFace) - 1:
			yCoord = yCoordBase
			zCoord -= gapBetweenCubeCenter
	
	var time_end = Time.get_ticks_msec()
	print("100% in " + str((time_end - time_start)/1000) + "s "+ str((time_end - time_start)%1000) + "ms.\n\nsecond generation")
	
	deepensPath_wideWay(mazeAll, beginId) # recompute connections from id given
	
	depthReached = cubeGraph.lastVisited
	
	instantiatePyramidConnection_allNeighbors(mazeAll, depthReached)
	
	# reset to new location :
	xCoordBase = -(gapBetweenCubeCenter * (sizeBase / 2)) + gapBetweenCubeCenter * (sizeBase + 1)
	yCoordBase = 0
	zCoordBase = 0
	xCoord = xCoordBase
	yCoord = yCoordBase
	zCoord = zCoordBase
	
	time_start = Time.get_ticks_msec()
	for i in range(sizeTotal):
		#if i%sizeBase == sizeBase - 1: print((100*i)/sizeTotal, "%")
		#print(xCoord, " ", yCoord, " ", zCoord)
		#print(cubeGraph.getNeighbors(i))
		
		#var cube = CubeCustom.new(
		var cube = TruncatedOctahedronCustom.new(
					Vector3(xCoord,yCoord,zCoord), 
					cubeGraph.getNeighborsConnection(i), 
					cubeGraph.getColor(i), 
					depthReached,
					debug,
					showWall,
					triColor
				)
		
		add_child(cube)
		maze[i] = cube
		
		xCoord += gapBetweenCubeCenter
		
		if i%(sizeBase) == sizeBase - 1:
			xCoord = xCoordBase
			yCoord += gapBetweenCubeCenter
		
		if i%(sizeFace) == (sizeFace) - 1:
			yCoord = yCoordBase
			zCoord -= gapBetweenCubeCenter
		
		# TODO : WIP, find a way to continue moving while rendering graph
		# this following line slow down the render but regenerate (while generating)
		# could send errors (try to delete not existing node)
		# await get_tree().create_timer(0.001).timeout 
		
	time_end = Time.get_ticks_msec()
#	print(cubeGraph.colorsIds)
#	print(cubeGraph.depths)
	print("100% in " + str((time_end - time_start)/1000) + "s "+ str((time_end - time_start)%1000) + "ms.")
	
	deepensPath_wideWay(maze, beginId) # recompute connections from id given
	
	depthReached = cubeGraph.lastVisited
	
	instantiatePyramidConnection(maze, depthReached)
	
	print("cubeGraph.getNbrRoom(): ", sizeTotal, ", depth: ", depthReached)
	

func _on_menu_generation(edgeSize) -> void:
	maze.clear()
	mazeAll.clear()
	
	for i in self.get_children():
		if i is CubeCustom:
			i.clean()
			self.remove_child(i)
			i.queue_free()
		elif i is MeshInstance3D:
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
	cubeGraph.setVisited(beginId) # not really interesting to remove this line
	cubeGraph.setDepth(beginId, 0)
	
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

# TODO : a deepgeneration with sometimes a switch on wide generation


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

# connection between layer is always on the deppest room from layer beginning
func createPath_deepWay_layer_by_layer_alt_2(beginId: int = 0):
	var neighborsToExplo = []
	var stack = []
	var currId = beginId
	var lastUpdated = currId
	var depth:int = 0
	var deepestId = 0
	var currMaxDepth = 0
	var deadendReached = false
	
	stack.append(currId)
	cubeGraph.setProcessing(currId)
	#print("d-setDepth(", currId, ",", depth, ")")
	cubeGraph.setDepth(currId, depth)
	
	while not stack.is_empty():
		neighborsToExplo.clear()
		# with "true" get only neighbors on the same layer
		neighborsToExplo.append_array(cubeGraph.getNotProcNotVisiNeighbors(currId, true))
		
		if len(neighborsToExplo) == 0:
			deadendReached = true
			if currMaxDepth < depth :
				currMaxDepth = depth
				deepestId = currId
				#print("dead end: ", deepestId, " ", currMaxDepth)
				if cubeGraph.getDepth(currId) == -1:
					#print("e-setDepth(", currId, ",", depth, ")")
					cubeGraph.setDepth(currId, depth)
			
			currId = stack.pop_back()
			cubeGraph.setVisited(currId)
			#cubeGraph.setDepth(currId, depth)
			depth -= 1
			
			# when all nodes are allready visited (stack empty) and we are 
			# back to the begining, connect the last updated node (means the 
			# last dead end) with the upper layer if exist
			if stack.is_empty() && cubeGraph.hasUpNeighbors(deepestId):
				stack.append(cubeGraph.getUpNeighbors(deepestId))
				cubeGraph.connectNeighbors(deepestId, stack.back())
				cubeGraph.setVisited(stack.back())
				currId = stack.back()
				
				depth = cubeGraph.getDepth(deepestId)
				depth += 1
				#print("c-setDepth(", currId, ",", depth, ")")
				cubeGraph.setDepth(currId, depth)
				deepestId = currId
				currMaxDepth = depth
			continue
		elif deadendReached:
			depth += 1
			deadendReached = false
		
		neighborsToExplo.shuffle()
		
		var newId = neighborsToExplo.pop_front()
		cubeGraph.connectNeighbors(currId, newId)
		cubeGraph.setProcessing(newId)
		currId = newId
		lastUpdated = newId
		depth += 1
		if cubeGraph.getDepth(currId) == -1:
			#print("n-setDepth(", currId, ",", depth, ")")
			cubeGraph.setDepth(currId, depth)
		stack.append(currId)

# 2 transitions between layers
func createPath_deepWay_layer_by_layer_alt_3(beginId: int = 0):
	var neighborsToExplo = []
	var stack = []
	var currId = beginId
	var lastUpdated = currId
	var depth:int = 0
	var deepestId = 0
	var currMaxDepth = 0
	var deadendReached = false
	
	var prevMaxDepth = 0
	var secondLayerTransitionId = -1
	
	stack.append(currId)
	cubeGraph.setProcessing(currId)
	#print("d-setDepth(", currId, ",", depth, ")")
	cubeGraph.setDepth(currId, depth)
	
	while not stack.is_empty():
		neighborsToExplo.clear()
		# with "true" get only neighbors on the same layer
		neighborsToExplo.append_array(cubeGraph.getNotProcNotVisiNeighbors(currId, true))
		
		if len(neighborsToExplo) == 0:
			
			deadendReached = true
			if currMaxDepth < depth :
				prevMaxDepth = currMaxDepth
				secondLayerTransitionId = deepestId
				
				currMaxDepth = depth
				deepestId = currId
				#print("dead end: ", deepestId, " ", currMaxDepth)
				if cubeGraph.getDepth(currId) == -1:
					#print("e-setDepth(", currId, ",", depth, ")")
					cubeGraph.setDepth(currId, depth)
			
			currId = stack.pop_back()
			cubeGraph.setVisited(currId)
			#cubeGraph.setDepth(currId, depth)
			depth -= 1
			
			# when all nodes are allready visited (stack empty) and we are 
			# back to the begining, connect the last updated node (means the 
			# last dead end) with the upper layer if exist
			if stack.is_empty() && cubeGraph.hasUpNeighbors(deepestId):
				stack.append(cubeGraph.getUpNeighbors(deepestId))
				cubeGraph.connectNeighbors(deepestId, stack.back())
				cubeGraph.setVisited(stack.back())
				currId = stack.back()
				
				depth = cubeGraph.getDepth(deepestId)
				depth += 1
				#print("c-setDepth(", currId, ",", depth, ")")
				cubeGraph.setDepth(currId, depth)
				deepestId = currId
				currMaxDepth = depth
				
				if secondLayerTransitionId != -1 && secondLayerTransitionId != 0 && cubeGraph.hasUpNeighbors(secondLayerTransitionId):
					cubeGraph.connectNeighbors(secondLayerTransitionId, 
						cubeGraph.getUpNeighbors(secondLayerTransitionId))
					secondLayerTransitionId = -1
			continue
		elif deadendReached:
			depth += 1
			deadendReached = false
		
		neighborsToExplo.shuffle()
		
		var newId = neighborsToExplo.pop_front()
		cubeGraph.connectNeighbors(currId, newId)
		cubeGraph.setProcessing(newId)
		currId = newId
		lastUpdated = newId
		depth += 1
		if cubeGraph.getDepth(currId) == -1:
			#print("n-setDepth(", currId, ",", depth, ")")
			cubeGraph.setDepth(currId, depth)
		stack.append(currId)

# cubeGraph.size*(1/3) transitions between layers
func createPath_deepWay_layer_by_layer_alt_4(beginId: int = 0):
	var neighborsToExplo = []
	var stack = []
	var currId = beginId
	var lastUpdated = currId
	var depth:int = 0
	var deepestId = 0
	var currMaxDepth = 0
	var deadendReached = false
	
	var prevMaxDepth = []
	var secondLayerTransitionId = []
	var indexForTansition = 0
	var additionnalConnections = int(cubeGraph.size * (1/3.) - 1)
	
	for i in range(additionnalConnections):
		prevMaxDepth.append(0)
		secondLayerTransitionId.append(-1)
	
	stack.append(currId)
	cubeGraph.setProcessing(currId)
	#print("d-setDepth(", currId, ",", depth, ")")
	cubeGraph.setDepth(currId, depth)
	
	while not stack.is_empty():
		
		neighborsToExplo.clear()
		# with "true" get only neighbors on the same layer
		neighborsToExplo.append_array(cubeGraph.getNotProcNotVisiNeighbors(currId, true))
		
		if len(neighborsToExplo) == 0:
			
			deadendReached = true
			if currMaxDepth < depth :
				prevMaxDepth = currMaxDepth
				if len(secondLayerTransitionId) > 0 :
					secondLayerTransitionId[indexForTansition] = deepestId
					indexForTansition = (indexForTansition + 1)%additionnalConnections
				
				currMaxDepth = depth
				deepestId = currId
				#print("dead end: ", deepestId, " ", currMaxDepth)
				if cubeGraph.getDepth(currId) == -1:
					#print("e-setDepth(", currId, ",", depth, ")")
					cubeGraph.setDepth(currId, depth)
			
			currId = stack.pop_back()
			cubeGraph.setVisited(currId)
			#cubeGraph.setDepth(currId, depth)
			depth -= 1
			
			# when all nodes are allready visited (stack empty) and we are 
			# back to the begining, connect the last updated node (means the 
			# last dead end) with the upper layer if exist
			if stack.is_empty() && cubeGraph.hasUpNeighbors(deepestId):
				stack.append(cubeGraph.getUpNeighbors(deepestId))
				cubeGraph.connectNeighbors(deepestId, stack.back())
				cubeGraph.setVisited(stack.back())
				currId = stack.back()
				
				depth = cubeGraph.getDepth(deepestId)
				depth += 1
				#print("c-setDepth(", currId, ",", depth, ")")
				cubeGraph.setDepth(currId, depth)
				deepestId = currId
				currMaxDepth = depth
				
				for i in range(additionnalConnections):
					if secondLayerTransitionId[i] != -1 && secondLayerTransitionId[i] != 0 && cubeGraph.hasUpNeighbors(secondLayerTransitionId[i]):
						cubeGraph.connectNeighbors(secondLayerTransitionId[i], 
							cubeGraph.getUpNeighbors(secondLayerTransitionId[i]))
					secondLayerTransitionId[i] = -1
			continue
		elif deadendReached:
			depth += 1
			deadendReached = false
		
		neighborsToExplo.shuffle()
		
		var newId = neighborsToExplo.pop_front()
		cubeGraph.connectNeighbors(currId, newId)
		cubeGraph.setProcessing(newId)
		currId = newId
		lastUpdated = newId
		depth += 1
		if cubeGraph.getDepth(currId) == -1:
			#print("n-setDepth(", currId, ",", depth, ")")
			cubeGraph.setDepth(currId, depth)
		stack.append(currId)

# random number of transition transitions between layers max : cubeGraph.size*(1/3)
func createPath_deepWay_layer_by_layer_alt_5(beginId: int = 0):
	var neighborsToExplo = []
	var stack = []
	var currId = beginId
	var lastUpdated = currId
	var depth:int = 0
	var deepestId = 0
	var currMaxDepth = 0
	var deadendReached = false
	
	var prevMaxDepth = []
	var secondLayerTransitionId = []
	var indexForTansition = 0
	var maxAdditionnalConnections = int(cubeGraph.size * (1/3.) - 1)
	var currentAdditionnalConnection = randi_range(0, maxAdditionnalConnections)
	
	for i in range(maxAdditionnalConnections):
		prevMaxDepth.append(0)
		secondLayerTransitionId.append(-1)
	
	stack.append(currId)
	cubeGraph.setProcessing(currId)
	#print("d-setDepth(", currId, ",", depth, ")")
	cubeGraph.setDepth(currId, depth)
	
	while not stack.is_empty():
		
		neighborsToExplo.clear()
		# with "true" get only neighbors on the same layer
		neighborsToExplo.append_array(cubeGraph.getNotProcNotVisiNeighbors(currId, true))
		
		if len(neighborsToExplo) == 0:
			
			deadendReached = true
			if currMaxDepth < depth :
				prevMaxDepth = currMaxDepth
				if currentAdditionnalConnection > 0 :
					secondLayerTransitionId[indexForTansition] = deepestId
					indexForTansition = (indexForTansition + 1)%currentAdditionnalConnection
				
				currMaxDepth = depth
				deepestId = currId
				#print("dead end: ", deepestId, " ", currMaxDepth)
				if cubeGraph.getDepth(currId) == -1:
					#print("e-setDepth(", currId, ",", depth, ")")
					cubeGraph.setDepth(currId, depth)
			
			currId = stack.pop_back()
			cubeGraph.setVisited(currId)
			#cubeGraph.setDepth(currId, depth)
			depth -= 1
			
			# when all nodes are allready visited (stack empty) and we are 
			# back to the begining, connect the last updated node (means the 
			# last dead end) with the upper layer if exist
			if stack.is_empty() && cubeGraph.hasUpNeighbors(deepestId):
				stack.append(cubeGraph.getUpNeighbors(deepestId))
				cubeGraph.connectNeighbors(deepestId, stack.back())
				cubeGraph.setVisited(stack.back())
				currId = stack.back()
				
				depth = cubeGraph.getDepth(deepestId)
				depth += 1
				#print("c-setDepth(", currId, ",", depth, ")")
				cubeGraph.setDepth(currId, depth)
				deepestId = currId
				currMaxDepth = depth
				
				for i in range(currentAdditionnalConnection):
					if secondLayerTransitionId[i] != -1 && secondLayerTransitionId[i] != 0 && cubeGraph.hasUpNeighbors(secondLayerTransitionId[i]):
						cubeGraph.connectNeighbors(secondLayerTransitionId[i], 
							cubeGraph.getUpNeighbors(secondLayerTransitionId[i]))
					secondLayerTransitionId[i] = -1
				# set random nbr of connection for the next transition layer
				currentAdditionnalConnection = randi_range(0, maxAdditionnalConnections)
			continue
		elif deadendReached:
			depth += 1
			deadendReached = false
		
		neighborsToExplo.shuffle()
		
		var newId = neighborsToExplo.pop_front()
		cubeGraph.connectNeighbors(currId, newId)
		cubeGraph.setProcessing(newId)
		currId = newId
		lastUpdated = newId
		depth += 1
		if cubeGraph.getDepth(currId) == -1:
			#print("n-setDepth(", currId, ",", depth, ")")
			cubeGraph.setDepth(currId, depth)
		stack.append(currId)

# BE CAREFULL : this function reset depth and color of current cubeGraph 
# using beginId for the new generation base : 0 by default
func deepensPath_wideWay(mazeUsed, beginId: int = 0):
	cubeGraph.reset_Depth_Color_Visited()
	
	if mazeUsed.is_empty(): return
	
	var neighbors: Array[int]
	var depth: int = 0
	neighbors = cubeGraph.getNeighborsConnectionNotVisited(beginId)
	cubeGraph.setDepth(beginId, depth)
	cubeGraph.setVisited(beginId)
	for i in neighbors:
		cubeGraph.setVisited(i)
	
	var neighborsNext: Array[int]
	
	while(!neighbors.is_empty()) :
		neighborsNext = neighbors.duplicate()
		neighbors.clear()
		depth += 1
		while(!neighborsNext.is_empty()) :
			var currentNeighbor:int = neighborsNext.pop_back() # neighbors to proccess
			cubeGraph.setDepth(currentNeighbor, depth)
			for i in cubeGraph.getNeighborsConnectionNotVisited(currentNeighbor):
				neighbors.append(i)
				cubeGraph.setVisited(i)
				
		
	cubeGraph.setColorFromDepth()

func instantiatePyramidConnection(mazeUsed, depthReached: int):
	if !newConnectionDebug:
		return
	for id in mazeUsed:
		for i in cubeGraph.getNextNeighbors(id):
			# print(id, " ", i, " ", (mazeUsed[i].getCenter() - mazeUsed[id].getCenter()).normalized())
			add_child(
				cubeGraph.instantiate_pyramid(
					mazeUsed[id].getCenter(),
					mazeUsed[i].getCenter() - mazeUsed[id].getCenter(),
					cubeGraph.computeColor(cubeGraph.getDepth(id),depthReached)
				)
			)

func instantiatePyramidConnection_allNeighbors(mazeUsed, depthReached: int):
	if !newConnectionDebug:
		return
	for id in mazeUsed:
		for i in cubeGraph.getNeighbors(id):
			if i > -1:
				add_child(
					cubeGraph.instantiate_pyramid(
						mazeUsed[id].getCenter(),
						mazeUsed[i].getCenter() - mazeUsed[id].getCenter(),
						cubeGraph.computeColor(cubeGraph.getDepth(id),depthReached)
					)
				)

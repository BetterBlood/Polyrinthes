extends Node3D
const CubeCustom := preload("res://scripts/CubeCustom.gd")
const TruncatedOctahedronCustom := preload("res://scripts/TruncatedOctahedronCustom.gd")
const CubeGraph := preload("res://scripts/cubeGraph.gd")
var wall = preload("res://scenes/wall.tscn")
var cubeGraph: CubeGraph

const TruncatedOctahedron := preload("res://scenes/octaedre_tronque.tscn") # DEBUG

var mazeAll:Dictionary= {}
var maze:Dictionary= {}
var mazeTruncOcta:Dictionary= {}

var size = 3 # default size
# 10.5 : normal spacing for cube rooms
# 21 : spacing to add gap between cube rooms
var gapBetweenRooms_multiplier = 1 # 1 for no gap, other value for DEBUG
var gapBetweenCubeCenter = (CubeCustom.distFromCenter * 2 + 0.1) * \
		gapBetweenRooms_multiplier
var gapBetweenTruncatedOctahedronCenter = (17.5*2 + 0.25) * \
		gapBetweenRooms_multiplier
var wallV = -1 # -1 = wall (only -1 !!)
var outWallV = -2 # -2 = ~ invisible walls (DEBUG), -1 visible walls

var thread: Thread
signal end_generate()

var debug: bool = true
var newConnectionDebug: bool = true


# Called when the node enters the scene tree for the first time.
func _ready(): # (backward, forward, left, right, down, up)
	#generate(size)
	
#	var truncOcta = TruncatedOctahedron.instantiate()
#	truncOcta.position = Vector3(0, 0, 50)
#	add_child(truncOcta)
#
#	var truncOctaCust = TruncatedOctahedronCustom.new(
#		Vector3(50, 0, 50), 
#		[-1, -1, -1, -1, -1, -1], 
#		0, 
#		0,
#		false,
#		true,
#		true
#	)
#
#	add_child(truncOctaCust)
	pass

func _process(_delta):
	pass

func generate(sizeP:int):
	var colorBasedOnDepth = true
	cubeGraph = CubeGraph.new(sizeP, wallV, outWallV, 6, colorBasedOnDepth)
	var sizeBase = cubeGraph.size
	var sizeFace = cubeGraph.getNbrRoomOnASide()
	var sizeTotal = cubeGraph.getNbrRoom()
	
	var showWall:bool = false # will show walls marked as -1 (wallV or outWallV)
	var triColor:bool = true
	
#	if (sizeBase == 3): 
#		exampleDebugforsize3()
#		return
	
	var beginId = 0
	# only for normal generation : odd size, middle: cubeGraph.getNbrRoom()/2 
	#createPath_deepWay(beginId)
	#createPath_deepWay_alt_1(beginId)
	#createPath_deepWay_alt_2(beginId)
	#createPath_deepWay_layer_by_layer(beginId)
	#createPath_deepWay_layer_by_layer_alt_1(beginId)
	#createPath_deepWay_layer_by_layer_alt_2(beginId)
	#createPath_deepWay_layer_by_layer_alt_3(beginId)
	#createPath_deepWay_layer_by_layer_alt_4(beginId)
	#createPath_deepWay_layer_by_layer_alt_5(beginId)
	createPath_deepWay_layer_by_layer_alt_6(beginId)
	
	deepensPath_wideWay(beginId) # recompute connections from given id
	var depthReached = cubeGraph.deepest
	
	if colorBasedOnDepth:
		cubeGraph.setColorFromDepth()
	
	# TODO : set this spawn point parametric
	var xCoordBase = -(gapBetweenCubeCenter * (sizeBase / 2))
	var yCoordBase = 0
	var zCoordBase = -50
	
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
	print("100% in " + str((time_end - time_start)/1000) + "s " + \
		str((time_end - time_start)%1000) + "ms.\n\nsecond generation")
	
	instantiatePyramidConnection_allNeighbors(mazeAll)
	
	# reset to new location :
	xCoordBase = xCoordBase + gapBetweenCubeCenter * (sizeBase + 1)
	xCoord = xCoordBase
	yCoord = yCoordBase
	zCoord = zCoordBase
	
	time_start = Time.get_ticks_msec()
	for i in range(sizeTotal):
		#if i%sizeBase == sizeBase - 1: print((100*i)/sizeTotal, "%")
		#print(xCoord, " ", yCoord, " ", zCoord)
		#print(cubeGraph.getNeighbors(i))
		
		var cube = CubeCustom.new(
		#var cube = TruncatedOctahedronCustom.new(
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
	print("100% in " + str((time_end - time_start)/1000) + "s "+ \
		str((time_end - time_start)%1000) + "ms.")
	
	instantiatePyramidConnection(maze)
	
	print("cubeGraph.getNbrRoom(): ", sizeTotal, ", depth: ", depthReached)
	
	# reset to new location (for truncated octahedron):
	xCoordBase = xCoordBase + gapBetweenCubeCenter * sizeBase + gapBetweenTruncatedOctahedronCenter
	xCoord = xCoordBase
	yCoord = yCoordBase
	zCoord = zCoordBase
	
	time_start = Time.get_ticks_msec()
	for i in range(sizeTotal): # TODO : truncatedOctahedronGraph (to file empty spaces with usable rooms)
		var truncatedOctahedron = TruncatedOctahedronCustom.new(
			Vector3(xCoord,yCoord,zCoord), 
			cubeGraph.getNeighborsConnection(i), 
			cubeGraph.getColor(i), 
			depthReached,
			debug,
			showWall,
			triColor
		)
		
		add_child(truncatedOctahedron)
		mazeTruncOcta[i] = truncatedOctahedron
		
		xCoord += gapBetweenTruncatedOctahedronCenter
		
		if i%(sizeBase) == sizeBase - 1:
			xCoord = xCoordBase
			yCoord += gapBetweenTruncatedOctahedronCenter
		
		if i%(sizeFace) == (sizeFace) - 1:
			yCoord = yCoordBase
			zCoord -= gapBetweenTruncatedOctahedronCenter
		
	time_end = Time.get_ticks_msec()
	print("100% truncated octahedron in " + \
		str((time_end - time_start)/1000) + "s "+ str((time_end - time_start)%1000) + "ms.")
	
	instantiatePyramidConnection(mazeTruncOcta)

func _on_menu_generation(edgeSize) -> void:
	clean()
	generate(edgeSize)

func clean() -> void:
	maze.clear()
	mazeAll.clear()
	mazeTruncOcta.clear()
	
	for i in self.get_children():
		if i is CubeCustom or i is TruncatedOctahedronCustom:
			i.clean()
			self.remove_child(i)
			i.queue_free()
		elif i is MeshInstance3D:
			self.remove_child(i)
			i.queue_free()
	
	if cubeGraph != null:
		cubeGraph.clean()

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
		cubeGraph.connectNeighbors(6, 15)
		cubeGraph.connectNeighbors(15, 24)
		cubeGraph.connectNeighbors(24, 25)
		cubeGraph.connectNeighbors(25, 26)
		cubeGraph.connectNeighbors(26, 17)
		cubeGraph.connectNeighbors(17, 8)
		cubeGraph.connectNeighbors(8, 7)
		cubeGraph.connectNeighbors(7, 16)
		
		var xCoordBase = -(gapBetweenCubeCenter * (3 / 2))
		var yCoordBase = 0
		
		var xCoord = xCoordBase
		var yCoord = yCoordBase
		var zCoord = -50
		
		deepensPath_wideWay(18)
		cubeGraph.setColorFromDepth()
		var depthReached = cubeGraph.deepest
		
		for i in range(cubeGraph.getNbrRoom()):
			var cube = CubeCustom.new(
				Vector3(xCoord,yCoord,zCoord), 
				cubeGraph.getNeighborsConnection(i),
				cubeGraph.getColor(i), 
				depthReached,
				true,
				false,
				true
			)
			
			add_child(cube)
			maze[i] = cube
			
			xCoord += gapBetweenCubeCenter
			
			if i%3 == 3 - 1:
				xCoord = xCoordBase
				yCoord += gapBetweenCubeCenter
			
			if i%9 == 9 - 1:
				yCoord = yCoordBase
				zCoord -= gapBetweenCubeCenter
				
		instantiatePyramidConnection(maze)

func createPath_deepWay(beginId: int = 0):
	var neighborsToExplo = []
	var stack = []
	
	stack.append(beginId)
	cubeGraph.setVisited(beginId) # not interesting to remove this line
	#cubeGraph.setDepth(beginId, 0)
	
	var currId = beginId
	
	while not stack.is_empty():
		neighborsToExplo.clear()
		neighborsToExplo.append_array(cubeGraph.getNotVisitedNeighbors(currId))
		#print(neighborsToExplo)
		
		if len(neighborsToExplo) == 0:
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
		
		if len(neighborsToExplo) == 0:
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

func createPath_deepWay_alt_2(beginId: int = 0):
	var neighborsToExplo = []
	var stack = []
	
	stack.append(beginId)
	cubeGraph.setVisited(beginId) # not interesting to remove this line
	
	var currId = beginId
	
	while not stack.is_empty():
		neighborsToExplo.clear()
		neighborsToExplo.append_array(cubeGraph.getNotVisitedNeighbors(currId))
		
		if len(neighborsToExplo) == 0:
			stack.shuffle()
			currId = stack.pop_back()
			continue
		
		stack.append(currId)
		neighborsToExplo.shuffle()
		
		var newId = neighborsToExplo.pop_front()
		cubeGraph.connectNeighbors(currId, newId)
		cubeGraph.setVisited(newId)
		currId = newId

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
			# when all nodes are already visited (stack empty) and we are 
			# back to the beginning, connect the last updated node (means the 
			# last dead end) with the upper layer if exist
			if stack.is_empty() && cubeGraph.hasUpNeighbors(lastUpdated):
				currId = cubeGraph.getUpNeighbors(lastUpdated)
				stack.append(currId)
				cubeGraph.connectNeighbors(lastUpdated, currId)
				cubeGraph.setVisited(currId)
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
				currId = cubeGraph.getUpNeighbors(lastUpdated)
				stack.append(currId)
				cubeGraph.connectNeighbors(lastUpdated, currId)
				cubeGraph.setVisited(currId)
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
	var depth:int = 0
	
	var deepestId = beginId
	var currMaxDepth = 0
	
	stack.append(currId)
	cubeGraph.setVisited(currId)
	#print("d-setDepth(", currId, ",", depth, ")")
	cubeGraph.setDepth(currId, depth)
	
	while not stack.is_empty():
		neighborsToExplo.clear()
		# with "true" get only neighbors on the same layer
		neighborsToExplo.append_array(cubeGraph.getNotVisitedNeighbors(currId, true))
		depth = cubeGraph.getDepth(currId)
		
		if len(neighborsToExplo) == 0:
			if currMaxDepth < depth :
				currMaxDepth = depth
				deepestId = currId
			
			currId = stack.pop_back()
			cubeGraph.setVisited(currId)
			
			# when all nodes are already visited (stack empty) and we are 
			# back to the begining, connect the last updated node (means the 
			# last dead end) with the upper layer if exist
			if stack.is_empty() && cubeGraph.hasUpNeighbors(deepestId):
				currId = cubeGraph.getUpNeighbors(deepestId)
				stack.append(currId)
				cubeGraph.connectNeighbors(deepestId, currId)
				cubeGraph.setVisited(currId)
				
				#print("c-setDepth(", currId, ",", depth, ")")
				currMaxDepth = cubeGraph.getDepth(deepestId) + 1
				cubeGraph.setDepth(currId, currMaxDepth)
				deepestId = currId
			continue
		
		neighborsToExplo.shuffle()
		
		var newId = neighborsToExplo.pop_front()
		cubeGraph.connectNeighbors(currId, newId)
		cubeGraph.setVisited(newId)
		cubeGraph.setDepth(newId, depth + 1)
		currId = newId
		stack.append(currId)

# 2 transitions between layers
func createPath_deepWay_layer_by_layer_alt_3(beginId: int = 0):
	var neighborsToExplo = []
	var stack = []
	var currId = beginId
	var depth:int = 0
	var deepestId = currId
	var currMaxDepth = 0
	
	var secondLayerTransitionId = -1
	var lastSecondId = secondLayerTransitionId
	var lastDeepestId = deepestId
	
	stack.append(currId)
	cubeGraph.setVisited(currId)
	cubeGraph.setDepth(currId, depth)
	
	while not stack.is_empty():
		neighborsToExplo.clear()
		neighborsToExplo.append_array(cubeGraph.getNotVisitedNeighbors(currId, true))
		depth = cubeGraph.getDepth(currId)
		
		if len(neighborsToExplo) == 0:
			if currMaxDepth < depth && currId != lastDeepestId && currId != lastSecondId:
				secondLayerTransitionId = deepestId
				
				currMaxDepth = depth
				deepestId = currId
			
			currId = stack.pop_back()
			cubeGraph.setVisited(currId)
			
			# when all nodes are already visited (stack empty) and we are 
			# back to the begining, connect the last updated node (means the 
			# last dead end) with the upper layer if exist
			if stack.is_empty() && cubeGraph.hasUpNeighbors(deepestId):
				currId = cubeGraph.getUpNeighbors(deepestId)
				stack.append(currId)
				cubeGraph.connectNeighbors(deepestId, currId)
				cubeGraph.setVisited(currId)
				
				currMaxDepth = cubeGraph.getDepth(deepestId) + 1
				cubeGraph.setDepth(currId, currMaxDepth)
				deepestId = currId
				
				if secondLayerTransitionId != lastSecondId && \
				   secondLayerTransitionId != lastDeepestId && \
				   cubeGraph.hasUpNeighbors(secondLayerTransitionId):
					cubeGraph.connectNeighbors(secondLayerTransitionId, 
						cubeGraph.getUpNeighbors(secondLayerTransitionId))
					lastSecondId = cubeGraph.getUpNeighbors(secondLayerTransitionId)
				else:
					lastSecondId = -1
					
				lastDeepestId = deepestId
			continue
		
		neighborsToExplo.shuffle()
		
		var newId = neighborsToExplo.pop_front()
		cubeGraph.connectNeighbors(currId, newId)
		cubeGraph.setVisited(newId)
		currId = newId
		cubeGraph.setDepth(currId, depth + 1)
		stack.append(currId)

# cubeGraph.size*(1/3) transitions between layers
func createPath_deepWay_layer_by_layer_alt_4(beginId: int = 0):
	var neighborsToExplo = []
	var stack = []
	var currId = beginId
	var depth:int = 0
	var deepestId = currId
	var currMaxDepth = 0
	
	var secondLayerTransitionId = []
	var lastSecondId = []
	var lastDeepestId = deepestId
	var additionalConnections = int(cubeGraph.size * (1/3.) - 1)
	
	for i in range(additionalConnections):
		secondLayerTransitionId.append(-1)
		lastSecondId.append(-1)
	
	stack.append(currId)
	cubeGraph.setVisited(currId)
	#print("d-setDepth(", currId, ",", depth, ")")
	cubeGraph.setDepth(currId, depth)
	
	while not stack.is_empty():
		neighborsToExplo.clear()
		# with "true" get only neighbors on the same layer
		neighborsToExplo.append_array(cubeGraph.getNotVisitedNeighbors(currId, true))
		depth = cubeGraph.getDepth(currId)
		
		if len(neighborsToExplo) == 0:
			if currMaxDepth < depth && currId != lastDeepestId && currId not in lastSecondId:
				var indexForTransition = 0
				var currSmallestDepth = cubeGraph.getNbrRoom() + 2
				for i in range(additionalConnections):
					if secondLayerTransitionId[i] == -1:
						indexForTransition = i
						break
					if secondLayerTransitionId[i] != -1 && \
					   currSmallestDepth > cubeGraph.getDepth(secondLayerTransitionId[i]):
						indexForTransition = i
						currSmallestDepth = cubeGraph.getDepth(secondLayerTransitionId[i])
				if additionalConnections > 0:
					secondLayerTransitionId[indexForTransition] = deepestId
				
				currMaxDepth = depth
				deepestId = currId
			
			currId = stack.pop_back()
			cubeGraph.setVisited(currId)
			
			# when all nodes are already visited (stack empty) and we are 
			# back to the begining, connect the last updated node (means the 
			# last dead end) with the upper layer if exist
			if stack.is_empty() && cubeGraph.hasUpNeighbors(deepestId):
				currId = cubeGraph.getUpNeighbors(deepestId)
				stack.append(currId)
				cubeGraph.connectNeighbors(deepestId, currId)
				cubeGraph.setVisited(currId)
				
				currMaxDepth = cubeGraph.getDepth(deepestId) + 1
				cubeGraph.setDepth(currId, currMaxDepth)
				deepestId = currId
				
				for i in range(additionalConnections):
					if secondLayerTransitionId[i] not in lastSecondId && \
					   secondLayerTransitionId[i] != lastDeepestId && \
					   cubeGraph.hasUpNeighbors(secondLayerTransitionId[i]):
						cubeGraph.connectNeighbors(secondLayerTransitionId[i], 
							cubeGraph.getUpNeighbors(secondLayerTransitionId[i]))
					else:
						secondLayerTransitionId[i] = -1
				for i in range(additionalConnections):
					lastSecondId[i] = cubeGraph.getUpNeighbors(secondLayerTransitionId[i])
				lastDeepestId = deepestId
			continue
		
		neighborsToExplo.shuffle()
		
		var newId = neighborsToExplo.pop_front()
		cubeGraph.connectNeighbors(currId, newId)
		cubeGraph.setVisited(newId)
		currId = newId
		cubeGraph.setDepth(currId, depth + 1)
		stack.append(currId)

# random number of transition transitions between layers max : cubeGraph.size*(1/3)
func createPath_deepWay_layer_by_layer_alt_5(beginId: int = 0):
	var neighborsToExplo = []
	var stack = []
	var currId = beginId
	var depth:int = 0
	var deepestId = beginId
	var currMaxDepth = 0
	
	var lastSecondId = []
	var lastDeepestId = deepestId
	var secondLayerTransitionId = []
	var maxAdditionalConnections = int(cubeGraph.size * (1/3.) - 1)
	var currentAdditionalConnection = randi_range(0, maxAdditionalConnections)
	
	for i in range(maxAdditionalConnections):
		secondLayerTransitionId.append(-1)
		lastSecondId.append(-1)
	
	stack.append(currId)
	cubeGraph.setVisited(currId)
	#print("d-setDepth(", currId, ",", depth, ")")
	cubeGraph.setDepth(currId, depth)
	
	while not stack.is_empty():
		neighborsToExplo.clear()
		# with "true" get only neighbors on the same layer
		neighborsToExplo.append_array(cubeGraph.getNotVisitedNeighbors(currId, true))
		depth = cubeGraph.getDepth(currId)
		
		if len(neighborsToExplo) == 0:
			if currMaxDepth < depth && currId != lastDeepestId && currId not in lastSecondId:
				var indexForTransition = 0
				var currSmallestDepth = cubeGraph.getNbrRoom() + 2
				for i in range(currentAdditionalConnection):
					if secondLayerTransitionId[i] == -1:
						indexForTransition = i
						break
					if secondLayerTransitionId[i] != -1 && \
					   currSmallestDepth > cubeGraph.getDepth(secondLayerTransitionId[i]):
						indexForTransition = i
						currSmallestDepth = cubeGraph.getDepth(secondLayerTransitionId[i])
				if currentAdditionalConnection > 0:
					secondLayerTransitionId[indexForTransition] = deepestId
				
				currMaxDepth = depth
				deepestId = currId
			
			currId = stack.pop_back()
			cubeGraph.setVisited(currId)
			
			# when all nodes are allready visited (stack empty) and we are 
			# back to the begining, connect the last updated node (means the 
			# last dead end) with the upper layer if exist
			if stack.is_empty() && cubeGraph.hasUpNeighbors(deepestId):
				currId = cubeGraph.getUpNeighbors(deepestId)
				stack.append(currId)
				cubeGraph.connectNeighbors(deepestId, currId)
				cubeGraph.setVisited(currId)
				
				currMaxDepth = cubeGraph.getDepth(deepestId) + 1
				cubeGraph.setDepth(currId, currMaxDepth)
				deepestId = currId
				
				for i in range(currentAdditionalConnection):
					if secondLayerTransitionId[i] not in lastSecondId && \
					   secondLayerTransitionId[i] != lastDeepestId && \
					   cubeGraph.hasUpNeighbors(secondLayerTransitionId[i]):
						cubeGraph.connectNeighbors(secondLayerTransitionId[i], 
							cubeGraph.getUpNeighbors(secondLayerTransitionId[i]))
					else:
						secondLayerTransitionId[i] = -1
				for i in range(currentAdditionalConnection):
					lastSecondId[i] = cubeGraph.getUpNeighbors(secondLayerTransitionId[i])
				lastDeepestId = deepestId
				# set random nbr of connection for the next transition layer
				currentAdditionalConnection = randi_range(0, maxAdditionalConnections)
			continue
		
		neighborsToExplo.shuffle()
		
		var newId = neighborsToExplo.pop_front()
		cubeGraph.connectNeighbors(currId, newId)
		cubeGraph.setVisited(newId)
		currId = newId
		cubeGraph.setDepth(currId, depth + 1)
		stack.append(currId)

# random number of transition transitions between layers max : cubeGraph.size*(1/3)
# shuffle the stack on deadend
func createPath_deepWay_layer_by_layer_alt_6(beginId: int = 0):
	var neighborsToExplo = []
	var stack = []
	var currId = beginId
	var depth:int = 0
	var deepestId = beginId
	var currMaxDepth = 0
	
	var lastSecondId = []
	var lastDeepestId = deepestId
	var secondLayerTransitionId = []
	var maxAdditionalConnections = int(cubeGraph.size * (1/3.) - 1)
	var currentAdditionalConnection = randi_range(0, maxAdditionalConnections)
	
	for i in range(maxAdditionalConnections):
		secondLayerTransitionId.append(-1)
		lastSecondId.append(-1)
	
	stack.append(currId)
	cubeGraph.setVisited(currId)
	#print("d-setDepth(", currId, ",", depth, ")")
	cubeGraph.setDepth(currId, depth)
	
	while not stack.is_empty():
		neighborsToExplo.clear()
		# with "true" get only neighbors on the same layer
		neighborsToExplo.append_array(cubeGraph.getNotVisitedNeighbors(currId, true))
		depth = cubeGraph.getDepth(currId)
		
		if len(neighborsToExplo) == 0:
			if currMaxDepth < depth && currId != lastDeepestId && currId not in lastSecondId:
				var indexForTransition = 0
				var currSmallestDepth = cubeGraph.getNbrRoom() + 2
				for i in range(currentAdditionalConnection):
					if secondLayerTransitionId[i] == -1:
						indexForTransition = i
						break
					if secondLayerTransitionId[i] != -1 && \
					   currSmallestDepth > cubeGraph.getDepth(secondLayerTransitionId[i]):
						indexForTransition = i
						currSmallestDepth = cubeGraph.getDepth(secondLayerTransitionId[i])
				if currentAdditionalConnection > 0:
					secondLayerTransitionId[indexForTransition] = deepestId
				
				currMaxDepth = depth
				deepestId = currId
			
			stack.shuffle()
			currId = stack.pop_back()
			#cubeGraph.setVisited(currId)
			
			# when all nodes are allready visited (stack empty) and we are 
			# back to the begining, connect the last updated node (means the 
			# last dead end) with the upper layer if exist
			if stack.is_empty() && cubeGraph.hasUpNeighbors(deepestId):
				currId = cubeGraph.getUpNeighbors(deepestId)
				stack.append(currId)
				cubeGraph.connectNeighbors(deepestId, currId)
				cubeGraph.setVisited(currId)
				
				currMaxDepth = cubeGraph.getDepth(deepestId) + 1
				cubeGraph.setDepth(currId, currMaxDepth)
				deepestId = currId
				
				for i in range(currentAdditionalConnection):
					if secondLayerTransitionId[i] not in lastSecondId && \
					   secondLayerTransitionId[i] != lastDeepestId && \
					   cubeGraph.hasUpNeighbors(secondLayerTransitionId[i]):
						cubeGraph.connectNeighbors(secondLayerTransitionId[i], 
							cubeGraph.getUpNeighbors(secondLayerTransitionId[i]))
						print("connect: ", secondLayerTransitionId[i], " and: ", cubeGraph.getUpNeighbors(secondLayerTransitionId[i]))
					else:
						secondLayerTransitionId[i] = -1
				print(currentAdditionalConnection, " ", lastDeepestId, " ", lastSecondId)
				for i in range(currentAdditionalConnection):
					lastSecondId[i] = cubeGraph.getUpNeighbors(secondLayerTransitionId[i])
				lastDeepestId = deepestId
				# set random nbr of connection for the next transition layer
				currentAdditionalConnection = randi_range(0, maxAdditionalConnections)
				print(currentAdditionalConnection, " ", lastDeepestId, " ", lastSecondId)
			continue
		
		neighborsToExplo.shuffle()
		
		var newId = neighborsToExplo.pop_front()
		cubeGraph.connectNeighbors(currId, newId)
		cubeGraph.setVisited(newId)
		currId = newId
		cubeGraph.setDepth(currId, depth + 1)
		stack.append(currId)


# BE CAREFULL : this function reset depth and color stored of cubeGraph 
# using beginId for the new generation base : 0 by default
func deepensPath_wideWay(beginId: int = 0):
	cubeGraph.reset_Depth_Color_Visited()
	
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
			var currentNeighbor:int = neighborsNext.pop_back() # neighbors to process
			cubeGraph.setDepth(currentNeighbor, depth)
			for i in cubeGraph.getNeighborsConnectionNotVisited(currentNeighbor):
				neighbors.append(i)
				cubeGraph.setVisited(i)
		
	cubeGraph.setColorFromDepth()

func instantiatePyramidConnection(mazeUsed: Dictionary):
	if !newConnectionDebug:
		return
	var depthReached = cubeGraph.deepest 
	for id in mazeUsed:
		for i in cubeGraph.getNextNeighbors(id):
			# print(id, " ", i, " ", (mazeUsed[i].getCenter() - mazeUsed[id].getCenter()).normalized())
			add_child(
				cubeGraph.instantiate_pyramid(
					mazeUsed[id].getCenter(),
					mazeUsed[i].getCenter() - mazeUsed[id].getCenter(),
					cubeGraph.computeColor(cubeGraph.getDepth(id), depthReached)
				)
			)

func instantiatePyramidConnection_allNeighbors(mazeUsed: Dictionary):
	if !newConnectionDebug:
		return
	var depthReached = cubeGraph.deepest 
	for id in mazeUsed:
		for i in cubeGraph.getNeighbors(id):
			if i > -1 && cubeGraph.isFollowing(id, i):
				add_child(
					cubeGraph.instantiate_pyramid(
						mazeUsed[id].getCenter(),
						mazeUsed[i].getCenter() - mazeUsed[id].getCenter(),
						cubeGraph.computeColor(cubeGraph.getDepth(id), depthReached)
					)
				)

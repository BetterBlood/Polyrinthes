extends Node3D
const CubeCustom := preload("res://scripts/CubeCustom.gd")
const TruncatedOctahedronCustom := preload("res://scripts/TruncatedOctahedronCustom.gd")
const CubeGraph := preload("res://scripts/cubeGraph.gd")
const TruncOctaGraph := preload("res://scripts/truncOctaGraph.gd")
var wall = preload("res://scenes/wall.tscn")

const TruncatedOctahedron := preload("res://scenes/octaedre_tronque.tscn") # DEBUG
var graphUsed

enum RoomType {
	CUBES = 0, 
	TRUNCATED_OCTAHEDRON_WITH_HOLES = 1, 
	TRUNCATED_OCTAHEDRON_FULL = 2
}

var roomType: RoomType = RoomType.TRUNCATED_OCTAHEDRON_FULL
#var roomType: RoomType = RoomType.TRUNCATED_OCTAHEDRON_WITH_HOLES

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
var wallV = -1 # -1 = wall
var outWallV = -2 # -2 = ~ invisible walls (DEBUG)

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
	
	match roomType:
		0, 1:
			graphUsed = CubeGraph.new(sizeP, wallV, outWallV, 6, colorBasedOnDepth)
		2: # WIP : TruncOctaGraph in progress
			#graphUsed = CubeGraph.new(sizeP, wallV, outWallV, 6, colorBasedOnDepth)
			graphUsed = TruncOctaGraph.new(sizeP, wallV, outWallV, 14, colorBasedOnDepth) # TODO : 6 to 14
		_:
			print("[ERROR] no match for enum RoomType :", roomType, ", value :", int(roomType))
	
	var sizeBase = graphUsed.size
	var sizeFace = graphUsed.getNbrRoomOnASide()
	var sizeTotal = graphUsed.getNbrRoom()
	
	var showWall:bool = true # will show walls marked as -1 (wallV or outWallV) (-2 are ignored anyway)
	var triColor:bool = true
	
#	if (sizeBase == 3): 
#		exampleDebugforsize3()
#		return
	
	var beginId = 0
	# only for normal (not layered) generation and odd size, begin at center: 
	#beginId = graphUsed.getNbrRoom()/2 
	#createPath_deepWay(beginId) # colorBasedOnDepth should be false or TODO
	
	#createPath_deepWay_layer_by_layer(beginId) # colorBasedOnDepth should be false or TODO
	#createPath_deepWay_layer_by_layer_alt_1(beginId) # colorBasedOnDepth should be false or TODO
	#createPath_deepWay_layer_by_layer_alt_2(beginId)
	#createPath_deepWay_layer_by_layer_alt_3(beginId)
	#createPath_deepWay_layer_by_layer_alt_4(beginId)
	createPath_deepWay_layer_by_layer_alt_5(beginId)
	
	deepensPath_wideWay(beginId) # recompute connections from given id
	
	var depthReached = graphUsed.lastVisited
	
	if colorBasedOnDepth:
		graphUsed.setColorFromDepth()
	
	# TODO : set this spawn point parametric
	var xCoordBase = -(gapBetweenCubeCenter * (sizeBase / 2))
	var yCoordBase = 0
	var zCoordBase = -50
	
	var xCoord = xCoordBase
	var yCoord = yCoordBase
	var zCoord = zCoordBase
	
	print("\nfirst generation (partially for debug)")
	var time_start = Time.get_ticks_msec()
	for i in range(sizeTotal):
		#if i%graphUsed.size == graphUsed.size - 1: print((100*i)/graphUsed.getNbrRoom(), "%")
		#print(xCoord, " ", yCoord, " ", zCoord)
		#print(graphUsed.getNeighbors(i))
		var cube = CubeCustom.new(
			Vector3(xCoord,yCoord,zCoord), 
			graphUsed.getNeighbors(i),
			graphUsed.getColor(i), 
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
		#print(graphUsed.getNeighbors(i))
		
		var cube = CubeCustom.new(
			Vector3(xCoord,yCoord,zCoord), 
			graphUsed.getNeighborsConnection(i), 
			graphUsed.getColor(i), 
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
		
		# (TODO) : find a way to continue moving while rendering graph
		# this following line slow down the render but regenerate (while generating)
		# could send errors (try to delete not existing node)
		# await get_tree().create_timer(0.001).timeout 
		
	time_end = Time.get_ticks_msec()
	
	print("100% in " + str((time_end - time_start)/1000) + "s "+ \
		str((time_end - time_start)%1000) + "ms.")
	
	instantiatePyramidConnection(maze)
	
	print("\ngraphUsed.getNbrRoom(): ", sizeTotal, ", depth: ", depthReached)
	
	# reset to new location (for truncated octahedron):
	xCoordBase = xCoordBase + gapBetweenCubeCenter * sizeBase + gapBetweenTruncatedOctahedronCenter
	xCoord = xCoordBase
	yCoord = yCoordBase
	zCoord = zCoordBase
	
	time_start = Time.get_ticks_msec()
	for i in range(sizeTotal): # TODO : truncatedOctahedronGraph (to file empty spaces with usable rooms)
		var truncatedOctahedron = TruncatedOctahedronCustom.new(
			Vector3(xCoord,yCoord,zCoord), 
			graphUsed.getNeighborsConnection(i), 
			graphUsed.getColor(i), 
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
	
	if roomType == RoomType.TRUNCATED_OCTAHEDRON_FULL:
		var initialGap = 17.6
		# reset for inside
		xCoord = xCoordBase + initialGap
		yCoord = yCoordBase + initialGap
		zCoord = zCoordBase - initialGap
		var sizeBaseInside = graphUsed.size - 1
		var sizeFaceInside = sizeBaseInside * sizeBaseInside
		var sizeTotalInside = sizeBaseInside * sizeBaseInside * sizeBaseInside
		
		for i in range(sizeTotalInside):
			var truncOctaCust = TruncatedOctahedronCustom.new(
				Vector3(xCoord,yCoord,zCoord), 
				[-1, -1, -1, -1, -1, -1], 
				0, 
				0,
				false,
				true,
				true
			)
			
			add_child(truncOctaCust)
			#mazeTruncOcta[sizeTotal + i] = truncOctaCust
			
			xCoord += gapBetweenTruncatedOctahedronCenter
			
			if i%(sizeBaseInside) == sizeBaseInside - 1:
				xCoord = xCoordBase + initialGap
				yCoord += gapBetweenTruncatedOctahedronCenter
			
			if i%(sizeFaceInside) == (sizeFaceInside) - 1:
				yCoord = yCoordBase + initialGap
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
	
	if graphUsed != null:
		graphUsed.clean()
	

func exampleDebugforsize3():
	if graphUsed.size == 3 :
		# floor 1
		graphUsed.connectNeighbors(18, 19)
		graphUsed.connectNeighbors(19, 10)
		graphUsed.connectNeighbors(19, 20)
		graphUsed.connectNeighbors(20, 11)
		graphUsed.connectNeighbors(11, 2)
		graphUsed.connectNeighbors(2, 1)
		graphUsed.connectNeighbors(1, 0)
		graphUsed.connectNeighbors(0, 9)

		# floor connection from 1 to 2
		graphUsed.connectNeighbors(9, 12)

		# floor 2
		graphUsed.connectNeighbors(12, 13)
		graphUsed.connectNeighbors(13, 22)
		graphUsed.connectNeighbors(22, 21)
		graphUsed.connectNeighbors(13, 14)
		graphUsed.connectNeighbors(14, 23)
		graphUsed.connectNeighbors(14, 5)
		graphUsed.connectNeighbors(5, 4)
		graphUsed.connectNeighbors(4, 3)

		# floor connection from 2 to 3
		graphUsed.connectNeighbors(3, 6)

		# floor 3
		graphUsed.connectNeighbors(6, 15)
		graphUsed.connectNeighbors(15, 24)
		graphUsed.connectNeighbors(24, 25)
		graphUsed.connectNeighbors(25, 26)
		graphUsed.connectNeighbors(26, 17)
		graphUsed.connectNeighbors(17, 8)
		graphUsed.connectNeighbors(8, 7)
		graphUsed.connectNeighbors(7, 16)
		
		var xCoordBase = -(gapBetweenCubeCenter * (3 / 2))
		var yCoordBase = 0
		
		var xCoord = xCoordBase
		var yCoord = yCoordBase
		var zCoord = -50
		
		deepensPath_wideWay(18)
		graphUsed.setColorFromDepth()
		var depthReached = graphUsed.deepest
		
		for i in range(graphUsed.getNbrRoom()):
			var cube = CubeCustom.new(
				Vector3(xCoord,yCoord,zCoord), 
				graphUsed.getNeighborsConnection(i),
				graphUsed.getColor(i), 
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
	graphUsed.setVisited(beginId) # not really interesting to remove this line
	graphUsed.setDepth(beginId, 0)
	
	var currId = beginId
	
	while not stack.is_empty():
		neighborsToExplo.clear()
		neighborsToExplo.append_array(graphUsed.getNotVisitedNeighbors(currId))
		#print(neighborsToExplo)
		
		if len(neighborsToExplo) == 0 :
			currId = stack.pop_back()
			continue
		
		stack.append(currId)
		neighborsToExplo.shuffle()
		
		var newId = neighborsToExplo.pop_front()
		graphUsed.connectNeighbors(currId, newId)
		graphUsed.setVisited(newId)
		currId = newId

# Inconclusive
func createPath_deepWay_alt_1(beginId: int = 0):
	var neighborsToExplo = []
	var stack = []
	stack.append(beginId)
	graphUsed.setVisited(beginId)
	
	var currId = beginId
	var i = 0
	var newId
	
	while not stack.is_empty():
		neighborsToExplo.clear()
		neighborsToExplo.append_array(graphUsed.getNotVisitedNeighbors(currId))
		#print(neighborsToExplo)
		
		if len(neighborsToExplo) == 0 :
			currId = stack.pop_back()
			continue
		
		stack.append(currId)
		neighborsToExplo.shuffle()
		
		newId = neighborsToExplo.pop_front()
		graphUsed.connectNeighbors(currId, newId)
		graphUsed.setVisited(newId)
		var prevId = currId
		currId = newId
		i += 1
		
		if i >= graphUsed.getNbrRoomOnASide() && not neighborsToExplo.is_empty():
			#print("alt Way ?")
			stack.append(currId)
			neighborsToExplo.shuffle()
			
			newId = neighborsToExplo.pop_front()
			graphUsed.connectNeighbors(prevId, newId)
			graphUsed.setVisited(newId)
			currId = newId
			i = 0

# TODO : a deepgeneration with sometimes a switch on wide generation


func createPath_deepWay_layer_by_layer(beginId: int = 0):
	var neighborsToExplo = []
	var stack = []
	
	stack.append(beginId)
	graphUsed.setVisited(beginId)

	var currId = beginId
	var lastUpdated = currId

	while not stack.is_empty():
		neighborsToExplo.clear()
		# with "true" get only neighbors on the same layer
		neighborsToExplo.append_array(graphUsed.getNotVisitedNeighbors(currId, true))
		#print(neighborsToExplo)
		
		if len(neighborsToExplo) == 0:
			currId = stack.pop_back()
			# when all nodes are allready visited (stack empty) and we are 
			# back to the begining, connect the last updated node (means the 
			# last dead end) with the upper layer if exist
			if stack.is_empty() && graphUsed.hasUpNeighbors(lastUpdated):
				stack.append(graphUsed.getUpNeighbors(lastUpdated))
				graphUsed.connectNeighbors(lastUpdated, stack.back())
				graphUsed.setVisited(stack.back())
				currId = stack.back()
			continue
		
		stack.append(currId)
		neighborsToExplo.shuffle()
		
		var newId = neighborsToExplo.pop_front()
		graphUsed.connectNeighbors(currId, newId)
		graphUsed.setVisited(newId)
		currId = newId
		lastUpdated = currId

func createPath_deepWay_layer_by_layer_alt_1(beginId: int = 0):
	var neighborsToExplo = []
	var stack = []
	
	stack.append(beginId)
	#graphUsed.setVisited(beginId) # uncomment this to have a linear begin

	var currId = beginId
	var lastUpdated = currId

	while not stack.is_empty():
		neighborsToExplo.clear()
		# with "true" get only neighbors on the same layer
		neighborsToExplo.append_array(graphUsed.getNotVisitedNeighbors(currId, true))
		#print(neighborsToExplo)
		
		if len(neighborsToExplo) == 0:
			currId = stack.pop_back()
			# when all nodes are allready visited (stack empty) and we are 
			# back to the begining, connect the last updated node (means the 
			# last dead end) with the upper layer if exist
			if stack.is_empty() && graphUsed.hasUpNeighbors(lastUpdated):
				stack.append(graphUsed.getUpNeighbors(lastUpdated))
				graphUsed.connectNeighbors(lastUpdated, stack.back())
				graphUsed.setVisited(stack.back())
				currId = stack.back()
			continue
		
		stack.append(currId)
		neighborsToExplo.shuffle()
		
		var newId = neighborsToExplo.pop_front()
		graphUsed.connectNeighbors(currId, newId)
		graphUsed.setVisited(newId)
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
	graphUsed.setProcessing(currId)
	#print("d-setDepth(", currId, ",", depth, ")")
	graphUsed.setDepth(currId, depth)
	
	while not stack.is_empty():
		neighborsToExplo.clear()
		# with "true" get only neighbors on the same layer
		neighborsToExplo.append_array(graphUsed.getNotProcNotVisiNeighbors(currId, true))
		
		if len(neighborsToExplo) == 0:
			deadendReached = true
			if currMaxDepth < depth :
				currMaxDepth = depth
				deepestId = currId
				#print("dead end: ", deepestId, " ", currMaxDepth)
				if graphUsed.getDepth(currId) == -1:
					#print("e-setDepth(", currId, ",", depth, ")")
					graphUsed.setDepth(currId, depth)
			
			currId = stack.pop_back()
			graphUsed.setVisited(currId)
			#graphUsed.setDepth(currId, depth)
			depth -= 1
			
			# when all nodes are allready visited (stack empty) and we are 
			# back to the begining, connect the last updated node (means the 
			# last dead end) with the upper layer if exist
			if stack.is_empty() && graphUsed.hasUpNeighbors(deepestId):
				stack.append(graphUsed.getUpNeighbors(deepestId))
				graphUsed.connectNeighbors(deepestId, stack.back())
				graphUsed.setVisited(stack.back())
				currId = stack.back()
				
				depth = graphUsed.getDepth(deepestId)
				depth += 1
				#print("c-setDepth(", currId, ",", depth, ")")
				graphUsed.setDepth(currId, depth)
				deepestId = currId
				currMaxDepth = depth
			continue
		elif deadendReached:
			depth += 1
			deadendReached = false
		
		neighborsToExplo.shuffle()
		
		var newId = neighborsToExplo.pop_front()
		graphUsed.connectNeighbors(currId, newId)
		graphUsed.setProcessing(newId)
		currId = newId
		lastUpdated = newId
		depth += 1
		if graphUsed.getDepth(currId) == -1:
			#print("n-setDepth(", currId, ",", depth, ")")
			graphUsed.setDepth(currId, depth)
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
	graphUsed.setProcessing(currId)
	#print("d-setDepth(", currId, ",", depth, ")")
	graphUsed.setDepth(currId, depth)
	
	while not stack.is_empty():
		neighborsToExplo.clear()
		# with "true" get only neighbors on the same layer
		neighborsToExplo.append_array(graphUsed.getNotProcNotVisiNeighbors(currId, true))
		
		if len(neighborsToExplo) == 0:
			
			deadendReached = true
			if currMaxDepth < depth :
				prevMaxDepth = currMaxDepth
				secondLayerTransitionId = deepestId
				
				currMaxDepth = depth
				deepestId = currId
				#print("dead end: ", deepestId, " ", currMaxDepth)
				if graphUsed.getDepth(currId) == -1:
					#print("e-setDepth(", currId, ",", depth, ")")
					graphUsed.setDepth(currId, depth)
			
			currId = stack.pop_back()
			graphUsed.setVisited(currId)
			#graphUsed.setDepth(currId, depth)
			depth -= 1
			
			# when all nodes are allready visited (stack empty) and we are 
			# back to the begining, connect the last updated node (means the 
			# last dead end) with the upper layer if exist
			if stack.is_empty() && graphUsed.hasUpNeighbors(deepestId):
				stack.append(graphUsed.getUpNeighbors(deepestId))
				graphUsed.connectNeighbors(deepestId, stack.back())
				graphUsed.setVisited(stack.back())
				currId = stack.back()
				
				depth = graphUsed.getDepth(deepestId)
				depth += 1
				#print("c-setDepth(", currId, ",", depth, ")")
				graphUsed.setDepth(currId, depth)
				deepestId = currId
				currMaxDepth = depth
				
				if secondLayerTransitionId != -1 && secondLayerTransitionId != 0 && graphUsed.hasUpNeighbors(secondLayerTransitionId):
					graphUsed.connectNeighbors(secondLayerTransitionId, 
						graphUsed.getUpNeighbors(secondLayerTransitionId))
					secondLayerTransitionId = -1
			continue
		elif deadendReached:
			depth += 1
			deadendReached = false
		
		neighborsToExplo.shuffle()
		
		var newId = neighborsToExplo.pop_front()
		graphUsed.connectNeighbors(currId, newId)
		graphUsed.setProcessing(newId)
		currId = newId
		lastUpdated = newId
		depth += 1
		if graphUsed.getDepth(currId) == -1:
			#print("n-setDepth(", currId, ",", depth, ")")
			graphUsed.setDepth(currId, depth)
		stack.append(currId)

# graphUsed.size*(1/3) transitions between layers
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
	var additionnalConnections = int(graphUsed.size * (1/3.) - 1)
	
	for i in range(additionnalConnections):
		prevMaxDepth.append(0)
		secondLayerTransitionId.append(-1)
	
	stack.append(currId)
	graphUsed.setProcessing(currId)
	#print("d-setDepth(", currId, ",", depth, ")")
	graphUsed.setDepth(currId, depth)
	
	while not stack.is_empty():
		
		neighborsToExplo.clear()
		# with "true" get only neighbors on the same layer
		neighborsToExplo.append_array(graphUsed.getNotProcNotVisiNeighbors(currId, true))
		
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
				if graphUsed.getDepth(currId) == -1:
					#print("e-setDepth(", currId, ",", depth, ")")
					graphUsed.setDepth(currId, depth)
			
			currId = stack.pop_back()
			graphUsed.setVisited(currId)
			#graphUsed.setDepth(currId, depth)
			depth -= 1
			
			# when all nodes are allready visited (stack empty) and we are 
			# back to the begining, connect the last updated node (means the 
			# last dead end) with the upper layer if exist
			if stack.is_empty() && graphUsed.hasUpNeighbors(deepestId):
				stack.append(graphUsed.getUpNeighbors(deepestId))
				graphUsed.connectNeighbors(deepestId, stack.back())
				graphUsed.setVisited(stack.back())
				currId = stack.back()
				
				depth = graphUsed.getDepth(deepestId)
				depth += 1
				#print("c-setDepth(", currId, ",", depth, ")")
				graphUsed.setDepth(currId, depth)
				deepestId = currId
				currMaxDepth = depth
				
				for i in range(additionnalConnections):
					if secondLayerTransitionId[i] != -1 && secondLayerTransitionId[i] != 0 && graphUsed.hasUpNeighbors(secondLayerTransitionId[i]):
						graphUsed.connectNeighbors(secondLayerTransitionId[i], 
							graphUsed.getUpNeighbors(secondLayerTransitionId[i]))
					secondLayerTransitionId[i] = -1
			continue
		elif deadendReached:
			depth += 1
			deadendReached = false
		
		neighborsToExplo.shuffle()
		
		var newId = neighborsToExplo.pop_front()
		graphUsed.connectNeighbors(currId, newId)
		graphUsed.setProcessing(newId)
		currId = newId
		lastUpdated = newId
		depth += 1
		if graphUsed.getDepth(currId) == -1:
			#print("n-setDepth(", currId, ",", depth, ")")
			graphUsed.setDepth(currId, depth)
		stack.append(currId)

# random number of transition transitions between layers max : graphUsed.size*(1/3)
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
	var maxAdditionnalConnections = int(graphUsed.size * (1/3.) - 1)
	var currentAdditionnalConnection = randi_range(0, maxAdditionnalConnections)
	
	for i in range(maxAdditionnalConnections):
		prevMaxDepth.append(0)
		secondLayerTransitionId.append(-1)
	
	stack.append(currId)
	graphUsed.setProcessing(currId)
	#print("d-setDepth(", currId, ",", depth, ")")
	graphUsed.setDepth(currId, depth)
	
	while not stack.is_empty():
		
		neighborsToExplo.clear()
		# with "true" get only neighbors on the same layer
		neighborsToExplo.append_array(graphUsed.getNotProcNotVisiNeighbors(currId, true))
		
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
				if graphUsed.getDepth(currId) == -1:
					#print("e-setDepth(", currId, ",", depth, ")")
					graphUsed.setDepth(currId, depth)
			
			currId = stack.pop_back()
			graphUsed.setVisited(currId)
			#graphUsed.setDepth(currId, depth)
			depth -= 1
			
			# when all nodes are allready visited (stack empty) and we are 
			# back to the begining, connect the last updated node (means the 
			# last dead end) with the upper layer if exist
			if stack.is_empty() && graphUsed.hasUpNeighbors(deepestId):
				stack.append(graphUsed.getUpNeighbors(deepestId))
				graphUsed.connectNeighbors(deepestId, stack.back())
				graphUsed.setVisited(stack.back())
				currId = stack.back()
				
				depth = graphUsed.getDepth(deepestId)
				depth += 1
				#print("c-setDepth(", currId, ",", depth, ")")
				graphUsed.setDepth(currId, depth)
				deepestId = currId
				currMaxDepth = depth
				
				for i in range(currentAdditionnalConnection):
					if secondLayerTransitionId[i] != -1 && secondLayerTransitionId[i] != 0 && graphUsed.hasUpNeighbors(secondLayerTransitionId[i]):
						graphUsed.connectNeighbors(secondLayerTransitionId[i], 
							graphUsed.getUpNeighbors(secondLayerTransitionId[i]))
					secondLayerTransitionId[i] = -1
				# set random nbr of connection for the next transition layer
				currentAdditionnalConnection = randi_range(0, maxAdditionnalConnections)
			continue
		elif deadendReached:
			depth += 1
			deadendReached = false
		
		neighborsToExplo.shuffle()
		
		var newId = neighborsToExplo.pop_front()
		graphUsed.connectNeighbors(currId, newId)
		graphUsed.setProcessing(newId)
		currId = newId
		lastUpdated = newId
		depth += 1
		if graphUsed.getDepth(currId) == -1:
			#print("n-setDepth(", currId, ",", depth, ")")
			graphUsed.setDepth(currId, depth)
		stack.append(currId)

# BE CAREFULL : this function reset depth and color stored of graphUsed 
# using beginId for the new generation base : 0 by default
func deepensPath_wideWay(beginId: int = 0):
	graphUsed.reset_Depth_Color_Visited()
	
	var neighbors: Array[int]
	var depth: int = 0
	neighbors = graphUsed.getNeighborsConnectionNotVisited(beginId)
	graphUsed.setDepth(beginId, depth)
	graphUsed.setVisited(beginId)
	for i in neighbors:
		graphUsed.setVisited(i)
	
	var neighborsNext: Array[int]
	
	while(!neighbors.is_empty()) :
		neighborsNext = neighbors.duplicate()
		neighbors.clear()
		depth += 1
		while(!neighborsNext.is_empty()) :
			var currentNeighbor:int = neighborsNext.pop_back() # neighbors to proccess
			graphUsed.setDepth(currentNeighbor, depth)
			for i in graphUsed.getNeighborsConnectionNotVisited(currentNeighbor):
				neighbors.append(i)
				graphUsed.setVisited(i)
		
	graphUsed.setColorFromDepth()

func instantiatePyramidConnection(mazeUsed: Dictionary):
	if !newConnectionDebug:
		return
	var depthReached = graphUsed.deepest 
	for id in mazeUsed:
		for i in graphUsed.getNextNeighbors(id):
			# print(id, " ", i, " ", (mazeUsed[i].getCenter() - mazeUsed[id].getCenter()).normalized())
			add_child(
				graphUsed.instantiate_pyramid(
					mazeUsed[id].getCenter(),
					mazeUsed[i].getCenter() - mazeUsed[id].getCenter(),
					graphUsed.computeColor(graphUsed.getDepth(id),depthReached)
				)
			)

func instantiatePyramidConnection_allNeighbors(mazeUsed: Dictionary):
	if !newConnectionDebug:
		return
	var depthReached = graphUsed.deepest 
	for id in mazeUsed:
		for i in graphUsed.getNeighbors(id):
			if i > -1 && graphUsed.isFollowing(id, i):
				add_child(
					graphUsed.instantiate_pyramid(
						mazeUsed[id].getCenter(),
						mazeUsed[i].getCenter() - mazeUsed[id].getCenter(),
						graphUsed.computeColor(graphUsed.getDepth(id),depthReached)
					)
				)

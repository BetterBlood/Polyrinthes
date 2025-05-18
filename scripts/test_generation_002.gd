extends Node3D
const CubeCustom := preload("res://scripts/CubeCustom.gd")
const TruncatedOctahedronCustom := preload("res://scripts/TruncatedOctahedronCustom.gd")
const CubeGraph := preload("res://scripts/cubeGraph.gd")
const wall = preload("res://scenes/wall.tscn") # DEBUG

@export var wall_mat:StandardMaterial3D #= preload("res://materials/wallMaterial.tres")
@export var algo:= GENERATION_ALGORITHME.DFS_3D_ALT_2

@export var coord_first: Marker3D
@export var coord_right: Marker3D
@export var coord_up: Marker3D

const corridor = preload("res://scenes/Test/corridor.tscn") # TEST & DEBUG
const sphere = preload("res://scenes/sphere.tscn") # DEBUG
var cubeGraph: CubeGraph

const TruncatedOctahedron := preload("res://scenes/octaedre_tronque.tscn") # DEBUG

var mazeAll:Dictionary= {} # DEBUG
var maze:Dictionary= {}
var mazeTruncOcta:Dictionary= {} # DEBUG

var size = 3 # default size
# 10.5 : normal spacing for cube rooms
# 21 : spacing to add gap between cube rooms
var gapBetweenRooms_multiplier = 1 # 1 for no gap, other value for DEBUG
var corridor_length = 15.6
@export var room_scale:float = 1.0

# SETUP for 3x3 debug static with corridors and all walls
#var debug_static_3x3 = true
#var corridor_used: bool = true
#var outWallV = CubeCustom.wallValue # -2 = ~ invisible walls (DEBUG), -1 visible walls
#var debug: bool = true
#var newConnectionDebug: bool = true
#var showWall:bool = true # will show walls marked as -1 (wallV or outWallV)
#var triColor:bool = true

# SETUP for 3x3 debug static with corridors, outside walls open
#var debug_static_3x3 = true
#var corridor_used: bool = true
#var outWallV = CubeCustom.outSideWallValue # -2 = ~ invisible walls (DEBUG), -1 visible walls
#var debug: bool = true
#var newConnectionDebug: bool = true
#var showWall:bool = true # will show walls marked as -1 (wallV or outWallV)
#var triColor:bool = true

# SETUP debug without corridors, with all walls
#var debug_static_3x3 = false
#var corridor_used: bool = false
#var outWallV = CubeCustom.wallValue # -2 = ~ invisible walls (DEBUG), -1 visible walls
#var debug: bool = true
#var newConnectionDebug: bool = true
#var showWall:bool = true # will show walls marked as -1 (wallV or outWallV)
#var triColor:bool = true

# SETUP debug without corridors, without exteriors walls
var debug_static_3x3 = false
var corridor_used: bool = false
var outWallV = CubeCustom.outSideWallValue # -2 = ~ invisible walls (DEBUG), -1 visible walls
var debug: bool = true
var newConnectionDebug: bool = true
var showWall:bool = true # will show walls marked as -1 (wallV or outWallV)
var triColor:bool = true

# SETUP debug without corridors, without walls
#var debug_static_3x3 = false
#var corridor_used: bool = false
#var outWallV = CubeCustom.outSideWallValue # -2 = ~ invisible walls (DEBUG), -1 visible walls
#var debug: bool = true
#var newConnectionDebug: bool = true
#var showWall:bool = false # will show walls marked as -1 (wallV or outWallV)
#var triColor:bool = true

# SETUP normal mode
#var debug_static_3x3 = false
#var corridor_used: bool = false
#var outWallV = CubeCustom.wallValue # -2 = ~ invisible walls (DEBUG), -1 visible walls
#var debug: bool = false
#var newConnectionDebug: bool = true
#var showWall:bool = true # will show walls marked as -1 (wallV or outWallV)
#var triColor:bool = true


var wallV = CubeCustom.wallValue # -1 = wall (only -1 !!)
var gapBetweenCubeCenter = (CubeCustom.distFromCenter * 2 + 0.1) * \
		gapBetweenRooms_multiplier
var gapBetweenCubeCenter_with_corridor = gapBetweenCubeCenter + corridor_length
var gapBetweenTruncatedOctahedronCenter = \
		(TruncatedOctahedronCustom.distFromCenter_square*2 + 0.25) * \
		gapBetweenRooms_multiplier

var thread: Thread
signal end_generate()

var rng = RandomNumberGenerator.new()
var seed_human:String
var seed_hashed:int
var characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'

enum GENERATION_ALGORITHME { 
	DFS_3D, 
	DFS_3D_ALT_1, 
	DFS_3D_ALT_2, 
	DFS_LBL, 
	DFS_LBL_ALT_1, 
	DFS_LBL_ALT_2, 
	DFS_LBL_ALT_3, 
	DFS_LBL_ALT_4, 
	DFS_LBL_ALT_5, 
	DFS_LBL_ALT_6 
}

# Called when the node enters the scene tree for the first time.
func _ready(): # (backward, forward, left, right, down, up)
	
	#rng.seed = hash("DEBUG")
	#print(rng.get_seed())
	
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
	if debug_static_3x3:
		var colorBasedOnDepth = true
		cubeGraph = CubeGraph.new(size, wallV, outWallV, 6, colorBasedOnDepth)
		
		if corridor_used:
			gapBetweenCubeCenter = gapBetweenCubeCenter_with_corridor
		else:
			gapBetweenCubeCenter = gapBetweenCubeCenter_with_corridor - corridor_length
		exampleDebugforsize3()
	
	pass

func _process(_delta):
	pass

func generate_seeds(chars:String = characters, length:int = 10) -> void :
	seed_human = ""
	var chars_len = len(chars)
	for i in range(length):
		seed_human += chars[randi()% chars_len]
	
	seed_hashed = hash(seed_human)
	print(seed_human, ": ", seed_hashed)

func generate(sizeP:int, new_seed:String = ""):
	if len(new_seed) == 0:
		generate_seeds()
	else:
		seed_human = new_seed
		seed_hashed = hash(seed_human)
	
	rng.seed = seed_hashed
	
	var colorBasedOnDepth = true
	cubeGraph = CubeGraph.new(sizeP, wallV, outWallV, 6, colorBasedOnDepth, [-1, -1])
	
	# only for normal generation : odd size, middle: cubeGraph.getNbrRoom()/2 
	var beginId = 0
	
	var time_start = Time.get_ticks_msec()
	match algo:
		GENERATION_ALGORITHME.DFS_3D:
			createPath_deepWay(beginId)
			
		GENERATION_ALGORITHME.DFS_3D_ALT_1:
			createPath_deepWay_alt_1(beginId)
			
		GENERATION_ALGORITHME.DFS_3D_ALT_2:
			createPath_deepWay_alt_2(beginId)
			
		GENERATION_ALGORITHME.DFS_LBL:
			createPath_deepWay_layer_by_layer(beginId)
			
		GENERATION_ALGORITHME.DFS_LBL_ALT_1:
			createPath_deepWay_layer_by_layer_alt_1(beginId)
			
		GENERATION_ALGORITHME.DFS_LBL_ALT_2:
			createPath_deepWay_layer_by_layer_alt_2(beginId)
			
		GENERATION_ALGORITHME.DFS_LBL_ALT_3:
			createPath_deepWay_layer_by_layer_alt_3(beginId)
			
		GENERATION_ALGORITHME.DFS_LBL_ALT_4:
			createPath_deepWay_layer_by_layer_alt_4(beginId)
			
		GENERATION_ALGORITHME.DFS_LBL_ALT_5:
			createPath_deepWay_layer_by_layer_alt_5(beginId)
			
		GENERATION_ALGORITHME.DFS_LBL_ALT_6:
			createPath_deepWay_layer_by_layer_alt_6(beginId)
			
		_:
			push_warning("gen_algo provided not matched: please have a look at GENERATION_ALGORITHME enum")
			createPath_deepWay_layer_by_layer_alt_6(beginId)
	var time_end = Time.get_ticks_msec()
	
	print("createPath in " + str((time_end - time_start)/1000) + "s " + \
		str((time_end - time_start)%1000) + "ms.")
	
	time_start = Time.get_ticks_msec()
	deepensPath_wideWay(beginId) # recompute connections from given id, by depth
	time_end = Time.get_ticks_msec()
	
	print("deepensPath in " + str((time_end - time_start)/1000) + "s " + \
		str((time_end - time_start)%1000) + "ms.")
	
	print("cubeGraph.getNbrRoom(): ", cubeGraph.getNbrRoom(), ", depth: ", cubeGraph.get_deepest())
	
	if colorBasedOnDepth:
		cubeGraph.setColorFromDepth()
	
	display()

func get_rotation_from_basis(src_basis: Basis, dst_basis: Basis) -> Vector3:
	src_basis.orthonormalized()
	dst_basis.orthonormalized()
	var rel = dst_basis * src_basis.transposed()
	return rel.get_euler()

func display() -> void:
	# on the corner: right: (1, 0.707, 0.707), up: (-1, 0.707, 0.707)
	var defaul_start_pos:Vector3 = coord_first.position
	var curr_pos:Vector3 = defaul_start_pos
	var right_gap:Vector3 = (coord_right.position - coord_first.position).normalized() * gapBetweenCubeCenter * room_scale
	var up_gap:Vector3 = (coord_up.position - coord_first.position).normalized() * gapBetweenCubeCenter * room_scale
	
	var depth_gap = up_gap.cross(right_gap).normalized() * gapBetweenCubeCenter * room_scale
	
	if right_gap.dot(up_gap) > 0.001:
		push_warning("Please be carefull, marker should be orthogonals, ", right_gap.dot(up_gap), " 
			for this generation: they are replaced with (1,0,0) for right and (0,1,0) for up")
		right_gap = Vector3(1,0,0) * gapBetweenCubeCenter * room_scale
		up_gap = Vector3(0,1,0) * gapBetweenCubeCenter * room_scale
	elif right_gap.dot(up_gap) != 0:
		print("DEBUG: approximation, manually fixed ! ", right_gap.dot(up_gap), " is close to 0")
		up_gap = right_gap.cross(depth_gap).normalized() * gapBetweenCubeCenter * room_scale
	
	var up_nbr = 0
	var depth_nbr = 0
	
	var source = Basis(Vector3.RIGHT, Vector3.UP, Vector3.FORWARD)
	var target = Basis(
		right_gap.normalized(),
		up_gap.normalized(),
		depth_gap.normalized()
	)
	
	var euler = get_rotation_from_basis(source, target)
	
	var time_start
	var time_end
	
	var sizeBase = cubeGraph.size
	var sizeFace = cubeGraph.getNbrRoomOnASide()
	var sizeTotal = cubeGraph.getNbrRoom()
	
	var depthReached = cubeGraph.get_deepest()
	
	if debug:
		time_start = Time.get_ticks_msec()
		for i in range(sizeTotal):
			#if i%cubeGraph.size == cubeGraph.size - 1: print((100*i)/cubeGraph.getNbrRoom(), "%")
			#print(xCoord, " ", yCoord, " ", zCoord)
			#print(cubeGraph.getNeighbors(i))
			var cube = CubeCustom.new(
				curr_pos, 
				cubeGraph.getNeighbors(i),
				cubeGraph.getColor(i), 
				depthReached,
				debug,
				showWall,
				triColor,
				wall_mat,
				room_scale
			)
			
			cube.rotation = euler
			
			add_child(cube)
			mazeAll[i] = cube
			
			#xCoord += gapBetweenCubeCenter
			curr_pos += right_gap
			
			if i%(sizeBase) == sizeBase - 1:
				up_nbr += 1
				curr_pos = defaul_start_pos + up_gap * up_nbr + depth_gap * depth_nbr
			
			if i%(sizeFace) == (sizeFace) - 1:
				up_nbr = 0
				depth_nbr += 1
				curr_pos = defaul_start_pos + up_gap * up_nbr + depth_gap * depth_nbr
		
		time_end = Time.get_ticks_msec()
		print("Display with all neighbors: 100% in " + str((time_end - time_start)/1000) + "s " + \
			str((time_end - time_start)%1000) + "ms.")
		
		time_start = Time.get_ticks_msec()
		instantiatePyramidConnection_allNeighbors(mazeAll)
		time_end = Time.get_ticks_msec()
		print("instantiatePyramid in " + str((time_end - time_start)/1000) + "s " + \
			str((time_end - time_start)%1000) + "ms.")
			
		# reset to new location :
		defaul_start_pos = coord_first.position + right_gap * (sizeBase + 1)
		curr_pos = defaul_start_pos
		up_nbr = 0
		depth_nbr = 0
	
	# DEBUG: for size > 2: update depth using tag_spread from room 24
	#tag_spreads_wide_way(24, 0, 4, [0, depthReached*1/4, depthReached*2/4, depthReached*3/4, depthReached])
	# update second tag:
	#tag_spreads_wide_way(24, 1, 4, [0, depthReached*1/4, depthReached*2/4, depthReached*3/4, depthReached])
	
	time_start = Time.get_ticks_msec()
	for i in range(sizeTotal):
		#if i%sizeBase == sizeBase - 1: print((100*i)/sizeTotal, "%")
		#print(xCoord, " ", yCoord, " ", zCoord)
		#print(cubeGraph.getNeighbors(i))
		
		var cube = CubeCustom.new(
			curr_pos, 
			cubeGraph.getNeighborsConnection(i), 
			cubeGraph.getColor(i), 
			depthReached,
			debug,
			showWall,
			triColor,
			wall_mat,
			room_scale
		)
		
		cube.rotation = euler
		
		add_child(cube)
		maze[i] = cube
		
		curr_pos += right_gap
		
		if i%(sizeBase) == sizeBase - 1:
			up_nbr += 1
			curr_pos = defaul_start_pos + up_gap * up_nbr + depth_gap * depth_nbr
		
		if i%(sizeFace) == (sizeFace) - 1:
			up_nbr = 0
			depth_nbr += 1
			curr_pos = defaul_start_pos + up_gap * up_nbr + depth_gap * depth_nbr
		
		# TODO : WIP, find a way to continue moving while rendering graph
		# this following line slow down the render but regenerate (while generating)
		# could send errors (try to delete not existing node)
		# await get_tree().create_timer(0.001).timeout 
		
	time_end = Time.get_ticks_msec()
#	print(cubeGraph.colorsIds)
#	print(cubeGraph.depths)
	print("100% cube in " + str((time_end - time_start)/1000) + "s "+ \
		str((time_end - time_start)%1000) + "ms.")
	
	if debug:
		time_start = Time.get_ticks_msec()
		instantiatePyramidConnection(maze)
		time_end = Time.get_ticks_msec()
		print("instantiatePyramid in " + str((time_end - time_start)/1000) + "s "+ \
			str((time_end - time_start)%1000) + "ms.\n")
	
	# truncated octahedron: TODO: need to upgrade to vect instead of coords
#	var xCoordBase = -(gapBetweenCubeCenter * (sizeBase / 2))
#	var yCoordBase = 0
#	var zCoordBase = -50
#	var xCoord = xCoordBase
#	var yCoord = yCoordBase
#	var zCoord = zCoordBase
#	# reset to new location (for truncated octahedron):
#	xCoordBase = xCoordBase + gapBetweenCubeCenter * sizeBase + gapBetweenTruncatedOctahedronCenter
#	xCoord = xCoordBase
#	yCoord = yCoordBase
#	zCoord = zCoordBase
#
#	time_start = Time.get_ticks_msec()
#	for i in range(sizeTotal): # TODO : truncatedOctahedronGraph (to file empty spaces with usable rooms)
#		var truncatedOctahedron = TruncatedOctahedronCustom.new(
#			Vector3(xCoord,yCoord,zCoord), 
#			cubeGraph.getNeighborsConnection(i), 
#			cubeGraph.getColor(i), 
#			depthReached,
#			debug,
#			showWall,
#			triColor
#		)
#
#		add_child(truncatedOctahedron)
#		mazeTruncOcta[i] = truncatedOctahedron
#
#		xCoord += gapBetweenTruncatedOctahedronCenter
#
#		if i%(sizeBase) == sizeBase - 1:
#			xCoord = xCoordBase
#			yCoord += gapBetweenTruncatedOctahedronCenter
#
#		if i%(sizeFace) == (sizeFace) - 1:
#			yCoord = yCoordBase
#			zCoord -= gapBetweenTruncatedOctahedronCenter
#
#	time_end = Time.get_ticks_msec()
#	print("100% truncated octahedron in " + \
#		str((time_end - time_start)/1000) + "s "+ str((time_end - time_start)%1000) + "ms.")
#
#	if debug:
#		time_start = Time.get_ticks_msec()
#		instantiatePyramidConnection(mazeTruncOcta)
#		time_end = Time.get_ticks_msec()
#		print("instantiatePyramid in " + str((time_end - time_start)/1000) + "s "+ \
#			str((time_end - time_start)%1000) + "ms.\n\n")

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
		
		var sphereStart = sphere.instantiate()
		sphereStart.get_child(0).mesh.material.albedo_color = Color(1, 1, 1, 1)
		sphereStart.set_position(
			Vector3(0 + xCoord, 0 + yCoord, gapBetweenCubeCenter*-2 + zCoord)
		)
		add_child(sphereStart)
		
		deepensPath_wideWay(18)
		cubeGraph.setColorFromDepth()
		
		var depthReached = cubeGraph.get_deepest()
		
		for i in range(cubeGraph.getNbrRoom()):
			var cube = CubeCustom.new(
				Vector3(xCoord,yCoord,zCoord), 
				cubeGraph.getNeighborsConnection(i),
				cubeGraph.getColor(i), 
				depthReached,
				false,
				true,
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
		if corridor_used:
			instantiate_corridors(maze)
		
		
		var sphereEnd = sphere.instantiate()
		sphereEnd.get_child(0).mesh.material.albedo_color = Color(0, 0, 0, 1)
		sphereEnd.set_position(
			Vector3(
				gapBetweenCubeCenter + xCoord, 
				gapBetweenCubeCenter*2 + yCoord, 
				gapBetweenCubeCenter*2 + zCoord
			)
		)
		add_child(sphereEnd)

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
		
		var newId = neighborsToExplo.pop_at(rng.randi() % neighborsToExplo.size())
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
		
		newId = neighborsToExplo.pop_at(rng.randi() % neighborsToExplo.size())
		cubeGraph.connectNeighbors(currId, newId)
		cubeGraph.setVisited(newId)
		var prevId = currId
		currId = newId
		i += 1
		
		if i >= cubeGraph.getNbrRoomOnASide() && not neighborsToExplo.is_empty():
			#print("alt Way ?")
			stack.append(currId)
			
			newId = neighborsToExplo.pop_at(rng.randi() % neighborsToExplo.size())
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
			currId = stack.pop_at(rng.randi() % stack.size())
			continue
		
		stack.append(currId)
		
		var newId = neighborsToExplo.pop_at(rng.randi() % neighborsToExplo.size())
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
		
		var newId = neighborsToExplo.pop_at(rng.randi() % neighborsToExplo.size())
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
		
		var newId = neighborsToExplo.pop_at(rng.randi() % neighborsToExplo.size())
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
		
		var newId = neighborsToExplo.pop_at(rng.randi() % neighborsToExplo.size())
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
		
		var newId = neighborsToExplo.pop_at(rng.randi() % neighborsToExplo.size())
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
		
		var newId = neighborsToExplo.pop_at(rng.randi() % neighborsToExplo.size())
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
	var currentAdditionalConnection = rng.randi_range(0, maxAdditionalConnections)
	
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
				currentAdditionalConnection = rng.randi_range(0, maxAdditionalConnections)
			continue
		
		var newId = neighborsToExplo.pop_at(rng.randi() % neighborsToExplo.size())
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
	var currentAdditionalConnection = rng.randi_range(0, maxAdditionalConnections)
	
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
			
			currId = stack.pop_at(rng.randi() % stack.size())
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
						#print("connect: ", secondLayerTransitionId[i], " and: ", cubeGraph.getUpNeighbors(secondLayerTransitionId[i]))
					else:
						secondLayerTransitionId[i] = -1
				#print(currentAdditionalConnection, " ", lastDeepestId, " ", lastSecondId)
				for i in range(currentAdditionalConnection):
					lastSecondId[i] = cubeGraph.getUpNeighbors(secondLayerTransitionId[i])
				lastDeepestId = deepestId
				# set random nbr of connection for the next transition layer
				currentAdditionalConnection = rng.randi_range(0, maxAdditionalConnections)
				#print(currentAdditionalConnection, " ", lastDeepestId, " ", lastSecondId)
			continue
		
		var newId = neighborsToExplo.pop_at(rng.randi() % neighborsToExplo.size())
		cubeGraph.connectNeighbors(currId, newId)
		cubeGraph.setVisited(newId)
		currId = newId
		cubeGraph.setDepth(currId, depth + 1)
		stack.append(currId)


# BE CAREFUL : this function reset depth and color stored of cubeGraph 
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
		while(!neighborsNext.is_empty()):
			var currentNeighbor:int = neighborsNext.pop_back() # neighbors to process
			cubeGraph.setDepth(currentNeighbor, depth)
			for i in cubeGraph.getNeighborsConnectionNotVisited(currentNeighbor):
				neighbors.append(i)
				cubeGraph.setVisited(i)
	
	cubeGraph.setColorFromDepth()

func clean_tag_wide_way(begin_id: int = 0, tag_id: int = 0, max_depth: int = 5, default_tag_value:int = -1) -> void:
	cubeGraph.resetVisited()
	
	var neighbors: Array[int]
	var depth: int = 0
	neighbors = cubeGraph.getNeighborsConnectionNotVisited(begin_id)
	cubeGraph.set_tag(begin_id, tag_id, default_tag_value)
	cubeGraph.setVisited(begin_id)
	for i in neighbors:
		cubeGraph.setVisited(i)
	
	var neighborsNext: Array[int]
	
	while(!neighbors.is_empty() && depth < max_depth):
		neighborsNext = neighbors.duplicate()
		neighbors.clear()
		depth += 1
		
		while(!neighborsNext.is_empty()):
			var currentNeighbor:int = neighborsNext.pop_back()
			cubeGraph.set_tag(currentNeighbor, tag_id, default_tag_value)
			for i in cubeGraph.getNeighborsConnectionNotVisited(currentNeighbor):
				neighbors.append(i)
				cubeGraph.setVisited(i)

func tag_spreads_wide_way(begin_id:int, tag_id:int, max_depth:int, values:Array) -> void:
	if not cubeGraph.isInRange(begin_id):
		push_error("begin_id out of range, aborted ! For current graph, should be lower than:", cubeGraph.getNbrRoom())
		return
	if not cubeGraph.isTagInRange(tag_id):
		push_error("tag_id not in tags, aborted ! For current graph, should be lower than:", cubeGraph.get_nbr_tag())
		return
	if max_depth < 1:
		push_error("max_depth cannot be less or equal to 0, aborted !")
		return
	
	if len(values) - 1 < max_depth:
		push_warning("Too fiew values for max_depth: ", max_depth, ", len of values should be: ", 
		max_depth + 1, ", actually is: ", len(values), "! Values sets to [0..", max_depth, "].")
		values.clear()
		values = range(max_depth + 1)
	
	cubeGraph.resetVisited()
	
	var neighbors: Array[int]
	var depth: int = 0
	neighbors = cubeGraph.getNeighborsConnectionNotVisited(begin_id)
	cubeGraph.set_tag(begin_id, tag_id, values[depth])
	cubeGraph.setVisited(begin_id)
	for i in neighbors:
		cubeGraph.setVisited(i)
	
	var neighborsNext: Array[int]
	
	while(!neighbors.is_empty() && depth < max_depth):
		neighborsNext = neighbors.duplicate()
		neighbors.clear()
		depth += 1
		
		while(!neighborsNext.is_empty()):
			var currentNeighbor:int = neighborsNext.pop_back()
			cubeGraph.set_tag(currentNeighbor, tag_id, values[depth])
			for i in cubeGraph.getNeighborsConnectionNotVisited(currentNeighbor):
				neighbors.append(i)
				cubeGraph.setVisited(i)

func instantiatePyramidConnection(mazeUsed: Dictionary):
	if !newConnectionDebug:
		return
	var depthReached = cubeGraph.get_deepest()
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

func instantiate_corridors(mazeUsed: Dictionary):
	if !newConnectionDebug:
		return
	for id in mazeUsed:
		for i in cubeGraph.getNextNeighbors(id):
			instantiate_corridor(
				mazeUsed[id].getCenter(),
				get_rotation_for_positions(mazeUsed[id].getCenter(), mazeUsed[i].getCenter())
			)

func get_rotation_for_positions(from: Vector3, to: Vector3) -> Vector3:
	var direction := to - from
	var epsilon = 0.001
	
	if direction.x > epsilon:
		return Vector3()
	if direction.x < -epsilon:
		return Vector3(0, PI, 0)
	
	if direction.y > epsilon:
		return Vector3(0, 0, PI/2)
	if direction.y < -epsilon:
		return Vector3(0, 0, -PI/2)
	
	if direction.z > epsilon:
		return Vector3(0, -PI/2, 0)
	if direction.z < -epsilon:
		return Vector3(0, PI/2, 0)
	
	return Vector3()

func instantiate_corridor(center_pos: Vector3, rot: Vector3):
	var connectionTmp = corridor.instantiate()
	
	connectionTmp.set_position(center_pos)
	connectionTmp.set_rotation(rot)
	
	add_child(connectionTmp)

func instantiatePyramidConnection_allNeighbors(mazeUsed: Dictionary):
	if !newConnectionDebug:
		return
	var depthReached = cubeGraph.get_deepest()
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

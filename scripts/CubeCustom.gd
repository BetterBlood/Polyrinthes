extends Node
class_name CubeCustom
var connection = preload("res://scenes/connection.tscn")
var wall = preload("res://scenes/wall.tscn")
var sphere = preload("res://scenes/sphere.tscn")
var distFromCenter = 5.2 
var rotationAngle = PI/2
var wallValue = -1
var outSideWallValue = -2

var _debug:bool
var _showWall:bool
var _triColor:bool

var _pyramid:bool = false

func _init(center_pos: Vector3, arr: Array[int], depth: float, deepest: float,
			debug: bool = false, showWall: bool = true, triColor: bool = true):
	
	_debug = debug
	_showWall = showWall
	_triColor = triColor
	#call_deferred("instantiate_cube", center_pos, arr, depth, deepest)
	instantiate_cube(center_pos, arr, depth, deepest)
	if _debug:
		if depth == 0:
			var sphereStart = sphere.instantiate()
			sphereStart.get_child(0).mesh.material.albedo_color = Color(1, 1, 1, 1)
			sphereStart.set_position(center_pos)
			add_child(sphereStart)
		elif depth == deepest:
			var sphereEnd = sphere.instantiate()
			sphereEnd.get_child(0).mesh.material.albedo_color = Color(0, 0, 0, 1)
			sphereEnd.set_position(center_pos)
			add_child(sphereEnd)

func instantiate_cube(center_pos: Vector3, arr: Array[int], depth: float, size: float):
	var ratio = (depth/(size-1.))
	var redRatio = 0
	var greenRatio = 0
	var blueRatio = 0
	
	if depth < size/2. :
		redRatio = 1 - (depth/((size-1)/2.))
		greenRatio = (depth/((size-1)/2.))/2
		blueRatio = 0
		#print(depth, " ", redRatio)
	else :
		redRatio = 0
		greenRatio = 1 - (depth/((size-1)/2.))/2
		blueRatio = 1 - (2 - (depth/((size-1)/2.)))
		#print(depth, " ", greenRatio, " ", blueRatio)
	
	var color = Vector3(1 - ratio, 0, ratio).normalized()
	
	if _triColor:
		color = Vector3(redRatio, greenRatio, blueRatio).normalized()
	
	#print(depth/size, " ", 1 - ratio, " ", ratio)
	# (backward, forward, left, right, down, up)
	if (arr[0] == wallValue):
		if _showWall:
			instanciate_wall(center_pos, Vector3(0,0,distFromCenter), Vector3(-2*rotationAngle,0,0))
	elif _debug && arr[0] != outSideWallValue:
		if not _pyramid:
			instantiate_connection(center_pos, Vector3(-2*rotationAngle,0,0), color)
		else :
			instantiate_pyramid(center_pos, Vector3(0,-2*rotationAngle,0), color)
	if (arr[1] == wallValue):
		if _showWall:
			instanciate_wall(center_pos, Vector3(0,0,-distFromCenter), Vector3(0,0,0))
	elif _debug && arr[1] != outSideWallValue:
		if not _pyramid:
			instantiate_connection(center_pos, Vector3(0,0,0), color)
		else :
			instantiate_pyramid(center_pos, Vector3(0,0,0), color)
	
	if (arr[2] == wallValue):
		if _showWall:
			instanciate_wall(center_pos, Vector3(-distFromCenter,0,0), Vector3(0,rotationAngle,0))
	elif _debug && arr[2] != outSideWallValue:
		if not _pyramid:
			instantiate_connection(center_pos, Vector3(0,rotationAngle,0), color)
		else :
			instantiate_pyramid(center_pos, Vector3(0,rotationAngle,0), color)
	if (arr[3] == wallValue):
		if _showWall:
			instanciate_wall(center_pos, Vector3(distFromCenter,0,0), Vector3(0,-rotationAngle,0))
	elif _debug && arr[3] != outSideWallValue:
		if not _pyramid:
			instantiate_connection(center_pos, Vector3(0,-rotationAngle,0),color)
		else :
			instantiate_pyramid(center_pos, Vector3(0,-rotationAngle,0), color)
	
	if (arr[4] == wallValue):
		if _showWall:
			instanciate_wall(center_pos, Vector3(0,-distFromCenter,0), Vector3(rotationAngle,0,0))
	elif _debug && arr[4] != outSideWallValue:
		if not _pyramid:
			instantiate_connection(center_pos, Vector3(-rotationAngle,0,0), color)
		else :
			instantiate_pyramid(center_pos, Vector3(0,0,-rotationAngle), color) # (._. )
	if (arr[5] == wallValue):
		if _showWall:
			instanciate_wall(center_pos, Vector3(0,distFromCenter,0), Vector3(-rotationAngle,0,0))
	elif _debug && arr[5] != outSideWallValue:
		if not _pyramid:
			instantiate_connection(center_pos, Vector3(rotationAngle,0,0), color)
		else :
			instantiate_pyramid(center_pos, Vector3(0,0,rotationAngle), color) # (._o )

func instanciate_wall(center_pos: Vector3, pos: Vector3, rot: Vector3):
	var wallTmp = wall.instantiate()
	
	wallTmp.set_position(center_pos + pos)
	wallTmp.set_rotation(rot)
	
	#call_deferred("add_child", wallTmp)
	add_child(wallTmp)

func instantiate_connection(center_pos: Vector3, rot: Vector3, color: Vector3):
	var connectionTmp = connection.instantiate()
	
	connectionTmp.get_child(0).mesh.material.albedo_color = Color(color.x, color.y, color.z, 1)
	connectionTmp.set_position(center_pos)
	connectionTmp.set_rotation(rot)
	
	#call_deferred("add_child", connectionTmp)
	add_child(connectionTmp)

func instantiate_pyramid(center_pos: Vector3, rot: Vector3, color: Vector3):
	var distance: int = distFromCenter
	var base_distFromCenter: int = 1
	var vertices = PackedVector3Array()
	# 4 faces :
	vertices.push_back(Vector3(0, base_distFromCenter, base_distFromCenter))
	vertices.push_back(Vector3(distance, 0, 0))
	vertices.push_back(Vector3(0, -base_distFromCenter, base_distFromCenter))
	
	vertices.push_back(Vector3(0, -base_distFromCenter, base_distFromCenter))
	vertices.push_back(Vector3(distance, 0, 0))
	vertices.push_back(Vector3(0, -base_distFromCenter, -base_distFromCenter))

	vertices.push_back(Vector3(0, -base_distFromCenter, -base_distFromCenter))
	vertices.push_back(Vector3(distance, 0, 0))
	vertices.push_back(Vector3(0, base_distFromCenter, -base_distFromCenter))

	vertices.push_back(Vector3(0, base_distFromCenter, -base_distFromCenter))
	vertices.push_back(Vector3(distance, 0, 0))
	vertices.push_back(Vector3(0, base_distFromCenter, base_distFromCenter))
	
	# base (square (triangle x 2)):
	vertices.push_back(Vector3(0, base_distFromCenter, base_distFromCenter))
	vertices.push_back(Vector3(0, -base_distFromCenter, base_distFromCenter))
	vertices.push_back(Vector3(0, -base_distFromCenter, -base_distFromCenter))
	
	vertices.push_back(Vector3(0, -base_distFromCenter, -base_distFromCenter))
	vertices.push_back(Vector3(0, base_distFromCenter, -base_distFromCenter))
	vertices.push_back(Vector3(0, base_distFromCenter, base_distFromCenter))
	
	
	# Initialize the ArrayMesh.
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	
	# Create the Mesh.
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	var m = MeshInstance3D.new()
	m.mesh = arr_mesh
	
	m.rotate_z(rot.z) # rotation on z cause we rotate on y for 90° so we can't do a rotation on x
	m.rotate_y(rot.y + PI/2) # ( °-°) <(the order is important)
	
	m.position = center_pos
	
	var newMaterial = StandardMaterial3D.new()
	newMaterial.albedo_color = Color(color.x, color.y, color.z, 1)
	m.material_override = newMaterial
	
	add_child(m)

func clean():
	for i in self.get_children():
		self.remove_child(i)
		i.queue_free()

func _exit_tree():
	self.queue_free()
	

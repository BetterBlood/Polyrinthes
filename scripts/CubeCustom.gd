extends Node3D

class_name CubeCustom

const connection = preload("res://scenes/connection.tscn") # depreciated
const wall = preload("res://scenes/wall.tscn") # depreciated

const wall_white = preload("res://scenes/wall_white.tscn")
var wall_material: StandardMaterial3D

const sphere = preload("res://scenes/sphere.tscn")
const distFromCenter: float = 5.2 
const rotationAngle: float = PI/2
const wallValue: int = -1
const outSideWallValue: int = -2
var spec_scale: float

var _debug: bool
var _showWall: bool
var _triColor: bool

const _connection: bool = false
const _pyramid: bool = false

var _center: Vector3 = Vector3()

func _init(center_pos: Vector3, arr: Array[int], depth: float, deepest: float,
			debug: bool = false, showWall: bool = true, triColor: bool = true,
			new_wall_material: StandardMaterial3D = null, new_scale: float = 1.0):
	
	position = center_pos
	
	_center = center_pos
	_debug = debug
	_showWall = showWall
	_triColor = triColor
	
	if new_wall_material != null:
		wall_material = new_wall_material
	spec_scale = new_scale
	
	#call_deferred("instantiate_cube", center_pos, arr, depth, deepest)
	instantiate_cube(arr, depth, deepest)
	if _debug:
		if depth == 0:
			var sphereStart = sphere.instantiate()
			sphereStart.get_child(0).mesh.material.albedo_color = Color(1, 1, 1, 1)
			add_child(sphereStart)
		elif depth == deepest:
			var sphereEnd = sphere.instantiate()
			sphereEnd.get_child(0).mesh.material.albedo_color = Color(0, 0, 0, 1)
			add_child(sphereEnd)

func computeColor(depth: float, size: float, triColor: bool = true) -> Vector3:
	if not triColor:
		var ratio = (depth/(size-1.))
		return Vector3(1 - ratio, 0, ratio).normalized()
		
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
	
	#print(depth/size, " ", 1 - ratio, " ", ratio)
	return Vector3(redRatio, greenRatio, blueRatio).normalized()

func instantiate_cube(arr: Array[int], depth: float, size: float):
	var color = computeColor(depth, size)
	# (backward, forward, left, right, down, up)
	if (arr[0] == wallValue):
		if _showWall:
			instatiate_wall_free(Vector3(0,0,distFromCenter*spec_scale), Vector3(-2*rotationAngle,0,0))
	elif _debug && arr[0] != outSideWallValue:
		if _connection:
			instantiate_connection(Vector3(-2*rotationAngle,0,0), color)
		elif _pyramid:
			instantiate_pyramid(Vector3(0,-2*rotationAngle,0), color)
	if (arr[1] == wallValue):
		if _showWall:
			instatiate_wall_free(Vector3(0,0,-distFromCenter*spec_scale), Vector3(0,0,0))
	elif _debug && arr[1] != outSideWallValue:
		if _connection:
			instantiate_connection(Vector3(0,0,0), color)
		elif _pyramid:
			instantiate_pyramid(Vector3(0,0,0), color)
	
	if (arr[2] == wallValue):
		if _showWall:
			instatiate_wall_free(Vector3(-distFromCenter*spec_scale,0,0), Vector3(0,rotationAngle,0))
	elif _debug && arr[2] != outSideWallValue:
		if _connection:
			instantiate_connection(Vector3(0,rotationAngle,0), color)
		elif _pyramid:
			instantiate_pyramid( Vector3(0,rotationAngle,0), color)
	if (arr[3] == wallValue):
		if _showWall:
			instatiate_wall_free(Vector3(distFromCenter*spec_scale,0,0), Vector3(0,-rotationAngle,0))
	elif _debug && arr[3] != outSideWallValue:
		if _connection:
			instantiate_connection(Vector3(0,-rotationAngle,0),color)
		elif _pyramid:
			instantiate_pyramid(Vector3(0,-rotationAngle,0), color)
	
	if (arr[4] == wallValue):
		if _showWall:
			instatiate_wall_free(Vector3(0,-distFromCenter*spec_scale,0), Vector3(rotationAngle,0,0))
	elif _debug && arr[4] != outSideWallValue:
		if _connection:
			instantiate_connection(Vector3(-rotationAngle,0,0), color)
		elif _pyramid:
			instantiate_pyramid(Vector3(0,0,-rotationAngle), color) # (._. )
	if (arr[5] == wallValue):
		if _showWall:
			instatiate_wall_free(Vector3(0,distFromCenter*spec_scale,0), Vector3(-rotationAngle,0,0))
	elif _debug && arr[5] != outSideWallValue:
		if _connection:
			instantiate_connection(Vector3(rotationAngle,0,0), color)
		elif _pyramid:
			instantiate_pyramid(Vector3(0,0,rotationAngle), color) # (._o )

func instantiate_wall(pos: Vector3, rot: Vector3): # depreciated
	var wallTmp = wall.instantiate()
	
	wallTmp.set_position(pos)
	wallTmp.set_rotation(rot)
	
	#call_deferred("add_child", wallTmp)
	add_child(wallTmp)


func instatiate_wall_free(pos: Vector3, rot: Vector3) -> void:
	var wallTmp = wall_white.instantiate()
	
	wallTmp.set_position(pos)
	wallTmp.set_rotation(rot)
	wallTmp.scale = Vector3(spec_scale, spec_scale, spec_scale)
	
	var mesh = wallTmp.get_children()[0] as MeshInstance3D;
	mesh.material_override = wall_material
	
	add_child(wallTmp)


func instantiate_connection(rot: Vector3, color: Vector3):
	var connectionTmp = connection.instantiate()
	
	connectionTmp.get_child(0).mesh.material.albedo_color = Color(color.x, color.y, color.z, 1)
	connectionTmp.set_rotation(rot)
	
	#call_deferred("add_child", connectionTmp)
	add_child(connectionTmp)

func instantiate_pyramid(rot: Vector3, color: Vector3):
	var distance: float = distFromCenter*spec_scale
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
	
	m.position = Vector3()
	
	var newMaterial = StandardMaterial3D.new()
	newMaterial.albedo_color = Color(color.x, color.y, color.z, 1)
	m.material_override = newMaterial
	
	add_child(m)

func getCenter():
	return _center

func clean():
	for i in self.get_children():
		self.remove_child(i)
		i.queue_free()

func _exit_tree():
	self.queue_free()
	

extends Node
class_name CubeCustom
var connection = preload("res://scenes/connection.tscn")
var wall = preload("res://scenes/wall.tscn")
var sphere = preload("res://scenes/sphere.tscn")
var distFromCenter = 5.2 
var rotationAngle = PI/2
var wallValue = -1
var outSideWallValue = -2

var debug = true
var showWall = false
var triColor = true

func _init(center_pos: Vector3, arr: Array[int], deep: float, size: float):
	#call_deferred("instantiate_cube", center_pos, arr, deep, size)
	instantiate_cube(center_pos, arr, deep, size)
	if debug:
		if deep == 0:
			var sphereStart = sphere.instantiate()
			sphereStart.get_child(0).mesh.material.albedo_color = Color(1, 1, 1, 1)
			sphereStart.set_position(center_pos)
			add_child(sphereStart)
		elif deep == size:
			var sphereEnd = sphere.instantiate()
			sphereEnd.get_child(0).mesh.material.albedo_color = Color(0, 0, 0, 1)
			sphereEnd.set_position(center_pos)
			add_child(sphereEnd)

func instantiate_cube(center_pos: Vector3, arr: Array[int], deep: float, size: float):
	var ratio = (deep/(size-1)) * 255.
	
	var redRatio = 0
	var greenRatio = 0
	var blueRatio = 0
	
	if deep < size/2. :
		redRatio = 1 - (deep/((size-1)/2.))
		greenRatio = (deep/((size-1)/2.))/2
		blueRatio = 0
		#print(deep, " ", redRatio)
	else :
		redRatio = 0
		greenRatio = 1 - (deep/((size-1)/2.))/2
		blueRatio = 1 - (2 - (deep/((size-1)/2.)))
		#print(deep, " ", greenRatio, " ", blueRatio)
	
	var color = Vector3(255 - ratio, 0, ratio).normalized()
	
	if triColor:
		color = Vector3(redRatio, greenRatio, blueRatio).normalized()
	
	#print(deep/size, " ", 255 - ratio, " ", ratio)
	# (backward, forward, left, right, down, up)
	if (arr[0] == wallValue):
		if showWall:
			instanciate_wall(center_pos, Vector3(0,0,distFromCenter), Vector3(-PI,0,0))
	elif debug && arr[0] != outSideWallValue:
		instantiate_connection(center_pos, Vector3(-PI,0,0), color)
	if (arr[1] == wallValue):
		if showWall:
			instanciate_wall(center_pos, Vector3(0,0,-distFromCenter), Vector3(0,0,0))
	elif debug && arr[1] != outSideWallValue:
		instantiate_connection(center_pos, Vector3(0,0,0), color)
	
	if (arr[2] == wallValue):
		if showWall:
			instanciate_wall(center_pos, Vector3(-distFromCenter,0,0), Vector3(0,rotationAngle,0))
	elif debug && arr[2] != outSideWallValue:
		instantiate_connection(center_pos, Vector3(0,rotationAngle,0), color)
	if (arr[3] == wallValue):
		if showWall:
			instanciate_wall(center_pos, Vector3(distFromCenter,0,0), Vector3(0,-rotationAngle,0))
	elif debug && arr[3] != outSideWallValue:
		instantiate_connection(center_pos, Vector3(0,-rotationAngle,0),color)
	
	if (arr[4] == wallValue):
		if showWall:
			instanciate_wall(center_pos, Vector3(0,-distFromCenter,0), Vector3(rotationAngle,0,0))
	elif debug && arr[4] != outSideWallValue:
		instantiate_connection(center_pos, Vector3(-rotationAngle,0,0), color)
	if (arr[5] == wallValue):
		if showWall:
			instanciate_wall(center_pos, Vector3(0,distFromCenter,0), Vector3(-rotationAngle,0,0))
	elif debug && arr[5] != outSideWallValue:
		instantiate_connection(center_pos, Vector3(rotationAngle,0,0), color)

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

func clean():
	for i in self.get_children():
		self.remove_child(i)
		i.queue_free()

func _exit_tree():
	self.queue_free()
	

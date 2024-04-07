extends Node
class_name CubeCustom
var connection = preload("res://scenes/connection.tscn")
var wall = preload("res://scenes/wall.tscn")
var distFromCenter = 5.2 
var rotationAngle = PI/2
var wallValue = -1
var outSideWallValue = -2

var debug = true
var showWall = true

func _init(center_pos: Vector3, arr: Array[int], deep: float, size: float):
	instantiate_cube(center_pos, arr, deep, size)

func instantiate_cube(center_pos: Vector3, arr: Array[int], deep: float, size: float):
	var ratio = (deep/(size-1)) * 250.
	var color = Vector3(250 - ratio, 0, ratio).normalized()
	#print(deep/size, " ", 250 - ratio, " ", ratio)
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
	wallTmp.position.x = center_pos.x + pos.x
	wallTmp.position.y = center_pos.y + pos.y
	wallTmp.position.z = center_pos.z + pos.z
	
	wallTmp.rotation.x = rot.x
	wallTmp.rotation.y = rot.y
	wallTmp.rotation.z = rot.z
	add_child(wallTmp)

func instantiate_connection(center_pos: Vector3, rot: Vector3, color: Vector3):
	var connectionTmp = connection.instantiate()
	
	connectionTmp.get_child(0).mesh.material.albedo_color = Color(color.x, color.y, color.z, 1)
	
	connectionTmp.position.x = center_pos.x
	connectionTmp.position.y = center_pos.y
	connectionTmp.position.z = center_pos.z
	
	connectionTmp.rotation.x = rot.x
	connectionTmp.rotation.y = rot.y
	connectionTmp.rotation.z = rot.z
	
	add_child(connectionTmp)

func clean():
	for i in self.get_children():
		self.remove_child(i)
		i.queue_free()

func _exit_tree():
	self.queue_free()
	

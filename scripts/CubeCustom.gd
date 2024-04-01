extends Node
class_name CubeCustom
var connection = preload("res://scenes/connection.tscn")
var wall = preload("res://scenes/wall.tscn")
var distFromCenter = 5.2 
var rotationAngle = PI/2
var wallValue = -1
var debug = true

func _init(center_pos: Vector3, arr: Array[int]):
	instantiate_cube(center_pos, arr)

func instantiate_cube(center_pos: Vector3, arr: Array[int]):
	# (backward, forward, left, right, down, up)
	if (arr[0] == wallValue):
		if not debug:
			instanciate_wall(center_pos, Vector3(0,0,distFromCenter), Vector3(-PI,0,0))
	else :
		instantiate_connection(center_pos, Vector3(-PI,0,0))
	if (arr[1] == wallValue):
		if not debug:
			instanciate_wall(center_pos, Vector3(0,0,-distFromCenter), Vector3(0,0,0))
	else :
		instantiate_connection(center_pos, Vector3(0,0,0))
	
	if (arr[2] == wallValue):
		if not debug:
			instanciate_wall(center_pos, Vector3(-distFromCenter,0,0), Vector3(0,rotationAngle,0))
	else :
		instantiate_connection(center_pos, Vector3(0,rotationAngle,0))
	if (arr[3] == wallValue):
		if not debug:
			instanciate_wall(center_pos, Vector3(distFromCenter,0,0), Vector3(0,-rotationAngle,0))
	else :
		instantiate_connection(center_pos, Vector3(0,-rotationAngle,0))
	
	if (arr[4] == wallValue):
		if not debug:
			instanciate_wall(center_pos, Vector3(0,-distFromCenter,0), Vector3(rotationAngle,0,0))
	else :
		instantiate_connection(center_pos, Vector3(-rotationAngle,0,0))
	if (arr[5] == wallValue):
		if not debug:
			instanciate_wall(center_pos, Vector3(0,distFromCenter,0), Vector3(-rotationAngle,0,0))
	else :
		instantiate_connection(center_pos, Vector3(rotationAngle,0,0))

func instanciate_wall(center_pos: Vector3, pos: Vector3, rot: Vector3):
	var wallTmp = wall.instantiate()
	wallTmp.position.x = center_pos.x + pos.x
	wallTmp.position.y = center_pos.y + pos.y
	wallTmp.position.z = center_pos.z + pos.z
	
	wallTmp.rotation.x = rot.x
	wallTmp.rotation.y = rot.y
	wallTmp.rotation.z = rot.z
	add_child(wallTmp)

func instantiate_connection(center_pos: Vector3, rot: Vector3):
	var connectionTmp = connection.instantiate()
	connectionTmp.position.x = center_pos.x
	connectionTmp.position.y = center_pos.y
	connectionTmp.position.z = center_pos.z
	
	connectionTmp.rotation.x = rot.x
	connectionTmp.rotation.y = rot.y
	connectionTmp.rotation.z = rot.z
	
	add_child(connectionTmp)

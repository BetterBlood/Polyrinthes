extends Node
class_name Cube

var wall = preload("res://scenes/wall.tscn")

func _init(center_pos: Vector3, arr: Array[int]):
	instantiate_cube(center_pos, arr)

func instantiate_cube(center_pos: Vector3, arr: Array[int]):
	if (arr[0] == 1):
		instanciate_wall(center_pos, Vector3(0,0,5.2), Vector3(0,0,0))
	if (arr[1] == 1):
		instanciate_wall(center_pos, Vector3(0,0,-5.2), Vector3(0,0,0))
	
	if (arr[2] == 1):
		instanciate_wall(center_pos, Vector3(5.2,0,0), Vector3(0,PI/2,0))
	if (arr[3] == 1):
		instanciate_wall(center_pos, Vector3(-5.2,0,0), Vector3(0,-PI/2,0))
	
	if (arr[4] == 1):
		instanciate_wall(center_pos, Vector3(0,-5.2,0), Vector3(PI/2,0,0))
	if (arr[5] == 1):
		instanciate_wall(center_pos, Vector3(0,5.2,0), Vector3(-PI/2,0,0))

func instanciate_wall(center_pos: Vector3, pos: Vector3, rot: Vector3):
	var wallTmp = wall.instantiate()
	wallTmp.position.x = center_pos.x + pos.x
	wallTmp.position.y = center_pos.y + pos.y
	wallTmp.position.z = center_pos.z + pos.z
	
	wallTmp.rotation.x = rot.x
	wallTmp.rotation.y = rot.y
	wallTmp.rotation.z = rot.z
	add_child(wallTmp)

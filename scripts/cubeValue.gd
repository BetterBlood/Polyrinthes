extends Node
class_name CubeValue

const wall = preload("res://scenes/wall.tscn")
const distFromCenter = 5.2 
const rotationAngle = PI/2

func _init(center_pos: Vector3, arr: Array[int]):
	instantiate_cube(center_pos, arr)

func instantiate_cube(center_pos: Vector3, arr: Array[int]):
	if (arr[0] == 1):
		instantiate_wall(center_pos, Vector3(0,0,distFromCenter), Vector3(0,0,0))
	if (arr[1] == 1):
		instantiate_wall(center_pos, Vector3(0,0,-distFromCenter), Vector3(0,0,0))
	
	if (arr[2] == 1):
		instantiate_wall(center_pos, Vector3(-distFromCenter,0,0), Vector3(0,-rotationAngle,0))
	if (arr[3] == 1):
		instantiate_wall(center_pos, Vector3(distFromCenter,0,0), Vector3(0,rotationAngle,0))
	
	if (arr[4] == 1):
		instantiate_wall(center_pos, Vector3(0,-distFromCenter,0), Vector3(rotationAngle,0,0))
	if (arr[5] == 1):
		instantiate_wall(center_pos, Vector3(0,distFromCenter,0), Vector3(-rotationAngle,0,0))

func instantiate_wall(center_pos: Vector3, pos: Vector3, rot: Vector3):
	var wallTmp = wall.instantiate()
	wallTmp.position.x = center_pos.x + pos.x
	wallTmp.position.y = center_pos.y + pos.y
	wallTmp.position.z = center_pos.z + pos.z
	
	wallTmp.rotation.x = rot.x
	wallTmp.rotation.y = rot.y
	wallTmp.rotation.z = rot.z
	add_child(wallTmp)

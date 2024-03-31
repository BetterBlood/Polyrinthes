extends Node3D
const CubeValue := preload("res://scripts/cubeValue.gd")
var wall = preload("res://scenes/wall.tscn")

# Called when the node enters the scene tree for the first time.
func _ready(): # (backward, forward, left, right, down, up)
	var up = 1
	var xCoords = [-10.5, 0, 10.5]
	var yCoords = [0]
	var zCoords = [0, -10.5, -21, -31.5, -42]
	
	
	add_child(CubeValue.new(Vector3(xCoords[0],0,zCoords[0]), [1,0,0,1,1,up]))
	add_child(CubeValue.new(Vector3(xCoords[0],0,zCoords[1]), [0,0,1,1,1,up]))
	add_child(CubeValue.new(Vector3(xCoords[0],0,zCoords[2]), [0,0,1,1,1,up]))
	add_child(CubeValue.new(Vector3(xCoords[0],0,zCoords[3]), [0,0,1,1,1,up]))
	add_child(CubeValue.new(Vector3(xCoords[0],0,zCoords[4]), [0,1,1,0,1,up]))
	
	add_child(CubeValue.new(Vector3(xCoords[1],0,zCoords[0]), [1,0,1,1,1,up]))
	add_child(CubeValue.new(Vector3(xCoords[1],0,zCoords[1]), [0,0,1,1,1,up]))
	add_child(CubeValue.new(Vector3(xCoords[1],0,zCoords[2]), [0,0,1,0,1,up]))
	add_child(CubeValue.new(Vector3(xCoords[1],0,zCoords[3]), [0,0,1,1,1,up]))
	add_child(CubeValue.new(Vector3(xCoords[1],0,zCoords[4]), [0,1,0,1,1,up]))
	
	add_child(CubeValue.new(Vector3(xCoords[2],0,zCoords[0]), [1,0,1,0,1,up]))
	add_child(CubeValue.new(Vector3(xCoords[2],0,zCoords[1]), [0,0,1,1,1,up]))
	add_child(CubeValue.new(Vector3(xCoords[2],0,zCoords[2]), [0,0,0,1,1,up]))
	add_child(CubeValue.new(Vector3(xCoords[2],0,zCoords[3]), [0,0,1,1,1,up]))
	add_child(CubeValue.new(Vector3(xCoords[2],0,zCoords[4]), [0,1,1,1,1,up]))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


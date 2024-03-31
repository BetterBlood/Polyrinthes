extends Node
class_name CubeGraph

var neighbors = []
var neighborsConnected = []
var size = 0
const nbrNeighbors = 6
var wallValue = -1
var outsideWallValue = -2

func _init(mazeSize: int):
	size = mazeSize
	for i in range(getNbrRoom()):
		neighbors.append([])
		neighborsConnected.append([])
		for j in range(nbrNeighbors):
			neighborsConnected[i].append(wallValue)
	constructNeig()
	replaceValueForOutsideWalls(neighborsConnected)

func constructNeig():
	# (backward, forward, left, right, down, up)
	var roomsNumber = getNbrRoom()
	var faceSize = getNbrRoomOnASide()
	
	if roomsNumber <= 1: # no neighbors in these cases
		return
	
	# TODO : problem here neighbors not correcty initialize:
	for i in range(faceSize): 
		# backward + forward
		neighbors[i].insert(0, wallValue) # backward is empty for the front side
		neighbors[i].insert(1, i + faceSize); # forward
		
		for j in range(1, size - 1):
			neighbors[i + j * faceSize].insert(0, i + (j - 1) * faceSize) # backward
			neighbors[i + j * faceSize].insert(1, i + (j + 1) * faceSize) # forward
		
		neighbors[i + (size - 1) * faceSize].insert(0, i + (size - 2) * faceSize) # backward
		neighbors[i + (size - 1) * faceSize].insert(1, wallValue) # forward is empty for the back side
	
	for i in range(faceSize): 
		# left + right
		neighbors[i * size].insert(2, wallValue) # left is empty for the left side
		neighbors[i * size].insert(3, i * size + 1) # right
		
		for j in range(1, size - 1):
			neighbors[i * size + j].insert(2, i * size + j - 1) # left
			neighbors[i * size + j].insert(3, i * size + j + 1) # right
			
		neighbors[i * size + size - 1].insert(2, i * size + size - 2) # left
		neighbors[i * size + size - 1].insert(3, wallValue) # right is empty for the right side
	
	var floorC = 0
	for i in range(faceSize): 
		# down + up
		neighbors[i%size + floorC*faceSize].insert(4, wallValue) # down is empty for the down side
		neighbors[i%size + floorC*faceSize].insert(5, i%size + floorC*faceSize + size) # up
		
		for j in range(1, size - 1):
			neighbors[i%size + floorC*faceSize + j*size].insert(4, i%size + floorC*faceSize + (j - 1)*size) # down
			neighbors[i%size + floorC*faceSize + j*size].insert(5, i%size + floorC*faceSize + (j + 1)*size) # up
		
		neighbors[i%size + floorC*faceSize + (size - 1) * size].insert(4, i%size + floorC*faceSize + (size - 2) * size) # down
		neighbors[i%size + floorC*faceSize + (size - 1) * size].insert(5, wallValue) # up is empty for the up side

		if i%size == size - 1:
			floorC += 1
	
	#print(neighbors)

func replaceValueForOutsideWalls(array):
	# (backward, forward, left, right, down, up)
	for i in range(getNbrRoom()):
		if i < getNbrRoomOnASide():
			array[i].remove_at(0)
			array[i].insert(0, outsideWallValue)
		if i > getNbrRoom() - getNbrRoomOnASide() - 1:
			array[i].remove_at(1)
			array[i].insert(1, outsideWallValue)
		
		if i%getNbrRoomOnASide() < size:
			array[i].remove_at(4)
			array[i].insert(4, outsideWallValue)
		if i%getNbrRoomOnASide() > getNbrRoomOnASide() - size - 1:
			array[i].remove_at(5)
			array[i].insert(5, outsideWallValue)
		
		if i%size == 0:
			array[i].remove_at(2)
			array[i].insert(2, outsideWallValue)
		if i%size == size - 1:
			array[i].remove_at(3)
			array[i].insert(3, outsideWallValue)

func getNeighbors(id) -> Array[int]:
	var neighborsForId : Array[int] = []
	#neighbors[id] = neighbors[id].filter(func(number): return number != -1)
	#print("id: ", id, ", size: ", len(neighbors[id]), ", neighbors[id]: ", neighbors[id])
	for i in range(nbrNeighbors):
		#print("i: ", i, ", neighbors[id][i]: ", neighbors[id][i])
		neighborsForId.append(neighbors[id][i])
	
	return neighborsForId

func getNeigborsConnection(id) -> Array[int]:
	var neighborsForId : Array[int] = []
	for i in range(nbrNeighbors):
		neighborsForId.append(neighborsConnected[id][i])
	return neighborsForId

func connectNeigbors(id1, id2, direction):
	# means to remove the 2 walls of each room given
	print("TODO ! connectNeigbors ", id1, " ", id2, " ", direction)

func getNbrRoom():
	return size * size * size

func getNbrRoomOnASide():
	return size * size

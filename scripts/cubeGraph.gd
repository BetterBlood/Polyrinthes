extends Node
class_name CubeGraph

var neighbors = []
var neighborsConnected = []
var colorsIds = []
var visited:Array[bool] = []
static var colorId = 0

var size: int
var nbrNeighbors: int
var wallValue: int
var outsideWallValue: int

func _init(mazeSize: int = 3, wallV: int = -1, outWallV: int = -2, nbrN: int = 6):
	size = mazeSize
	nbrNeighbors = nbrN
	wallValue = wallV
	outsideWallValue = outWallV
	
	for i in range(getNbrRoom()):
		visited.append(false)
		neighbors.append([])
		neighborsConnected.append([])
		colorsIds.append(-1)
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

# construct a copy of the neighbors for the id given
func getNeighbors(id: int) -> Array[int]:
	var neighborsForId : Array[int] = []
	#neighbors[id] = neighbors[id].filter(func(number): return number != -1)
	#print("id: ", id, ", size: ", len(neighbors[id]), ", neighbors[id]: ", neighbors[id])
	for i in range(nbrNeighbors):
		#print("i: ", i, ", neighbors[id][i]: ", neighbors[id][i])
		neighborsForId.append(neighbors[id][i])
	
	return neighborsForId

# construct a copy of the connected neighbors for the id given
func getNeighborsConnection(id) -> Array[int]:
	var neighborsForId : Array[int] = []
	for i in range(nbrNeighbors):
		neighborsForId.append(neighborsConnected[id][i])
	return neighborsForId

func getNotVisitedNeighbors(id: int, only2D:bool = false):
	var neighborsForId : Array[int] = []
	var nbrNeighborsNeeded = nbrNeighbors
	if only2D :
		nbrNeighborsNeeded = getNbrNeighborsFor2D()
	for i in range(nbrNeighborsNeeded):
		if not isVisited(neighbors[id][i]):
			neighborsForId.append(neighbors[id][i])
	return neighborsForId

func getNbrNeighborsFor2D():
	return nbrNeighbors - 2

# update neighborsConnected if id1 and id2 are neighbors
# removes the 2 walls that connect roomsId given
func connectNeighbors(id1, id2):
	if not areNeighbors(id1, id2):
		print("ERROR : cannot connect ", id1, " and ", id2, ", they are not Neighbors !")
		return
	
	# first color instead of overwrite color
	if colorsIds[id1] == -1 :
		colorsIds[id1] = colorId
	if colorsIds[id2] == -1 :
		colorsIds[id2] = colorId + 1
	colorId += 1
	
	# left, right
	if id1 + 1 == id2:
		neighborsConnected[id1][3] = id2
		neighborsConnected[id2][2] = id1
	if id1 - 1 == id2:
		neighborsConnected[id1][2] = id2
		neighborsConnected[id2][3] = id1
	
	# backward, forward
	if id1 + getNbrRoomOnASide() == id2:
		neighborsConnected[id1][1] = id2
		neighborsConnected[id2][0] = id1
	if id1 - getNbrRoomOnASide() == id2:
		neighborsConnected[id1][0] = id2
		neighborsConnected[id2][1] = id1
	
	# down, up
	if id1 + size == id2:
		neighborsConnected[id1][5] = id2
		neighborsConnected[id2][4] = id1
	if id1 - size == id2:
		neighborsConnected[id1][4] = id2
		neighborsConnected[id2][5] = id1

# update neighborsConnected if id1 and id2 are neighbors
# add 2 walls on the connection between roomsId given
func disconnectNeighbors(id1, id2):
	if not areNeighbors(id1, id2):
		print("ERROR : cannot disconnect ", id1, " and ", id2, ", they are not Neighbors !")
		return
	
	# left, right
	if id1 + 1 == id2:
		neighborsConnected[id1][3] = wallValue
		neighborsConnected[id2][2] = wallValue
	if id1 - 1 == id2:
		neighborsConnected[id1][2] = wallValue
		neighborsConnected[id2][3] = wallValue
	
	# backward, forward
	if id1 + getNbrRoomOnASide() == id2:
		neighborsConnected[id1][1] = wallValue
		neighborsConnected[id2][0] = wallValue
	if id1 - getNbrRoomOnASide() == id2:
		neighborsConnected[id1][0] = wallValue
		neighborsConnected[id2][1] = wallValue
	
	# down, up
	if id1 + size == id2:
		neighborsConnected[id1][5] = wallValue
		neighborsConnected[id2][4] = wallValue
	if id1 - size == id2:
		neighborsConnected[id1][4] = wallValue
		neighborsConnected[id2][5] = wallValue

# check if neighborsConnected[id1] contain id2
func areConnected(id1, id2):
	if (isInRange(id1) && isInRange(id2)):
		for i in neighborsConnected[id1]:
			if i == id2:
				return true
	return false

# check if neighbors[id1] contain id2
func areNeighbors(id1, id2):
	if (isInRange(id1) && isInRange(id2)):
		for i in neighbors[id1]:
			if i == id2:
				return true
	return false

func getNbrRoom():
	return size * size * size

func getNbrRoomOnASide():
	return size * size

func getColor(id: int):
	return colorsIds[id]

func isInRange(id: int):
	return id < getNbrRoom() && id >= 0

func isVisited(id: int):
	return not isInRange(id) || visited[id]

func setVisited(id: int, value: bool = true):
	if not isInRange(id): return
	visited[id] = value

func hasUpNeighbors(id: int):
	return neighbors[id][5] != -1

func getUpNeighbors(id: int):
	return neighbors[id][5]

func clean():
	neighbors.clear()
	neighborsConnected.clear()
	colorsIds.clear()
	colorId = 0
	visited.clear()

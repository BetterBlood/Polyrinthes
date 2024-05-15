extends Node
class_name CubeGraph

var neighbors = []
var neighborsConnected = []
var colorsIds = []
var depths = []
var lastVisited = 0
var deepest = 0
var visited:Array[bool] = []
var processing:Array[bool] = []
static var colorId = 0
var colorByDepth = true

var size: int
var nbrNeighbors: int
var wallValue: int
var outsideWallValue: int

func _init(mazeSize: int = 3, wallV: int = -1, outWallV: int = -2, nbrN: int = 6, byDepthColor: bool = true):
	size = mazeSize
	nbrNeighbors = nbrN
	wallValue = wallV
	outsideWallValue = outWallV
	colorByDepth = byDepthColor
	
	for i in range(getNbrRoom()):
		visited.append(false)
		processing.append(false)
		neighbors.append([])
		neighborsConnected.append([])
		colorsIds.append(-1)
		depths.append(-1)
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

func getNextNeighbors(id: int) -> Array[int]:
	var neighborsForId : Array[int] = []
	for i in range(nbrNeighbors):
		if neighborsConnected[id][i] > -1 && isFollowing(id, neighborsConnected[id][i]):
			neighborsForId.append(neighborsConnected[id][i])
	return neighborsForId

# construct a copy of the connected neighbors for the id given
func getNeighborsConnection(id) -> Array[int]:
	var neighborsForId : Array[int] = []
	for i in range(nbrNeighbors):
		neighborsForId.append(neighborsConnected[id][i])
	return neighborsForId

func getNeighborsConnectionNotVisited(id) -> Array[int]:
	var neighborsForId : Array[int] = []
	for i in range(nbrNeighbors):
		if not isVisited(neighborsConnected[id][i]):
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

func getNotProcessingNeighbors(id: int, only2D:bool = false):
	var neighborsForId : Array[int] = []
	var nbrNeighborsNeeded = nbrNeighbors
	if only2D :
		nbrNeighborsNeeded = getNbrNeighborsFor2D()
	for i in range(nbrNeighborsNeeded):
		if not isProcessing(neighbors[id][i]):
			neighborsForId.append(neighbors[id][i])
	return neighborsForId

func getNotProcNotVisiNeighbors(id: int, only2D:bool = false):
	var neighborsForId : Array[int] = []
	var nbrNeighborsNeeded = nbrNeighbors
	if only2D :
		nbrNeighborsNeeded = getNbrNeighborsFor2D()
	for i in range(nbrNeighborsNeeded):
		if not isProcessing(neighbors[id][i]) and not isVisited(neighbors[id][i]):
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
	
	# first color instead of overwrite color and first approach to debug with colors
	if not colorByDepth :
		if colorsIds[id1] == -1 :
			colorsIds[id1] = colorId
		if colorsIds[id2] == -1 :
			#colorId += 1
			colorsIds[id2] = colorId + 1
			lastVisited = colorId + 1
		colorId += 1
#	else :
#		if colorsIds[id1] == -1 :
#			colorsIds[id1] = depths[id1]
#		if colorsIds[id2] == -1 :
#			colorId += 1
#			colorsIds[id2] = depths[id2]
	
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
	if isInRange(id):
		return colorsIds[id]
	return -1

func getDepth(id :int):
	if not isInRange(id):
		return -1
	return depths[id]

func setDepth(id: int, depth: int):
	if isInRange(id):
		depths[id] = depth 
		if deepest < depth :
			deepest = depth
			lastVisited = deepest
			#print("lastVisited:", lastVisited)

func setColorFromDepth():
	colorsIds = depths.duplicate()

func isInRange(id: int):
	return id < getNbrRoom() && id >= 0

func isVisited(id: int):
	return not isInRange(id) || visited[id]

func setVisited(id: int, value: bool = true):
	if not isInRange(id): return
	visited[id] = value

func isProcessing(id: int):
	return not isInRange(id) || processing[id]

func setProcessing(id: int, value: bool = true):
	if not isInRange(id): return
	processing[id] = value

func isFollowing(id_first: int, id_second: int):
	return isInRange(id_first) && isInRange(id_second) && getDepth(id_first) < getDepth(id_second)

func hasUpNeighbors(id: int):
	return neighbors[id][5] != -1

func getUpNeighbors(id: int):
	return neighbors[id][5]

func reset_Depth_Color_Visited():
	lastVisited = 0
	deepest = 0
	depths.clear()
	colorsIds.clear()
	visited.clear()
	for i in range(getNbrRoom()):
		depths.append(-1)
		colorsIds.append(-1)
		visited.append(false)

func resetDepth():
	depths.clear()
	for i in range(getNbrRoom()):
		depths.append(-1)

func resetColor():
	colorsIds.clear()
	for i in range(getNbrRoom()):
		colorsIds.append(-1)

func resetVisited():
	visited.clear()
	for i in range(getNbrRoom()):
		visited.append(false)

# duplicate from CubeCustom
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

func instantiate_pyramid(center_pos: Vector3, distFromCenter: Vector3, color: Vector3):
	var base_distFromCenter: int = 1
	var vertices = PackedVector3Array()
	var point1:Vector3
	var point2:Vector3
	var point3:Vector3
	var point4:Vector3
	
	if distFromCenter.x != 0:
		point1 = Vector3(0, base_distFromCenter, base_distFromCenter)
		point2 = Vector3(0, -base_distFromCenter, base_distFromCenter)
		point3 = Vector3(0, -base_distFromCenter, -base_distFromCenter)
		point4 = Vector3(0, base_distFromCenter, -base_distFromCenter)
	elif distFromCenter.y != 0:
		point1 = Vector3(base_distFromCenter, 0, base_distFromCenter)
		point2 = Vector3(-base_distFromCenter, 0, base_distFromCenter)
		point3 = Vector3(-base_distFromCenter, 0, -base_distFromCenter)
		point4 = Vector3(base_distFromCenter, 0, -base_distFromCenter)
	else:
		point1 = Vector3(base_distFromCenter, base_distFromCenter, 0)
		point2 = Vector3(-base_distFromCenter, base_distFromCenter, 0)
		point3 = Vector3(-base_distFromCenter, -base_distFromCenter, 0)
		point4 = Vector3(base_distFromCenter, -base_distFromCenter, 0)
	
	# 4 faces :
	vertices.push_back(point1)
	vertices.push_back(distFromCenter)
	vertices.push_back(point2)
	
	vertices.push_back(point2)
	vertices.push_back(distFromCenter)
	vertices.push_back(point3)

	vertices.push_back(point3)
	vertices.push_back(distFromCenter)
	vertices.push_back(point4)

	vertices.push_back(point4)
	vertices.push_back(distFromCenter)
	vertices.push_back(point1)
	
	# base (square (triangle x 2)):
	vertices.push_back(point1)
	vertices.push_back(point2)
	vertices.push_back(point3)
	
	vertices.push_back(point3)
	vertices.push_back(point4)
	vertices.push_back(point1)
	
	
	# Initialize the ArrayMesh.
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	
	# Create the Mesh.
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	var m = MeshInstance3D.new()
	m.mesh = arr_mesh
	m.position = center_pos
	
	var newMaterial = StandardMaterial3D.new()
	newMaterial.albedo_color = Color(color.x, color.y, color.z, 1)
	m.material_override = newMaterial
	
	return m

func clean():
	neighbors.clear()
	neighborsConnected.clear()
	colorsIds.clear()
	colorId = 0
	lastVisited = 0
	deepest = 0
	visited.clear()
	processing.clear()
	depths.clear()
	
	for i in self.get_children():
		self.remove_child(i)
		i.queue_free()

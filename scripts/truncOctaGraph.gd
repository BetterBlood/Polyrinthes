extends BaseGraph
class_name TruncOctaGraph

static var colorId = 0

func _init(mazeSize: int = 3, wallV: int = -1, outWallV: int = -2, nbrN: int = 14, byDepthColor: bool = true):
	super._init(mazeSize, wallV, outWallV, nbrN, byDepthColor)
	
	for i in range(getNbrRoom()):
		# TODO see if Array.resise() or something like this is usable here (and better)
		visited.append(false)
		processing.append(false)
		neighbors.append([])
		neighborsConnected.append([])
		colorsIds.append(-1)
		depths.append(-1)
		for j in range(nbrNeighbors):
			neighborsConnected[i].append(wallValue)
	
	constructNeig()
	#replaceValueForOutsideWalls(neighborsConnected)

func getNbrRoom() -> int:
	return super.getNbrRoom() + getNbrRoom_inside()

func getNbrRoom_inside() -> int:
	return pow(size - 1, 3)

func getNbrRoomOnASide() -> int:
	return super.getNbrRoomOnASide() + getNbrRoomOnASide_inside()

func getNbrRoomOnASide_inside() -> int:
	return pow(size - 1, 2)

func constructNeig():
	# (backward, forward, left, right, down, up)
	var roomsNumber = super.getNbrRoom()
	var faceSize = super.getNbrRoomOnASide()
	
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
	
	# add neighbors for inside rooms : ( TODO : verify that's correct)
	var roomsNumberInside:int = getNbrRoom_inside()
	var faceSizeInside:int = getNbrRoomOnASide_inside()
	var sizeInside = size - 1
	
	for i in range(faceSizeInside): 
		# backward + forward
		neighbors[i + roomsNumber].insert(0, wallValue) # backward is empty for the front side
		neighbors[i + roomsNumber].insert(1, i + faceSize + faceSizeInside); # forward
		
		for j in range(1, sizeInside - 1):
			neighbors[i + roomsNumber + j * faceSizeInside].insert(0, i + roomsNumber + (j - 1) * faceSizeInside) # backward
			neighbors[i + roomsNumber + j * faceSizeInside].insert(1, i + roomsNumber + (j + 1) * faceSizeInside) # forward
		
		neighbors[i + roomsNumber + (sizeInside - 1) * faceSizeInside].insert(0, i + roomsNumber + (sizeInside - 2) * faceSizeInside) # backward
		neighbors[i + roomsNumber + (sizeInside - 1) * faceSizeInside].insert(1, wallValue) # forward is empty for the back side
	
	for i in range(faceSizeInside): 
		# left + right
		neighbors[i * sizeInside + roomsNumber].insert(2, wallValue) # left is empty for the left side
		neighbors[i * sizeInside + roomsNumber].insert(3, i * sizeInside + 1 + roomsNumber) # right
		
		for j in range(1, sizeInside - 1):
			neighbors[i * sizeInside + j + roomsNumber].insert(2, i * sizeInside + j - 1 + roomsNumber) # left
			neighbors[i * sizeInside + j + roomsNumber].insert(3, i * sizeInside + j + 1 + roomsNumber) # right
			
		neighbors[i * sizeInside + sizeInside - 1 + roomsNumber].insert(2, i * sizeInside + sizeInside - 2 + roomsNumber) # left
		neighbors[i * sizeInside + sizeInside - 1 + roomsNumber].insert(3, wallValue) # right is empty for the right side
	
	floorC = 0
	for i in range(faceSizeInside): 
		# down + up
		neighbors[i%sizeInside + floorC*faceSizeInside + roomsNumber].insert(4, wallValue) # down is empty for the down side
		neighbors[i%sizeInside + floorC*faceSizeInside + roomsNumber].insert(5, i%sizeInside + floorC*faceSizeInside + sizeInside + roomsNumber) # up
		
		for j in range(1, sizeInside - 1):
			neighbors[i%sizeInside + floorC*faceSizeInside + j*sizeInside + roomsNumber].insert(4, i%sizeInside + floorC*faceSizeInside + (j - 1)*sizeInside + roomsNumber) # down
			neighbors[i%sizeInside + floorC*faceSizeInside + j*sizeInside + roomsNumber].insert(5, i%sizeInside + floorC*faceSizeInside + (j + 1)*sizeInside + roomsNumber) # up
		
		neighbors[i%sizeInside + floorC*faceSizeInside + (sizeInside - 1) * sizeInside + roomsNumber].insert(4, i%sizeInside + floorC*faceSizeInside + (sizeInside - 2) * sizeInside + roomsNumber) # down
		neighbors[i%sizeInside + floorC*faceSizeInside + (sizeInside - 1) * sizeInside + roomsNumber].insert(5, wallValue) # up is empty for the up side

		if i%sizeInside == sizeInside - 1:
			floorC += 1
	
	constructHexagonalNeig(roomsNumber, sizeInside) # 8 hex neighbors
	
	#print(neighbors) # debug (<.<)

func constructHexagonalNeig(roomsNumber, sizeInside):
	
	# TODO : add 8 hexagonal neighbors
	# (backward-left-down , backward-left-up, backward-right-up, backward-right-down, 
	# 		6, 					7, 					8, 				9
	#  forward-left-down,  forward-left-up,  forward-right-up,  forward-right-down)
	# 		10, 				11, 				12, 			13
	
	var allOut = range(roomsNumber) # array
	var allInside = getInsideRoom() # array
	
	# backward-left-down => bld
	var outsideWall_bld = getRoomIdsWithWallAt_backward_left_down() # array
	var outside_bld = getArrayDiff(allOut, outsideWall_bld) # debug
	var insideWall_bld = getInsideRoomIdsBordered_backward_left_down() # array
	var inside_bld = getArrayDiff(allInside, insideWall_bld) # debug
	
	for i in outsideWall_bld: 
		neighbors[i].insert(6, wallValue)# TODO : verify
	for i in getArrayDiff(allOut, outsideWall_bld):
		neighbors[i].insert(6, i - size * size - size - 1 )# TODO : verify
	for i in insideWall_bld:
		neighbors[i].insert(6, i - roomsNumber - 1)# TODO : verify
	for i in getArrayDiff(allInside, insideWall_bld):
		neighbors[i].insert(6, i - sizeInside * sizeInside - sizeInside - 1)# TODO : verify (false for not bordered)
	
	# backward-left-up => blu TODO : WIP
	var outsideWall_blu = getRoomIdsWithWallAt_backward_left_up() # array
	var outside_blu = getArrayDiff(allOut, outsideWall_blu) # debug
	var insideWall_blu = getInsideRoomIdsBordered_backward_left_up() # array
	var inside_blu = getArrayDiff(allInside, insideWall_blu) # debug
	
	
	# backward-right-up => bru
	# backward-right-down => brd
	
	# forward-left-down => fld
	# forward-left-up => flu
	# forward-right-up => fru
	# forward-right-down => frd
	
	print("outside : ", allOut)
	print("inside  : ", allInside)
	
	print("\nbackward-left-down")
	print("with    : ", outsideWall_bld)
	print("without : ", outside_bld)
	print("insideB : ", insideWall_bld)
	print("insideN : ", inside_bld)
	
	print("\nbackward-left-up")
	print("with    : ", outsideWall_blu)
	print("without : ", outside_blu)
	print("insideB : ", insideWall_blu)
	print("insideN : ", inside_blu)
	

# 3 faces : front, left and down ones
func getRoomIdsWithWallAt_backward_left_down():
	var result = range(size*size) # front face
	for i in range(1, size): # down face
		for j in range(size):
			result.append(i*size*size + j)
	
	for i in range(1, size): # left face
		for j in range(1, size):
			result.append(j*size*size + i*size)
	
	return result

func getInsideRoomIdsBordered_backward_left_down():
	var nbrOnInsideFace = getNbrRoomOnASide_inside()
	var beginInsideId = size*size*size
	
	# front face
	var result = range(beginInsideId, beginInsideId + nbrOnInsideFace)
	
	# down face
	for i in range(1, size - 1):
		for j in range(size - 1):
			result.append(beginInsideId + i*nbrOnInsideFace + j)
	
	# left face
	for i in range(1, size - 1):
		for j in range(1, size - 1):
			result.append(beginInsideId + j*nbrOnInsideFace + i*(size - 1))
	
	return result

func getRoomIdsWithWallAt_backward_left_up():
	var result = range(size*size) # front face
	for i in range(1, size): # up face
		for j in range(size):
			result.append((i+1)*size*size + j - size)
	
	for i in range(1, size): # left face TODO : WIP
		for j in range(1, size):
			result.append(j*size*size + i*size)
	
	return result

func getInsideRoomIdsBordered_backward_left_up():
	var nbrOnInsideFace = getNbrRoomOnASide_inside()
	var beginInsideId = size*size*size
	
	# front face
	var result = range(beginInsideId, beginInsideId + nbrOnInsideFace)
	
	# up face
	for i in range(1, size - 1):
		for j in range(size - 1):
			result.append(beginInsideId + (i+1)*nbrOnInsideFace + j - (size-1))
	
	print("\n")
	# left face
	for i in range(1, size - 1):
		for j in range(1, size - 1):
			result.append(beginInsideId + j*nbrOnInsideFace + i*(size - 1) - size + 1)
	
	print(result)
	return result

func getArrayDiff(insides, arr):
	var result = []
	for i in insides:
		if i not in arr:
			result.append(i)
	return result

# inside rooms
func getInsideRoom():
	return range(super.getNbrRoom(), getNbrRoom())


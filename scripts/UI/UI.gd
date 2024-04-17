extends CanvasLayer

signal generation(edgeSize: int)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		$"../SelectionWheel".show()
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	elif Input.is_action_just_released("menu"):
		#TODO signal -> remove prev gen -> generate new with edgeSize !
		var edgeSize = $"../SelectionWheel".close()
		if edgeSize != 0 :
			generation.emit(edgeSize)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)




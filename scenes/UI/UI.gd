extends CanvasLayer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		$"../SelectionWheel".show()
	elif Input.is_action_just_released("menu"):
		$"../SelectionWheel".hide()

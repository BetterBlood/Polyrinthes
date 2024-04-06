extends Node

signal generation(edgeSize: int)

func _on_ui_generation(edgeSize) -> void:
	generation.emit(edgeSize)

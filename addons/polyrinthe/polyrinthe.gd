@tool
extends EditorPlugin


func _enter_tree():
	# Initialization of the plugin goes here.
	add_custom_type("Polyrinthe", "Node3D", 
		preload("res://scripts/test_generation_002.gd"), 
		preload("res://addons/polyrinthe/polyrinthe_logo.png")
	)


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_custom_type("Polyrinthe")

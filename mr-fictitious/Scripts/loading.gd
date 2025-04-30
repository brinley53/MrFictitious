'''
Script for loading screen logic.
Authors: Brinley Hull
Creation date: 4/29/2025
Revisions:
'''

extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame  # Wait one frame so loading screen appears
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

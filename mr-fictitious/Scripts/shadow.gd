"""
Script for shadows and stealth
Authors: Brinley Hull
Creation Date: 04/14/2025
Revisions:
"""
extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	# set player stealth
	pass


func _on_area_2d_body_exited(body: Node2D) -> void:
	# reset player stealth
	pass

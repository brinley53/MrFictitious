'''
Script for the asylum boss room logic
Authors: Brinley Hull
Creation date: 4/29/2025
Revisions:
'''

extends Node2D

@onready var players = get_tree().get_nodes_in_group("Player")
@onready var player = players[0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# call final boss dialogue
	await get_tree().process_frame  # Wait one frame so screen appears
	player.final_boss_dialogue()

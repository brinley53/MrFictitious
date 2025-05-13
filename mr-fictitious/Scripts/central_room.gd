'''
Script for central room logic.
Authors: Brinley Hull, Sean Hammell
Creation date: 4/29/2025
Revisions:
'''

extends Node2D

@onready var players = get_tree().get_nodes_in_group("Player")
@onready var player = players[0]
@onready var asylum_blocker = $AsylumBlocker

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# call starting dialogue
	await get_tree().process_frame  # Wait one frame so screen appears


func _on_dialogue_trigger_body_entered(_body: Node2D) -> void:
	if player and abs(player.position.y - asylum_blocker.position.y) < 64:
		player.asylum_blocker_dialogue()


func _on_tree_entered() -> void:
	if player != null and player.evidence_collected >= 3 and asylum_blocker != null:
		asylum_blocker.queue_free()

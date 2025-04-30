'''
Script for the inmate/tent logic.
Authors: Jose Leyba, Brinley Hull
Creation date: 4/29/2025
Revisions:
	Brinley Hull - 4/29/2025: Make dialogue call to player
'''

extends CharacterBody2D
@onready var players = get_tree().get_nodes_in_group("Player")
@onready var player = players[0]
var in_enter_area := false

func _process(_delta):
	if in_enter_area and Input.is_action_just_pressed("attack"):
		player.inmate_dialogue()

func _on_enter_area_body_entered(body: Node2D) -> void:
	if body.name == "Player": 
		in_enter_area = true

func _on_enter_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		in_enter_area = false

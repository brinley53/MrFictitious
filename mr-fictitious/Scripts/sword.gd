"""
Second Weapon Implemented, attacks in a circle range around the player
Authors: Jose Leyba
Creation Date: 04/17/2025
Revisions:
	Brinley Hull - 4/22/2025: Dialogue
"""
extends Area2D

@export var damage_increase := 3
@export var attack_area_shrink := 0.7  # 70% of original size\
@onready var dialogue = preload("res://shovel.dialogue")
@onready var dialogue_manager = get_node("/root/DialogueManager")
@export var inventory_drop_item:InventoryItem;
@export var evidence_item:Evidence;


func _ready():
	pass


func _on_body_entered(body):
	if body.name == "Player":
		body.collect_sword_weapon()
		dialogue_manager.show_dialogue_balloon(dialogue, "sword")
		body.in_dialogue = true
		queue_free()

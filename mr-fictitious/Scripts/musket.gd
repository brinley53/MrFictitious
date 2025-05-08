"""
Last Weapon Implemented, shoots bullets that separate and explode after 4 seconds
Authors: Jose Leyba
Creation Date: 04/17/2025
Revisions:
	Brinley Hull - 4/22/2025: Dialogue
"""
extends Area2D

@export var damage_increase := 3
@export var attack_area_shrink := 0.7  
@onready var dialogue = preload("res://shovel.dialogue")
@onready var dialogue_manager = get_node("/root/DialogueManager")
@export var inventory_drop_item:InventoryItem;
@export var evidence_item:Evidence;


func _on_body_entered(body):
	if body.name == "Player":
		body.collect_musket_weapon()
		for i in range(15):
			body.collectWeapon(inventory_drop_item)
		dialogue_manager.show_dialogue_balloon(dialogue, "musket")
		queue_free()

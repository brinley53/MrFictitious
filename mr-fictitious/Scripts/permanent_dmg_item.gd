"""
First Permanent Item, It trades attack area for a dmg buff
Authors: Jose Leyba
Creation Date: 04/17/2025
Revisions:
	Brinley Hull - 4/22/2025: Dialogue
"""
extends Area2D

@export var damage_increase := -1
@export var attack_area_shrink := 1.4  # 70% of original size\
@onready var dialogue = preload("res://shovel.dialogue")
@onready var dialogue_manager = get_node("/root/DialogueManager")
@onready var timer = $Timer



func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))


func _on_body_entered(body):
	if body.name == "Player":
		body.shovel(damage_increase, attack_area_shrink)
		dialogue_manager.show_dialogue_balloon(dialogue, "start")
		queue_free()

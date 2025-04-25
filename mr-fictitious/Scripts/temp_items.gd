"""
Script for items, they dissapear when walking over them and give out temporary buffs
Authors: Jose Leyba
Creation Date: 04/17/2025
Revisions:
	[format: date - name, what you revised]
"""
extends Area2D

#Possible Buffs
@export_enum("Speed", "Dmg", "Nothing fr", "Evidence") var type : String
@export var inventory_drop_item:InventoryItem;

#BOOST VALUES
var speed_boost: float = 1.5
var damage_boost: int = 1

#Buff Time (Same for everything for now)
@export var duration: float = 5.0
@onready var timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if type == "Speed":
			if body.collectItem(inventory_drop_item):
				body.add_speed_item()
			queue_free()
		if type == "Dmg":
			if body.collectItem(inventory_drop_item):
				body.add_damage_item()
				queue_free()
		if type == "Evidence":
			body.new_evidence_collected()
			queue_free()

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

#BOOST VALUES
var speed_boost: float = 1.5
var damage_boost: int = 1

#Buff Time (Same for everything for now)
@export var duration: float = 5.0
@onready var timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if type == "Speed":
			body.apply_speed_buff(speed_boost, duration)
			queue_free()
		if type == "Dmg":
			body.apply_damage_buff(damage_boost, duration)
			queue_free()
		if type == "Evidence":
			body.evidence_collected +=1
			queue_free()

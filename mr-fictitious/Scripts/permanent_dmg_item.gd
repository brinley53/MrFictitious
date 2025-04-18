"""
First Permanent Item, It trades attack area for a dmg buff
Authors: Jose Leyba
Creation Date: 04/17/2025
Revisions:
"""
extends Area2D

@export var damage_increase := 3
@export var attack_area_shrink := 0.7  # 70% of original size

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body is Player:
		body.shovel(damage_increase, attack_area_shrink)
		queue_free()

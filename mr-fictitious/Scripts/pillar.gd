"""
Script for showing lit vs unlit pillar.
Authors: Brinley Hull
Creation Date: 04/26/2025
Revisions:
"""

extends Node2D

@onready var lit_sprite = $Lit
@export var lit = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lit_sprite.visible = lit


func toggle_enable():
	lit_sprite.visible = !lit_sprite.visible

func _on_hit_area_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if area.is_in_group("Bullet"):
		area.queue_free()

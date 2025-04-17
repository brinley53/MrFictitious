"""
Script for items, for now they dissapear when walking over them
Authors: Jose Leyba
Creation Date: 03/27/2025
Revisions:
	[format: date - name, what you revised]
"""
extends Area2D
@export var drop_item:InventoryItem;




func _on_body_entered(body: Node2D) -> void:
	print("Body entered:", body.name)
	if body.name == "Player":
		if body.collectItem(drop_item):
			body.add_bullet()
			queue_free()
	if body.is_in_group("Enemies"):
		print("Hit an Enemy!")
		if body.has_method("reduce_enemy_health"):
			body.reduce_enemy_health(1)
			print("Enemy health reduced.")
			queue_free()

	

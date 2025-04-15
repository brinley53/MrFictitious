extends Area2D

"""
----------
Script for health item
Authors: Tej Gumaste
Creation Date: 04/15/2025
Revisions:
[First Addition- Tej Gumaste]
"""
@export var inventory_drop_item:InventoryItem;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_body_entered(body: Node2D) -> void:
	print("Collision")
	if body.name == "Player":
		print("entered collision")
		if body.collectItem(inventory_drop_item):
			body.add_health_item()
			queue_free()
	

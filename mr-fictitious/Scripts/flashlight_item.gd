extends Area2D

"""
----------
Script for flashlight item
Authors: Jose Leyba
Creation Date: 04/15/2025
Revisions:
[First Addition- Jose Leyba]
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
			body.collectItem(inventory_drop_item)
			body.collectItem(inventory_drop_item)
			body.add_flashlight_item()
			body.add_flashlight_item()
			body.add_flashlight_item()

			queue_free()

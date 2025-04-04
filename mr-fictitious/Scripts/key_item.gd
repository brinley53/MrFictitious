"""
Script for items, for now they dissapear when walking over them
Authors: Jose Leyba
Creation Date: 03/27/2025
Revisions:
	[format: date - name, what you revised]
"""
extends Area2D
@export var drop_item:InventoryItem;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if body.collectItem(drop_item):
			queue_free()
	

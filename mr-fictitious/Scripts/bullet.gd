"""
Script for items, for now they dissapear when walking over them
Authors: Jose Leyba
Creation Date: 03/27/2025
Revisions:
	[format: date - name, what you revised]
"""
extends Area2D
@export var drop_item:InventoryItem;
@onready var bulletResource = preload("res://Resources/bullet.tres")




func _on_body_entered(body: Node2D) -> void:
	print("Body entered:", body.name)
	if body.name == "Player":
		body.collectItem(bulletResource)
		body.add_bullet()
		queue_free()


	

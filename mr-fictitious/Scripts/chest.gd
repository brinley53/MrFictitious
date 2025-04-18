"""
Chest that drops a random amount of items
Authors: Jose Leyba, Brinley Hull
Creation Date: 04/17/2025
Revisions:

"""
extends Area2D

@export var bullet_scene: PackedScene = preload("res://Scenes/bullet.tscn")
@export var health_scene: PackedScene = preload("res://Scenes/health_item.tscn")
@export var speed_scene: PackedScene = preload("res://Scenes/speed_item.tscn")
@export var damage_scene: PackedScene = preload("res://Scenes/damage_item.tscn")

@onready var sprite = $Sprite2D
var opened = false


func _on_body_entered(body: Node2D) -> void:
	if opened or body.name != "Player":
		return

	opened = true
	spawn_random_loot()
	#sprite.texture = preload("res://Sprites/chest_open.png") 
	queue_free()
	

func spawn_random_loot():
	opened = true
	#sprite.texture = open_texture

	var loot_options = [bullet_scene, health_scene, speed_scene]
	var num_loot = randi_range(1, 6)

	for i in range(num_loot):
		var item_scene = loot_options[randi() % loot_options.size()]
		var item = item_scene.instantiate()

		var angle = randf() * TAU 
		var radius = randf_range(128.0, 256.0)
		var offset = Vector2(cos(angle), sin(angle)) * radius

		item.global_position = global_position + offset
		get_tree().current_scene.add_child(item)

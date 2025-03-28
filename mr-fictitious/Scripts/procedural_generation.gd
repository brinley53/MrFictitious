"""
File to control procedural generation for items, rooms, enemies, etc.
Authors: Brinley Hull [add your name as you work on it]
Creation Date: 3/27/2025
Revisions:
	[format: date - name, what you revised]
"""

extends Node2D

@export var enemy_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Generate all items, enemies, rooms, etc here
	generate_enemies()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func generate_enemies():
	# Function to procedurally generate enemies in the scene
	var rand = RandomNumberGenerator.new()
	for i in range(3): # How many enemies to spawn
		var enemy = enemy_scene.instantiate()
		
		# Randomly position and place enemy. Change range to fit screen/valid spaces
		var spawn_x = rand.randi_range(100, 1000)
		var spawn_y = rand.randi_range(100, 1000)
		enemy.position = Vector2(spawn_x, spawn_y)
		
		add_child(enemy) # Add enemy to scene
		

"""
File to control procedural generation for items, rooms, enemies, etc.
Authors: Brinley Hull, Tej Gumaste
Creation Date: 3/27/2025
Revisions:
	Tej Gumaste - 3/27/2025:
	- Added item generation for generic item(sprite coin) and key item(godot sprite)
	- Added rudimentary logic to ensure spawned objects don't completely overlap
	Brinley Hull - 3/30/2025: commented out enemy procedural generation (for now)
	Sean Hammell - 4/2/2025: Added room layout logic
	Sean Hammell - 4/3/2025: Moved room layout logic to room_manager.gd
"""

extends Node2D

@export var enemy_scene: PackedScene

@export var generic_item:PackedScene
@export var key_item:PackedScene
@export var num_generic_item:int = 5
@export var num_key_item:int = 3
@export var health_item:PackedScene
@export var num_health_items:int = 4
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Generate all items, enemies, rooms, etc here
	#generate_rooms()
	#generate_objects(enemy_scene,3)
	generate_objects(generic_item,num_generic_item)
	generate_objects(key_item,num_key_item)
	generate_objects(health_item,num_health_items)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func generate_objects(objectScene:PackedScene,count:int):
	# Function to procedurally generate enemies in the scene
	var space_state = get_world_2d().direct_space_state
	var rand = RandomNumberGenerator.new()
	for i in range(count): # How many enemies to spawn
		var object = objectScene.instantiate()
		var foundSpot:bool = false
		var spawn_x;
		var spawn_y;
		while(!foundSpot):
		# Randomly position and place enemy. Change range to fit screen/valid spaces
			spawn_x = rand.randi_range(100, 1000)
			spawn_y = rand.randi_range(100, 1000)
			var query = PhysicsPointQueryParameters2D.new()
			query.collide_with_bodies = true
			query.position = Vector2(spawn_x, spawn_y)
			var result = space_state.intersect_point(query)
			if(result.is_empty()):
				foundSpot=true
		
		object.position = Vector2(spawn_x, spawn_y)
		add_child(object) # Add enemy to scene
	

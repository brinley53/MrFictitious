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
"""

extends Node2D

const ROOM_SCENES:Array[Resource] = [
	preload("res://Scenes/Rooms/Prototype1/room_1.tscn"),
	preload("res://Scenes/Rooms/Prototype1/room_2.tscn"),
	preload("res://Scenes/Rooms/Prototype1/room_3.tscn"),
	preload("res://Scenes/Rooms/Prototype1/room_4.tscn")
]

@export var enemy_scene: PackedScene

@export var generic_item:PackedScene
@export var key_item:PackedScene
@export var num_generic_item:int = 5
@export var num_key_item:int = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Generate all items, enemies, rooms, etc here
	#generate_rooms()
	#generate_objects(enemy_scene,3)
	generate_objects(generic_item,num_generic_item)
	generate_objects(key_item,num_key_item)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func generate_rooms() -> void:
	# Declare the arrays that we're about to start doing
	# some VERY questionable things with.
	var instances:Array[Node2D]
	var unattached:Array[int]
	var unexplored:Array[int]

	# Initialize all the rooms.
	# Rooms begin their lives invisible and unattached.
	# (Relatable, am I right?)
	for i in range(ROOM_SCENES.size()):
		instances.append(ROOM_SCENES[i].instantiate())
		add_child(instances[i])
		instances[i].set_visible(false)
		unattached.append(i)

	# Select a random room to serve as the anchor and move it from
	# unattached to unexplored.
	#
	# Here's a good spot to talk about unattached vs. unexplored:
	# - Unattached means a room is not linked to any other rooms.
	# - Unexplored means a room is linked to another room but has
	#   not made links of its own.
	var random:RandomNumberGenerator = RandomNumberGenerator.new()
	var start:int = random.randi_range(0, unattached.size() - 1)
	instances[start].set_visible(true)
	unattached.remove_at(start)
	unexplored.append(start)

	while unattached.size() > 0:
		# Pick a random, unexplored room to... explore.
		var explore:int = random.randi_range(0, unexplored.size() - 1)
		var source:int = unexplored[explore]

		# Pick a random number of rooms to link to this one.
		# There can only be a maximum of three NEW attachments because all
		# rooms will have a previous link (the anchor is linked to whatever
		# scene brought us to this area).
		var attachments:int = random.randi_range(1, Room.PathDirection.COUNT - 2)
		for i in attachments:
			# Break if we attempt to make more attachments
			# than we have unattached rooms.
			if unattached.size() == 0:
				break

			var direction:Room.PathDirection
			while true:
				# Find an random, open direction to link on.
				# Consider this fully optimized. There is nothing faster than
				# a while loop that breaks on a random condition.
				direction = random.randi_range(0, Room.PathDirection.COUNT - 1) as Room.PathDirection
				if instances[source].is_path_available(direction):
					break

			# Pick a random room from the list of unattached rooms to link
			# to the destination room from the source room.
			var attach:int = random.randi_range(0, unattached.size() - 1)
			var destination:int = unattached[attach]
			instances[source].attach_room(direction, destination)

			# Link to the source room from the destination room so things don't
			# get weird when it's this destination's turn to be a source.
			var opposite_direction:int = (direction / 2) + (1 - (direction % 2))
			instances[destination].attach_room(opposite_direction, source)

			# The destination is now unexplored.
			unattached.remove_at(attach)
			unexplored.append(destination)

		# The source is now explored.
		unexplored.remove_at(explore)

	for instance in instances:
		instance.set_edges()

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
	

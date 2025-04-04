"""
Creation Date: 04/03/2025
Revisions:
	Sean Hammell - Added room generation logic
	Brinley Hull - 4/4/2025, fix left transition
"""
extends Node2D

enum PathDirection {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	COUNT
}

const ROOM_SCENES:Array[PackedScene] = [
	preload("res://Scenes/Rooms/Prototype1/room_1.tscn"),
	preload("res://Scenes/Rooms/Prototype1/room_2.tscn"),
	preload("res://Scenes/Rooms/Prototype1/room_3.tscn"),
	preload("res://Scenes/Rooms/Prototype1/room_4.tscn")
]

const BLOCKING_EDGES:Array[PackedScene] = [
	preload("res://Scenes/Rooms/Prototype1/up_blocking_edge.tscn"),
	preload("res://Scenes/Rooms/Prototype1/down_blocking_edge.tscn"),
	preload("res://Scenes/Rooms/Prototype1/left_blocking_edge.tscn"),
	preload("res://Scenes/Rooms/Prototype1/right_blocking_edge.tscn")
]

var active_room_index:int = -1
var active_room:Node2D = null
var connections:Dictionary = {}
var blocking_edges:Array = []

func _ready() -> void:
	for direction in range(PathDirection.COUNT):
		blocking_edges.append(BLOCKING_EDGES[direction].instantiate())

func set_active_room(index:int) -> void:
	# Delete the current active room.
	if active_room != null:
		remove_child(active_room)
		active_room.queue_free()
#
	# Add the new active room.
	active_room_index = index
	active_room = ROOM_SCENES[index].instantiate()
	add_child(active_room)

	# Update the blocking edges.
	for direction in range(PathDirection.COUNT):
		if connections[index][direction] != null and blocking_edges[direction].is_inside_tree():
			remove_child(blocking_edges[direction])
		elif connections[index][direction] == null and not blocking_edges[direction].is_inside_tree():
			add_child(blocking_edges[direction])

func add_connection_entry(index:int) -> void:
	if connections.has(index):
		print("Attempted to add duplicate room: %" % index)
		return

	# Add an empty connection entry for the room.
	connections[index] = {
		PathDirection.UP: null,
		PathDirection.DOWN: null,
		PathDirection.LEFT: null,
		PathDirection.RIGHT: null
	}

func generate_rooms() -> void:
	# Declare the arrays that we're about to start doing
	# some VERY questionable things with.
	var unattached:Array[int]
	var unexplored:Array[int]

	# All of the rooms begin unattached.
	for i in range(ROOM_SCENES.size()):
		unattached.append(i)

	# Select a random room to serve as the anchor and move it from
	# unattached to unexplored.
	#
	# Here's a good spot to talk about unattached vs. unexplored:
	# - Unattached means a room is not linked to any other rooms.
	# - Unexplored means a room is linked to another room but has
	#   not made links of its own.
	var random:RandomNumberGenerator = RandomNumberGenerator.new()
	var start:int = unattached[random.randi_range(0, unattached.size() - 1)]
	unattached.erase(start)
	unexplored.append(start)
	add_connection_entry(start)

	while unattached.size() > 0:
		# Pick a random, unexplored room to... explore.
		var source:int = unexplored[random.randi_range(0, unexplored.size() - 1)]

		# Pick a random number of rooms to link to this one.
		# There can only be a maximum of three NEW attachments because all
		# rooms will have a previous link (the anchor is linked to whatever
		# scene brought us to this area).
		var attachments:int = random.randi_range(1, PathDirection.COUNT - 2)
		for i in attachments:
			# Break if we attempt to make more attachments
			# than we have unattached rooms.
			if unattached.size() == 0:
				break

			var direction:PathDirection
			while true:
				# Find an random, open direction to link on.
				# Consider this fully optimized. There is nothing faster than
				# a while loop that breaks on a random condition.
				direction = random.randi_range(0, PathDirection.COUNT - 1) as PathDirection
				if connections[source][direction] == null:
					break

			# Pick a random room from the list of unattached rooms to link
			# to the destination room from the source room.
			var destination:int = unattached[random.randi_range(0, unattached.size() - 1)]
			connections[source][direction] = destination

			# Link to the source room from the destination room so things don't
			# get weird when it's this destination's turn to be a source.
			var opposite_direction:int = ((direction / 2) * 2) + (1 - (direction % 2))
			add_connection_entry(destination)
			connections[destination][opposite_direction] = source

			# The destination is now unexplored.
			unattached.erase(destination)
			unexplored.append(destination)

		# The source is now explored.
		unexplored.erase(source)

	# Activate the starting room now
	# that we have edge information.
	set_active_room(start)

func _on_path_up_body_entered(body: Node2D) -> void:
	if is_instance_of(body, Player):
		var destination = connections[active_room_index][PathDirection.UP]
		if destination != null:
			set_active_room(destination)
			body.position.y = get_viewport_rect().size.y - body.get_size().y

func _on_path_down_body_entered(body: Node2D) -> void:
	if is_instance_of(body, Player):
		var destination = connections[active_room_index][PathDirection.DOWN]
		if destination != null:
			set_active_room(destination)
			body.position.y = body.get_size().y

func _on_path_left_body_entered(body: Node2D) -> void:
	if is_instance_of(body, Player):
		var destination = connections[active_room_index][PathDirection.LEFT]
		if destination != null:
			set_active_room(destination)
			body.position.x = get_viewport_rect().size.x - body.get_size().x * 2

func _on_path_right_body_entered(body: Node2D) -> void:
	if is_instance_of(body, Player):
		var destination = connections[active_room_index][PathDirection.RIGHT]
		if destination != null:
			set_active_room(destination)
			body.position.x = body.get_size().x * 2

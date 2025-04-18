"""
Creation Date: 04/03/2025
Revisions:
	Sean Hammell - Added room generation logic
	Brinley Hull - 4/4/2025, fix left transition
"""
extends Node2D

enum Location {
	CENTRAL,
	FOREST,
	CRYPT,
	COUNT
}

enum Direction {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	COUNT
}

const DIRECTION_FROM_CENTRAL:Dictionary = {
	Location.FOREST: Direction.DOWN,
	Location.CRYPT: Direction.LEFT
}

const ROOMS:Dictionary = {
	Location.CENTRAL: [
		preload("res://Scenes/Rooms/central_room.tscn")
	],
	Location.FOREST: [
		preload("res://Scenes/Rooms/Forest/room_1.tscn"),
		preload("res://Scenes/Rooms/Forest/room_2.tscn"),
		preload("res://Scenes/Rooms/Forest/room_3.tscn"),
		preload("res://Scenes/Rooms/Forest/room_4.tscn"),
		preload("res://Scenes/Rooms/Forest/room_5.tscn"),
		preload("res://Scenes/Rooms/Forest/room_6.tscn"),
		preload("res://Scenes/Rooms/Forest/room_7.tscn"),
		preload("res://Scenes/Rooms/Forest/room_8.tscn")
	],
	Location.CRYPT: [
		preload("res://Scenes/Rooms/Crypt/room_1.tscn"),
		preload("res://Scenes/Rooms/Crypt/room_2.tscn"),
		preload("res://Scenes/Rooms/Crypt/room_3.tscn"),
		preload("res://Scenes/Rooms/Crypt/room_4.tscn")
	],
}

const EDGES:Dictionary = {
	Location.CENTRAL: [
		preload("res://Scenes/Rooms/Forest/up_blocking_edge.tscn"),
		preload("res://Scenes/Rooms/Forest/down_blocking_edge.tscn"),
		preload("res://Scenes/Rooms/Forest/left_blocking_edge.tscn"),
		preload("res://Scenes/Rooms/Forest/right_blocking_edge.tscn")
	],
	Location.FOREST: [
		preload("res://Scenes/Rooms/Forest/up_blocking_edge.tscn"),
		preload("res://Scenes/Rooms/Forest/down_blocking_edge.tscn"),
		preload("res://Scenes/Rooms/Forest/left_blocking_edge.tscn"),
		preload("res://Scenes/Rooms/Forest/right_blocking_edge.tscn")
	],
	Location.CRYPT: [
		preload("res://Scenes/Rooms/Crypt/up_blocking_edge.tscn"),
		preload("res://Scenes/Rooms/Crypt/down_blocking_edge.tscn"),
		preload("res://Scenes/Rooms/Crypt/left_blocking_edge.tscn"),
		preload("res://Scenes/Rooms/Crypt/right_blocking_edge.tscn")
	]
}

var active_location:Location
var active_room:int

var rooms:Dictionary
var edges:Dictionary

var connections:Dictionary

func _ready() -> void:
	# Start in the Central room.
	active_location = Location.CENTRAL
	active_room = 0
	rooms[Location.CENTRAL] = [ROOMS[Location.CENTRAL][0].instantiate()]
	add_connection_entry(Location.CENTRAL, 0)

	# Instantiate the rooms and edges for each location.
	for location in range(Location.COUNT):
		edges[location] = []
		for edge in EDGES[location]:
			edges[location].append(edge.instantiate())

		# The Central room is taken care of above.
		if location == Location.CENTRAL:
			continue

		rooms[location] = []
		for room in ROOMS[location]:
			rooms[location].append(room.instantiate())

func set_active_room(location:Location, room:int) -> void:
	# Remove the old active room.
	remove_child(rooms[active_location][active_room])

	# Remove the old active room's edges.
	for direction in range(Direction.COUNT):
		remove_child(edges[active_location][direction])

	# Add the new active room.
	active_location = location
	active_room = room
	add_child(rooms[active_location][active_room])

	# Update the new active room's edges.
	for direction in range(Direction.COUNT):
		if connections[active_location][active_room][direction]["room"] == null:
			add_child(edges[active_location][direction])

func add_connection_entry(location:Location, room:int) -> void:
	# Add an entry for the location if one isn't present.
	if not connections.has(location):
		connections[location] = {}

	# Check for duplicate connection requests.
	if connections[location].has(room):
		print("Attempted to add duplicate room %s in location %s" % [room, location])
		return

	# Add an empty connection entry for the room.
	connections[location][room] = {
		Direction.UP: {
			"location": Location.COUNT,
			"room": null
		},
		Direction.DOWN: {
			"location": Location.COUNT,
			"room": null
		},
		Direction.LEFT: {
			"location": Location.COUNT,
			"room": null
		},
		Direction.RIGHT: {
			"location": Location.COUNT,
			"room": null
		}
	}

func create_connection(source_location:Location, source_room:int, destination_location:Location, destination_room:int, direction:Direction):
		# Record the source to destination connection.
		connections[source_location][source_room][direction]["location"] = destination_location
		connections[source_location][source_room][direction]["room"] = destination_room

		# Record the destination to source connection.
		# Intentional integer division.
		var opposite_direction:int = ((direction / 2) * 2) + (1 - (direction % 2))
		connections[destination_location][destination_room][opposite_direction]["location"] = source_location
		connections[destination_location][destination_room][opposite_direction]["room"] = source_room

func generate_rooms() -> void:
	for location in range(Location.COUNT):
		# Skip Central since those connections are hardcoded.
		if location == Location.CENTRAL:
			continue

		# Declare the arrays that we're about to start doing
		# some VERY questionable things with.
		var unattached:Array[int]
		var unexplored:Array[int]

		# All of the rooms begin unattached.
		for i in range(ROOMS[location].size()):
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
		add_connection_entry(location, start)
	
		# Connect the anchor room of the location to Central.
		create_connection(Location.CENTRAL, 0, location, start, DIRECTION_FROM_CENTRAL[location])

		while unattached.size() > 0:
			# Pick a random, unexplored room to... explore.
			var source:int = unexplored[random.randi_range(0, unexplored.size() - 1)]

			# Pick a random number of rooms to link to this one.
			# There can only be a maximum of three NEW attachments because all
			# rooms will have a previous link (the anchor is linked to Central).
			var attachments:int = random.randi_range(1, Direction.COUNT - 2)
			for i in attachments:
				# Break if we attempt to make more attachments
				# than we have unattached rooms.
				if unattached.size() == 0:
					break

				var direction:Direction
				while true:
					# Find an random, open direction to link on.
					# Consider this fully optimized. There is nothing faster than
					# a while loop that breaks on a random condition.
					direction = random.randi_range(0, Direction.COUNT - 1) as Direction
					if connections[location][source][direction]["room"] == null:
						break

				# Pick a random room from the list of unattached rooms to link
				# to the destination room from the source room.
				var destination:int = unattached[random.randi_range(0, unattached.size() - 1)]
				add_connection_entry(location, destination)
				create_connection(location, source, location, destination, direction)

				# The destination is now unexplored.
				unattached.erase(destination)
				unexplored.append(destination)

			# The source is now explored.
			unexplored.erase(source)

	# Activate the Central room now that the connections
	# are populated.
	set_active_room(Location.CENTRAL, 0)

func _on_path_up_body_entered(body: Node2D) -> void:
	if is_instance_of(body, Player):
		var destination = connections[active_location][active_room][Direction.UP]
		if destination["room"] != null:
			set_active_room(destination["location"], destination["room"])
			body.position.y = get_viewport_rect().size.y - body.get_size().y*2

func _on_path_down_body_entered(body: Node2D) -> void:
	if is_instance_of(body, Player):
		var destination = connections[active_location][active_room][Direction.DOWN]
		if destination["room"] != null:
			set_active_room(destination["location"], destination["room"])
			body.position.y = body.get_size().y

func _on_path_left_body_entered(body: Node2D) -> void:
	if is_instance_of(body, Player):
		var destination = connections[active_location][active_room][Direction.LEFT]
		if destination["room"] != null:
			set_active_room(destination["location"], destination["room"])
			body.position.x = get_viewport_rect().size.x - body.get_size().x * 2

func _on_path_right_body_entered(body: Node2D) -> void:
	if is_instance_of(body, Player):
		var destination = connections[active_location][active_room][Direction.RIGHT]
		if destination["room"] != null:
			set_active_room(destination["location"], destination["room"])
			body.position.x = body.get_size().x * 2

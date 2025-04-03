class_name Room
extends Node2D

enum PathDirection {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	COUNT
}

const BLOCKING_EDGES:Array[Resource] = [
	preload("res://Scenes/Rooms/Prototype1/up_blocking_edge.tscn"),
	preload("res://Scenes/Rooms/Prototype1/down_blocking_edge.tscn"),
	preload("res://Scenes/Rooms/Prototype1/left_blocking_edge.tscn"),
	preload("res://Scenes/Rooms/Prototype1/right_blocking_edge.tscn")
]

var paths:Array[Dictionary] = [
	{
		"in_use": false,
		"leads_to": -1,
		"edge_node": null
	},
	{
		"in_use": false,
		"leads_to": -1,
		"edge_node": null
	},
	{
		"in_use": false,
		"leads_to": -1,
		"edge_node": null
	},
	{
		"in_use": false,
		"leads_to": -1,
		"edge_node": null
	},
]

func is_path_available(direction:PathDirection) -> bool:
	if direction > -1 and direction < PathDirection.COUNT:
		return !paths[direction]["in_use"]
	return false

func attach_room(direction:PathDirection, id:int) -> void:
	if direction > -1 and direction < PathDirection.COUNT:
		paths[direction]["in_use"] = true
		paths[direction]["leads_to"] = id
		# TODO
		# Create an instance of the appropriate edge
		# Add the instance as a child of the room scene
		# paths[direction]["edge_node"] = instance

func set_edges() -> void:
	for i in range(PathDirection.COUNT):
		if paths[i]["in_use"]:
			# Add open edge
			continue
		else:
			add_child(BLOCKING_EDGES[i].instantiate())

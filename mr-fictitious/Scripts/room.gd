class_name Room
extends Node2D

enum PathDirection {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	COUNT
}

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
		paths[direction]["blocked"] = false
		paths[direction]["leads_to"] = id
		# TODO
		# Create an instance of the appropriate edge
		# Add the instance as a child of the room scene
		# paths[direction]["edge_node"] = instance

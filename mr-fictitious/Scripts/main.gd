extends Node

#const RoomManager = preload("res://Scripts/room_manager.gd")
#
#func _ready():
	#var room_manager = RoomManager.new()
	#add_child(room_manager)
	#room_manager.generate_rooms()

const TEST_AREA = preload("res://Scenes/test_area.tscn")

func _ready():
	var tile_map = TEST_AREA.instantiate()
	add_child(tile_map)

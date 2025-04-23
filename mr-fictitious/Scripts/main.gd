extends Node

const RoomManager:PackedScene = preload("res://Scenes/room_manager.tscn")

@onready var player:Player = $Player
@onready var menu = $PauseMenu/CanvasLayer

func _ready():
	var room_manager = RoomManager.instantiate()
	add_child(room_manager)
	room_manager.receive_player(player)
	room_manager.generate_rooms()
	
func _process(delta):
	if Input.is_action_just_pressed("pause"):
		menu.show()
		get_tree().paused = true

#const TEST_AREA = preload("res://Scenes/test_area.tscn")
#
#func _ready():
	#var tile_map = TEST_AREA.instantiate()
	#add_child(tile_map)

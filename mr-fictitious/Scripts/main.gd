extends Node

const TEST_AREA = preload("res://Scenes/test_area.tscn")

func _ready():
	var tile_map = TEST_AREA.instantiate()
	add_child(tile_map)

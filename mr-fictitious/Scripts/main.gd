extends Node

#const ProceduralGeneration = preload("res://Scripts/procedural_generation.gd")
#
#func _ready():
	#var generator = ProceduralGeneration.new()
	#add_child(generator)

const TEST_AREA = preload("res://Scenes/test_area.tscn")

func _ready():
	var tile_map = TEST_AREA.instantiate()
	add_child(tile_map)

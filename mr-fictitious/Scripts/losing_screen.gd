extends Control

func _on_reload_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _hard_reset():
	get_tree().root.free()
	var new_scene = load("res://Scenes/main.tscn").instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene


func _on_button_2_pressed() -> void:
	get_tree().quit()


	
func _on_tree_entered() -> void:
	print("Put in scene")

	

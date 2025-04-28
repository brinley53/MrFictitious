extends Control


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/opening_dialogue.tscn")


func _on_button_2_pressed() -> void:
	get_tree().quit()


func _on_glossary_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/enemy_glossary.tscn")

	
func _on_tree_entered() -> void:
	print("Put in scene")

	

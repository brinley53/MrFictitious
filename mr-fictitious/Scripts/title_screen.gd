extends Control

func _on_button_pressed() -> void:
	TitleMusicScene.stop_music(self)
	get_tree().change_scene_to_file("res://Scenes/opening_dialogue.tscn")

func _on_controls_pressed() -> void:
	Wwise.post_event_id(AK.EVENTS.MENU_CLICK,self)
	get_tree().change_scene_to_file("res://Scenes/controls.tscn")
	
func _on_button_2_pressed() -> void:
	Wwise.post_event_id(AK.EVENTS.MENU_CLICK,self)
	get_tree().quit()


func _on_glossary_pressed() -> void:
	Wwise.post_event_id(AK.EVENTS.MENU_CLICK,self)
	get_tree().change_scene_to_file("res://Scenes/enemy_glossary.tscn")

func _on_tree_entered() -> void:
	TitleMusicScene.play_music(self)
	print("Put in scene")
	

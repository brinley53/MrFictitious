extends Control

func _on_reload_pressed() -> void:
	TitleMusicScene.stop_music(self)
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _hard_reset():
	get_tree().root.free()
	var new_scene = load("res://Scenes/main.tscn").instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene


func _on_button_pressed() -> void:
	pass


func _on_button_2_pressed() -> void:
	get_tree().quit()


#func _on_focus_entered() -> void:
	#Wwise.register_game_obj(self,self.name)
	#Wwise.register_listener(self)
	#print("Put in scene")
	#TitleMusicScene.play_music(self)


func _on_tree_entered() -> void:
	Wwise.register_game_obj(self,self.name)
	Wwise.register_listener(self)
	print("Put in scene")
	TitleMusicScene.play_music(self)
	Wwise.post_event_id(AK.EVENTS.PLAYER_DEATH, self)

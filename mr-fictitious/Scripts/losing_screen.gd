extends Control
@export var PlayMusic:WwiseEvent
@export var playTitle:WwiseEvent
@export var playAgain:WwiseEvent
func _on_button_pressed() -> void:
	pass


func _on_button_2_pressed() -> void:
	get_tree().quit()


	
func _on_tree_entered() -> void:
	Wwise.register_game_obj(self,self.name)
	Wwise.register_listener(self)
	Wwise.load_bank_id(AK.BANKS.MUSIC)
	Wwise.load_bank_id(AK.BANKS.SOUND)
	PlayMusic.post(self)
	playTitle.post(self)
	playAgain.post(self)
	print("Put in scene")
	


func _on_tree_exiting() -> void:
	
	PlayMusic.stop(self,200,AkUtils.AK_CURVE_LINEAR)
	playTitle.stop(self,200,AkUtils.AK_CURVE_LINEAR)
	playAgain.stop(self,200,AkUtils.AK_CURVE_LINEAR)
	Wwise.unregister_game_obj(self)
	Wwise.unload_bank_id(AK.BANKS.SOUND)
	Wwise.unload_bank_id(AK.BANKS.MUSIC)
	print("Exiting objects")
	pass # Replace with function body.


func _on_reload_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/opening_dialogue.tscn")

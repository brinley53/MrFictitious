extends Control

@export var PlayMusic:WwiseEvent
@export var playTitle:WwiseEvent
@export var playAgain:WwiseEvent


func _on_reload_pressed() -> void:
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


	
func _on_tree_entered() -> void:
	print("Put in scene")

	
	PlayMusic.stop(self,200,AkUtils.AK_CURVE_LINEAR)
	playTitle.stop(self,200,AkUtils.AK_CURVE_LINEAR)
	playAgain.stop(self,200,AkUtils.AK_CURVE_LINEAR)
	Wwise.unregister_game_obj(self)
	Wwise.unload_bank_id(AK.BANKS.SOUND)
	Wwise.unload_bank_id(AK.BANKS.MUSIC)
	print("Exiting objects")
	pass # Replace with function body.

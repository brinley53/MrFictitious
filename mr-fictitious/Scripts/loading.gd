'''
Script for loading screen logic.
Authors: Brinley Hull
Creation date: 4/29/2025
Revisions:
'''

extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Wwise.register_game_obj(self,self.name)
	#Wwise.register_listener(self)
	TitleMusicScene.play_loading_music()
	Wwise.post_event_id(AK.EVENTS.LOADING_START, self)
	await get_tree().process_frame  # Wait one frame so loading screen appears
	get_tree().change_scene_to_file("res://Scenes/main.tscn")




func _on_tree_exiting() -> void:
	TitleMusicScene.stop_loading_music()
	Wwise.post_event_id(AK.EVENTS.LOADING_END, self)
	#Wwise.unregister_game_obj(self)

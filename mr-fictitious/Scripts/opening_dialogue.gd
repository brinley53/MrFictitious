'''
Script for the opening dialogue
Authors: Brinley Hull
Creation Date: 04/27/2025
Revisions:
'''

extends Node2D

@onready var dialogue_manager = $DialogueManager


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialogue_manager.connect("dialogue_ended", Callable(self, "_on_dialogue_finished"))
	dialogue_manager.show_dialogue_balloon(load("res://dialogue.dialogue"), "opening", [], "res://Dialogue/balloon_no_portrait.tscn")

func _on_dialogue_finished(_resource: DialogueResource):
	get_tree().change_scene_to_file("res://Scenes/loading.tscn")
	
func _input(_event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_ENTER):
		get_tree().change_scene_to_file("res://Scenes/loading.tscn")

	

extends CharacterBody2D
@onready var dialogue_manager = $DialogueManager
@onready var dialogue = preload("res://shovel.dialogue")
var in_enter_area := false

func _process(delta):
	if in_enter_area and Input.is_action_just_pressed("attack"):
		dialogue_manager.show_dialogue_balloon(dialogue, "start")

func _on_enter_area_body_entered(body: Node2D) -> void:
	if body.name == "Player": 
		in_enter_area = true

func _on_enter_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		in_enter_area = false

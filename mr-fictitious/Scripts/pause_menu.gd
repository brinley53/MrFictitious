extends Node2D
@onready var menu = $CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu.hide()
	hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	menu.hide()
	get_tree().paused = false

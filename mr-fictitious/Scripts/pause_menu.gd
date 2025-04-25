extends Control
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


func _on_glossary_pressed() -> void:
	$EnemyGlossary.show()


func _on_exit_pressed() -> void:
	get_tree().quit()

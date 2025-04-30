extends Control
@onready var menu = $CanvasLayer
#@onready var glossary = $EnemyGlossary
@onready var close_glossary = $ExitGlossary


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu.layer = 10000000000
	menu.hide()
	#glossary.hide()
	close_glossary.hide()
	hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	menu.hide()
	#glossary.hide()
	get_tree().paused = false


func _on_glossary_pressed() -> void:
	menu.hide()
	#glossary.show()
	close_glossary.show()


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_exit_glossary_pressed() -> void:
	close_glossary.hide()
	#glossary.hide()
	menu.show()


	

extends Control
@onready var menu = $CanvasLayer
@onready var glossary = $GlossaryGallery
@onready var close_glossary = $ExitGlossary

func _ready() -> void:
	menu.layer = 10
	menu.hide()
	close_glossary.hide()
	hide()

func _on_glossary_pressed() -> void:
	menu.hide()
	glossary.show()
	close_glossary.show()

func _on_exit_glossary_pressed() -> void:
	close_glossary.hide()
	glossary.hide()
	menu.show()


func _on_exit_pressed() -> void:
	get_tree().quit()

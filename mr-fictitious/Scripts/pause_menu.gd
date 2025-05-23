extends Control
@onready var menu = $CanvasLayer
#@onready var glossary = $GlossaryGallery
@onready var close_glossary = $ExitGlossary
var player:Player

func _ready() -> void:
	menu.layer = 10
	menu.hide()
	close_glossary.hide()
	hide()

func _on_glossary_pressed() -> void:
	Wwise.post_event_id(AK.EVENTS.MENU_CLICK,player)
	menu.hide()
	#glossary.show()
	close_glossary.show()

func _on_exit_glossary_pressed() -> void:
	Wwise.post_event_id(AK.EVENTS.MENU_CLICK,player)
	close_glossary.hide()
	#glossary.hide()
	menu.show()


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_resume_pressed() -> void:
	Wwise.post_event_id(AK.EVENTS.MENU_CLICK,player)
	get_tree().paused = false
	menu.hide()
	close_glossary.hide()
	hide()

func get_player(obj:Player):
	player = obj

func _on_main_menu_pressed() -> void:
	player.inventory.clear()
	player.weapon_inventory.clear()
	get_tree().change_scene_to_file("res://Scenes/title.tscn")

func _on_h_slider_value_changed(value: float) -> void:
	player.update_volume(value)

func _on_music_slider_value_changed(value: float):
	player.update_music_volume(value)

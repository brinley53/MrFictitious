extends Control


var is_open:bool;

func _ready() -> void:
	close()
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		if is_open:
			close()
		else:
			open()


func close():
	visible = false
	is_open=false

func open():
	visible=true
	is_open=true

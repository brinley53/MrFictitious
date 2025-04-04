extends Control


var is_open:bool;
@onready var playerinv:Inventory = preload("res://Resources/inventory.tres")
@onready var slots:Array = $NinePatchRect/GridContainer.get_children()
func _ready() -> void:
	playerinv.update.connect(updateSlots)
	updateSlots()
	close()
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		if is_open:
			close()
		else:
			open()

func updateSlots():
	for i in range(min(playerinv.slots.size(),slots.size())):
		slots[i].update(playerinv.slots[i])

func close():
	visible = false
	is_open=false

func open():
	visible=true
	is_open=true

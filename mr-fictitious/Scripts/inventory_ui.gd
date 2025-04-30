extends Control


var is_open:bool;

@onready var playerinv:Inventory = preload("res://Resources/inventory.tres")
@onready var slots:Array = $NinePatchRect/GridContainer.get_children()
@onready var slotBg:NinePatchRect = $NinePatchRect
var belt_sprites:Array[Texture2D]=[]
func _ready() -> void:
	for i in range(2,7):
		var texture = ResourceLoader.load("res://images/bandolierinventory%d.png"%i)
		belt_sprites.append(texture)
		
	playerinv.update.connect(updateSlots)
	updateSlots()
	close()
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		if is_open:
			close()
		else:
			open()

func updateSlots():
	for i in range(min(playerinv.slots.size(),slots.size())):
		if(i==playerinv.activeSlot):
			slotBg.texture=belt_sprites[i]
			print(belt_sprites[i].resource_name)
		slots[i].update(playerinv.slots[i])

func close():
	visible = false
	is_open=false

func open():
	visible=true
	is_open=true

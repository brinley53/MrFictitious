extends Control

var is_open: bool
var selected_weapon_slot: int = 0	# 0 for first weapon, 1 for second weapon

@onready var weapon_inv: Inventory = preload("res://Resources/weapon_inventory.tres")
@onready var weapon_slots: Array = $NinePatchRect/GridContainer.get_children()
@onready var slot_bg: NinePatchRect = $NinePatchRect

# Different background textures for weapon slots
var weapon_bg_textures: Array[Texture2D] = []

func _ready() -> void:
	# Load background textures for weapon slots
	for i in range(2):
		var texture = ResourceLoader.load("res://images/weapon_slot_bg%d.png" % (i + 1))
		if texture:
			weapon_bg_textures.append(texture)
	
	# Connect signals and initialize
	weapon_inv.update.connect(update_weapon_slots)
	update_weapon_slots()
	close()
	
	# Hide extra slots (since we only need 2 for weapons)
	for i in range(2, weapon_slots.size()):
		weapon_slots[i].visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		if is_open:
			close()
		else:
			open()
	

func update_weapon_slots():
	# Update the background to highlight selected weapon
	if weapon_bg_textures.size() > selected_weapon_slot:
		slot_bg.texture = weapon_bg_textures[selected_weapon_slot]
	
	# Update the weapon slots (only first 2)
	for i in range(min(weapon_inv.slots.size(), 2)):
		weapon_slots[i].update(weapon_inv.slots[i])
		
		# Highlight the selected weapon slot
		if i == selected_weapon_slot:
			weapon_slots[i].modulate = Color(1.2, 1.2, 1.2)	# Slightly brighter
		else:
			weapon_slots[i].modulate = Color(1, 1, 1)	# Normal color

func close():
	visible = false
	is_open = false

func open():
	visible = true
	is_open = true

# Function to get currently selected weapon
func get_current_weapon():
	if weapon_inv.slots.size() > selected_weapon_slot:
		return weapon_inv.slots[selected_weapon_slot]
	return null

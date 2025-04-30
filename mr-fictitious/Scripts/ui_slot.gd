extends Panel

@onready var itemvisual:Sprite2D = $CenterContainer/Panel/item_display
@onready var amountText: Label = $CenterContainer/Panel/Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
	
func update(slot:InventorySlot):
	if !slot.item:
		itemvisual.visible = false
		amountText.visible = false
	else:
		itemvisual.visible = true
		amountText.visible = true
		itemvisual.texture = slot.item.texture
		amountText.text = str(slot.amount)

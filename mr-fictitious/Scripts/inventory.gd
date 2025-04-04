extends Resource

class_name Inventory

@export var slots:Array[InventorySlot];
signal update
func insert(item:InventoryItem):
	
	var itemSlots = slots.filter(func(slot): slot.item==item)
	if !itemSlots.is_empty():
		itemSlots[0].amount+=1
	else:
		print("Empty slots")
		var emptySlots = slots.filter(func(slot): slot.item==null)
		if !emptySlots.is_empty():
			emptySlots[0].item = item
			emptySlots[0].amount = 1
	update.emit()
		
		
		

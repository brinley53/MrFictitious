extends Resource

class_name Inventory

@export var slots:Array[InventorySlot];
signal update
func insert(item:InventoryItem):

	var itemFound:bool = false
	for i in range(slots.size()):
		if(slots[i].item == item):
			slots[i].amount+=1
			itemFound=true
			break
	if !itemFound:

		var emptyFound:bool = false
		for i in range(slots.size()):
			if !slots[i].item:
				slots[i].amount = 1
				slots[i].item = item;
				emptyFound = true
				break
		if emptyFound:
			update.emit()
			return true
		else:
			return false
	else:
		update.emit()
		return true

func remove(item:InventoryItem):
	var itemFound:bool = false
	for i in range(slots.size()):
		if(slots[i].item == item):
			slots[i].amount-=1
			itemFound=true
			if(slots[i].amount==0):
				slots[i].item = null
			break
	update.emit()
	return itemFound
		
		
		
		

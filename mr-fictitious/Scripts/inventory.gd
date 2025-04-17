extends Resource

class_name Inventory

@export var slots:Array[InventorySlot];
var activeSlot:int=0
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

func equipSlot(index:int):
	if(index-1 in range(0,slots.size())):
		activeSlot = index
		update.emit()

func use_item():
	if not slots[activeSlot]:
		return "NULL"
	return slots[activeSlot].item.action
	
		
		
		
		

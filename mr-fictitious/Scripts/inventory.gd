extends Resource

class_name Inventory

@export var slots:Array[InventorySlot];
#@export var evidence_inventory:Array[Evidence]
@export var evidenceSlots:Array[EvidenceSlot]
var activeSlot:int=0
signal update
signal evidence_update
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

func clear():
	for slot in slots:
		slot.item = null
		slot.amount = 0
	for slot in evidenceSlots:
		slot.item = null
	update.emit()

func equipSlot(index:int):
	print(index)
	if(index>=0 and index<slots.size()):
		activeSlot = index
		update.emit()

func use_item():
	if not slots[activeSlot] or not slots[activeSlot].item:
		return "NULL"
	return slots[activeSlot].item.action
	
func collect_evidence(evi:Evidence):
	insert_evidence(evi)
	
func insert_evidence(item:Evidence):
	if(evidenceSlots[0].item):
		evidenceSlots[0].amount+=1
	else:
		evidenceSlots[0].item = item
		evidenceSlots[0].amount=1
	evidence_update.emit()

func remove_evidence(item:Evidence):
	evidenceSlots[item.evidence_number-1].item = null
	evidence_update.emit()
	
	
		
		
		
		

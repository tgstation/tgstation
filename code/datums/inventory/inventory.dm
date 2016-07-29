/datum/inventory
	var/list/slots=list()

	var/volume=0 // Maximum volume of the inventory "bag", in cubic centimeters.
	var/currentWeight=0 // Current weight of the object, in CC
	var/variableSlots=0 // 0 = variable number of slots
	var/slot_type=/datum/inventory_slot

	var/event/on_item_added=new() // item, slot, inventory
	var/event/on_item_removed=new() // "

/datum/inventory/proc/addItem(var/obj/O)
	var/datum/inventory_slot/found
	for(var/datum/inventory_slot/S in slots)
		if(S.canAccept(O))
			found=S

	if(!found && variableSlots)
		found = addSlot(slot_type)

	if(found)
		found.setContent(O)

	return found.ID

/datum/inventory/proc/findObjectSlot(var/obj/O)
	for(var/datum/inventory_slot/S in slots)
		if(S.content == O)
			return S
	return null

/datum/inventory/proc/removeItem(var/obj/O)
	var/datum/inventory_slot/slot = findObjectSlot(O)
	if(slot)
		slot.clearContent()

/datum/inventory/proc/addSlot(var/slot_type)
	var/datum/inventory_slot/S = new slot_type(src)
	slots += S
	S.ID=slots.len
	return S

/datum/inventory/proc/removeSlot(var/datum/inventory_slot/S)
	slots -= S

// Used by the slots.
/datum/inventory/proc/swap(var/slotIDA, var/slotIDB)
	var/datum/inventory_slot/A=slots[slotIDA]
	var/datum/inventory_slot/B=slots[slotIDB]
	var/obj/O=A.clearContent()
	A.setContent(B.clearContent())
	B.setContent(O)


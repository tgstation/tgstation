/datum/inventory_slot
	var/ID
	var/obj/content
	var/datum/inventory_slot/swapsWith

/datum/inventory_slot/proc/canAccept(var/obj/O)
	return TRUE

/datum/inventory_slot/proc/setContent(var/obj/O)
	content=O

/datum/inventory_slot/proc/clearContent(var/obj/O)
	.=content
	content=null

/datum/hideout
	var/list/stored_items = list()

/datum/hideout/Destroy(force, ...)
	. = ..()
	for(var/obj/item/item as anything in stored_items)
		remove_item(item)

/datum/hideout/proc/add_item(obj/item/item)
	RegisterSignal(item, COMSIG_QDELETING, PROC_REF(remove_item))
	RegisterSignal(item, COMSIG_ITEM_PICKUP, PROC_REF(remove_item))
	stored_items += item

/datum/hideout/proc/remove_item(obj/item/item)
	UnregisterSignal(item, list(COMSIG_QDELETING, COMSIG_ITEM_PICKUP))
	stored_items -= item

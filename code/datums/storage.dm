/datum/storage
	var/atom/parent
				
	var/max_slots
	var/max_specific_storage
	var/max_total_storage

/datum/storage/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	src.parent = parent
	src.max_slots = max_slots
	src.max_specific_storage = max_specific_storage
	src.max_total_storage = max_total_storage

/datum/storage/Destroy()
	. = ..()
	parent = null


/datum/storage/proc/attempt_insert(obj/item/to_insert)
	message_admins("ATTEMPTED ITEM INSERTION: [to_insert.name] to [parent.name]")
	message_admins(to_insert.w_class > max_specific_storage ? "DID NOT PASS SPECIFIC STORAGE TEST" : "PASSED SPECIFIC STORAGE TEST")

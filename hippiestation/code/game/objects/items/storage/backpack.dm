/obj/item/storage/backpack/duffelbag	//hippie start, movement speed tweaks, remove slowdown from all main backpacks
	slowdown = 0

/obj/item/storage/backpack/duffelbag/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 21	//now has the space of a normal backpack

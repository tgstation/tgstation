/obj/item/crystal_destabilizer
	name = "Supermatter Destabilizer"
	desc = "Used for disrupting the fabric of the Crystal Matrix."
	icon = 'icons/obj/supermatter.dmi'
	icon_state = "destabilizer"
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE
	///The destabilizer is one use only
	var/filled = TRUE

/obj/item/crystal_stabilizer
	name = "Supermatter Stabilizer"
	desc = "Used when the Supermatter Matrix is starting to reach the destruction point."
	icon = 'icons/obj/supermatter.dmi'
	icon_state = "stabilizer"
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE
	///The stabilizer is one use only
	var/filled = TRUE

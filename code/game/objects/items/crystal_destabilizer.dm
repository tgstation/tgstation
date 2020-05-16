/obj/item/crystal_destabilizer
	name = "Supermatter Destabilizer"
	desc = "Used for disrupting the fabric of the Crystal Matrix."
	icon = 'icons/obj/supermatter.dmi'
	item_state = "destabilizer"
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE
	///The destabilizer is one use only
	var/filled = TRUE

/obj/item/crystal_destabilizer/Initialize()
	. = ..()

/obj/item/crystal_destabilizer/Destroy()
	return..()

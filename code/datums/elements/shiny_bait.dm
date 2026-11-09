///A component that gives fishing rod TRAIT_ROD_ATTRACT_SHINY_LOVERS when the attached item is used as bait.
/datum/element/shiny_bait

/datum/element/shiny_bait/Attach(obj/item/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ITEM_FISHING_ROD_SLOTTED, PROC_REF(on_fishing_rod_slotted))
	RegisterSignal(target, COMSIG_ITEM_FISHING_ROD_UNSLOTTED, PROC_REF(on_fishing_rod_unslotted))
	if(istype(target.loc, /obj/item/fishing_rod))
		ADD_TRAIT(target.loc, TRAIT_ROD_ATTRACT_SHINY_LOVERS, REF(src))
	else if(istype(target, /obj/item/fishing_rod))
		ADD_TRAIT(target, TRAIT_ROD_ATTRACT_SHINY_LOVERS, "[REF(src)]_rod")

/datum/element/shiny_bait/Detach(obj/item/source)
	UnregisterSignal(source, list(
		COMSIG_ITEM_FISHING_ROD_SLOTTED,
		COMSIG_ITEM_FISHING_ROD_UNSLOTTED,
	))
	if(istype(source.loc, /obj/item/fishing_rod))
		REMOVE_TRAIT(source.loc, TRAIT_ROD_ATTRACT_SHINY_LOVERS, REF(src))
	else if(istype(source, /obj/item/fishing_rod))
		REMOVE_TRAIT(source, TRAIT_ROD_ATTRACT_SHINY_LOVERS, "[REF(src)]_rod")
	return ..()

/datum/element/shiny_bait/proc/on_fishing_rod_slotted(datum/source, obj/item/fishing_rod/rod, slot)
	SIGNAL_HANDLER
	if(slot == ROD_SLOT_BAIT)
		ADD_TRAIT(rod, TRAIT_ROD_ATTRACT_SHINY_LOVERS, REF(source))

/datum/element/shiny_bait/proc/on_fishing_rod_unslotted(datum/source, obj/item/fishing_rod/rod, slot)
	SIGNAL_HANDLER
	if(slot == ROD_SLOT_BAIT)
		REMOVE_TRAIT(rod, TRAIT_ROD_ATTRACT_SHINY_LOVERS, REF(source))

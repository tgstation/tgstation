/obj/item/storage
	name = "storage"
	icon = 'icons/obj/storage.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	///bool to allow dumping items from the storage instead of
	var/rummage_if_nodrop = TRUE
	///max size of objects that will fit, given to the component
	var/storage_max_w_class = WEIGHT_CLASS_SMALL
	///max combined sizes of objects that will fit, given to the component
	var/storage_max_combined_w_class = 14
	///max number of objects that will fit, given to the component
	var/storage_max_items = 7
	///specific items and their subtypes this storage will hold and not hold (if the nulls are replaced with lists)
	var/list/storage_holdables = list(null, null)
	///component added to this object, use /concrete subtype please.
	var/component_type = /datum/component/storage/concrete

/obj/item/storage/get_dumping_location(obj/item/storage/source, mob/user)
	return src

/obj/item/storage/Initialize()
	. = ..()
	PopulateContents()
	AddComponent(component_type, storage_max_w_class, storage_max_combined_w_class, storage_max_items, storage_holdables)

/obj/item/storage/AllowDrop()
	return FALSE

/obj/item/storage/contents_explosion(severity, target)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			SSexplosions.high_mov_atom += contents
		if(EXPLODE_HEAVY)
			SSexplosions.med_mov_atom += contents
		if(EXPLODE_LIGHT)
			SSexplosions.low_mov_atom += contents

/obj/item/storage/canStrip(mob/who)
	. = ..()
	if(!. && rummage_if_nodrop)
		return TRUE

/obj/item/storage/doStrip(mob/who)
	if(HAS_TRAIT(src, TRAIT_NODROP) && rummage_if_nodrop)
		var/datum/component/storage/CP = GetComponent(/datum/component/storage)
		CP.do_quick_empty()
		return TRUE
	return ..()

/obj/item/storage/contents_explosion(severity, target)
	return
///Cyberboss says: "USE THIS TO FILL IT, NOT INITIALIZE OR NEW"
/obj/item/storage/proc/PopulateContents()
	return

/obj/item/storage/proc/emptyStorage()
	var/datum/component/storage/ST = GetComponent(/datum/component/storage)
	ST.do_quick_empty()

/obj/item/storage/Destroy()
	for(var/obj/important_thing in contents)
		if(!(important_thing.resistance_flags & INDESTRUCTIBLE))
			continue
		important_thing.forceMove(drop_location())
	return ..()

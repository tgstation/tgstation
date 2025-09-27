/obj/item/storage
	name = "storage"
	icon = 'icons/obj/storage/storage.dmi'
	abstract_type = /obj/item/storage
	w_class = WEIGHT_CLASS_NORMAL
	interaction_flags_click = ALLOW_RESTING | FORBID_TELEKINESIS_REACH
	action_slots = ALL
	/// Should we preload the contents of this type?
	/// BE CAREFUL, THERE'S SOME REALLY NASTY SHIT IN THIS TYPEPATH
	/// SANTA IS EVIL
	var/preload = FALSE
	/// What storage type to use for this item
	var/datum/storage/storage_type = /datum/storage

/obj/item/storage/Initialize(mapload)
	. = ..()

	create_storage(storage_type = storage_type)

	PopulateContents()

	for (var/obj/item/item in src)
		item.item_flags |= IN_STORAGE

/obj/item/storage/create_storage(
	max_slots,
	max_specific_storage,
	max_total_storage,
	list/canhold,
	list/canthold,
	storage_type,
)
	// If no type was passed in, default to what we already have
	storage_type ||= src.storage_type
	return ..()

///Use this to populate the contents of the storage
/obj/item/storage/proc/PopulateContents()
	PROTECTED_PROC(TRUE)

/obj/item/storage/contents_explosion(severity, target)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			SSexplosions.high_mov_atom += contents
		if(EXPLODE_HEAVY)
			SSexplosions.med_mov_atom += contents
		if(EXPLODE_LIGHT)
			SSexplosions.low_mov_atom += contents

/obj/item/storage/canStrip(mob/who)
	return TRUE

/obj/item/storage/doStrip(mob/who)
	if(HAS_TRAIT(src, TRAIT_NODROP))
		atom_storage.remove_all()
		return TRUE
	return ..()

/obj/item/storage/AllowDrop()
	return FALSE

///Drops all contents of this storage on the turf of its parent
/obj/item/storage/proc/emptyStorage()
	SHOULD_NOT_OVERRIDE(TRUE)

	atom_storage.remove_all()

/obj/item/storage/apply_fantasy_bonuses(bonus)
	. = ..()
	if(isnull(atom_storage)) // some abstract types of storage (yes i know) don't get a datum
		return

	atom_storage.max_slots = modify_fantasy_variable("max_slots", atom_storage.max_slots, round(bonus/2))
	atom_storage.max_total_storage = modify_fantasy_variable("max_total_storage", atom_storage.max_total_storage, round(bonus/2))
	LAZYSET(fantasy_modifications, "max_specific_storage", atom_storage.max_specific_storage)
	if(bonus >= 15)
		atom_storage.max_specific_storage = max(WEIGHT_CLASS_HUGE, atom_storage.max_specific_storage)
	else if(bonus >= 10)
		atom_storage.max_specific_storage = max(WEIGHT_CLASS_BULKY, atom_storage.max_specific_storage)
	else if(bonus <= -10)
		atom_storage.max_specific_storage = WEIGHT_CLASS_SMALL
	else if(bonus <= -15)
		atom_storage.max_specific_storage = WEIGHT_CLASS_TINY

/obj/item/storage/remove_fantasy_bonuses(bonus)
	. = ..()
	if(isnull(atom_storage)) // some abstract types of storage (yes i know) don't get a datum
		return

	atom_storage.max_slots = reset_fantasy_variable("max_slots", atom_storage.max_slots)
	atom_storage.max_total_storage = reset_fantasy_variable("max_total_storage", atom_storage.max_total_storage)
	var/previous_max_storage = LAZYACCESS(fantasy_modifications, "max_specific_storage")
	LAZYREMOVE(fantasy_modifications, "max_specific_storage")
	if(previous_max_storage)
		atom_storage.max_specific_storage = previous_max_storage

/// Returns a list of object types to be preloaded by our code
/// I'll say it again, be very careful with this. We only need it for a few things
/// Don't do anything stupid, please
/obj/item/storage/proc/get_types_to_preload()
	return

/obj/item/storage/used_in_craft(atom/result, datum/crafting_recipe/current_recipe)
	. = ..()
	// If we consumed in crafting, we should dump contents out before qdeling them.
	if(!is_type_in_list(src, current_recipe.parts))
		emptyStorage()

/// Removes an item or puts it in mouth from the contents, if any
/obj/item/storage/proc/quick_remove_item(obj/item/grabbies, mob/user, equip_to_mouth =  FALSE)
	var/obj/item/finger = locate(grabbies) in contents
	if(!finger)
		return
	if(!equip_to_mouth)
		if(atom_storage.remove_single(user, finger, drop_location()))
			user.put_in_hands(finger)
		return
	if(user.equip_to_slot_if_possible(finger, ITEM_SLOT_MASK, qdel_on_fail = FALSE, disable_warning = TRUE))
		finger.forceMove(user)
		return
	balloon_alert(user, "mouth is covered!")

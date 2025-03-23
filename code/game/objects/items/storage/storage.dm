/obj/item/storage
	name = "storage"
	icon = 'icons/obj/storage/storage.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	interaction_flags_click = ALLOW_RESTING|FORBID_TELEKINESIS_REACH
	action_slots = ALL
	/// Should we preload the contents of this type?
	/// BE CAREFUL, THERE'S SOME REALLY NASTY SHIT IN THIS TYPEPATH
	/// SANTA IS EVIL
	var/preload = FALSE
	/// What storage type to use for this item
	var/datum/storage/storage_type = /datum/storage

/obj/item/storage/Initialize(mapload)
	. = ..()

	var/datum/storage_config/initial_cofig = GLOB.initial_storage_config
	initial_cofig.reset()
	var/list/obj/item/items = PopulateContents(initial_cofig)

	//no hacking our way into the storages loc without going through `can_insert()` first
	if(contents.len)
		stack_trace("[contents.len] atoms were found inside storage before they could be inserted correctly")
		return INITIALIZE_HINT_QDEL

	//Create storage only after retriving the contents. This is done so `atom_storage` values are not modified
	//manually which is error prone. Either create a storage subtype with your specified values or use
	//datum/storage_config to compute these values automatically
	create_storage(storage_type = storage_type)

	//nothing to add
	if(!items)
		return
	if(!islist(items))
		items = list(items)
	if(!items.len)
		return

	//set them to allow all items for now as we compute these values from the contents
	var/pre_compute = FALSE
	if(initial_cofig.compute_max_total_weight)
		atom_storage.max_total_storage = INFINITY
		pre_compute = TRUE
	if(initial_cofig.compute_max_item_weight)
		atom_storage.max_specific_storage = INFINITY
		pre_compute = TRUE
	if(initial_cofig.compute_max_item_count)
		atom_storage.max_slots = items.len
		pre_compute = TRUE
	if(initial_cofig.contents_are_exceptions)
		atom_storage.exception_hold = null
	if(initial_cofig.whitelist_content_types)
		atom_storage.can_hold = null

	var/max_total_weight = 0
	var/max_item_weight = 0
	var/list/obj/item/type_paths = initial_cofig.contents_are_exceptions || initial_cofig.whitelist_content_types ? list() : null
	pre_compute |= !isnull(type_paths)

	//we now begin inserting these items the right way
	for(var/obj/item/insert as anything in items)
		if(ispath(insert))
			insert = new insert(null)

		//computing values from contents
		if(pre_compute)
			if(initial_cofig.compute_max_total_weight)
				max_total_weight += insert.w_class
			if(initial_cofig.compute_max_item_weight)
				max_item_weight = insert.w_class > max_item_weight ? insert.w_class : max_item_weight
			if(type_paths)
				type_paths |= insert.type

		if(!atom_storage.can_insert(insert, messages = STORAGE_ERROR_INSERT))
			. = INITIALIZE_HINT_QDEL //this thing was shoved inside & destroyed us. Fix your storage caps and try again
		insert.forceMove(src)

	if(!pre_compute || . == INITIALIZE_HINT_QDEL)
		return

	//assign computed values
	if(max_total_weight)
		atom_storage.max_total_storage = max_total_weight
	if(max_item_weight)
		atom_storage.max_specific_storage = max_item_weight
	if(type_paths)
		atom_storage.set_holdable(
			can_hold_list = initial_cofig.whitelist_content_types ? type_paths : atom_storage.can_hold,
			exception_hold_list = initial_cofig.contents_are_exceptions ? type_paths : atom_storage.exception_hold
		)

/obj/item/storage/create_storage(
	max_slots,
	max_specific_storage,
	max_total_storage,
	list/canhold,
	list/canthold,
	storage_type,
)
	if(!QDELETED(atom_storage))
		stack_trace("Cannot re initialize storage")
		return

	// If no type was passed in, default to what we already have
	storage_type ||= src.storage_type
	return ..()

/obj/item/storage/atom_deconstruct(disassembled)
	var/atom/drop_point = drop_location()
	for(var/obj/important_thing in contents)
		if(important_thing.resistance_flags & INDESTRUCTIBLE)
			important_thing.forceMove(drop_point)

/**
 * Returns a list of items(object typepaths or solid atoms) to be inserted into the storage
 * If you list contains solid atoms make sure they are created/moved in nullspace i.e. no bypassing storage
 * restrictions else this storage will self destruct with a stack trace
 * Arguments
 *
 * * datum/storage_config/config - the config used to set storage values based on the contents returned here
 */
/obj/item/storage/proc/PopulateContents(datum/storage_config/config)
	RETURN_TYPE(/list/obj/item)
	PROTECTED_PROC(TRUE)

	return NONE

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
	if(isnull(atom_storage)) // some abstract types of storage (yes i know) don't get a datum
		return ..()

	atom_storage.max_slots = reset_fantasy_variable("max_slots", atom_storage.max_slots)
	atom_storage.max_total_storage = reset_fantasy_variable("max_total_storage", atom_storage.max_total_storage)
	var/previous_max_storage = LAZYACCESS(fantasy_modifications, "max_specific_storage")
	LAZYREMOVE(fantasy_modifications, "max_specific_storage")
	if(previous_max_storage)
		atom_storage.max_specific_storage = previous_max_storage
	return ..()

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
	return TRUE

/obj/item/storage/doStrip(mob/who)
	if(HAS_TRAIT(src, TRAIT_NODROP))
		atom_storage.remove_all()
		return TRUE
	return ..()

/obj/item/storage/proc/emptyStorage()
	atom_storage.remove_all()

/// Returns a list of object types to be preloaded by our code
/// I'll say it again, be very careful with this. We only need it for a few things
/// Don't do anything stupid, please
/obj/item/storage/proc/get_types_to_preload()
	return

/atom
	/// the datum handler for our contents - see create_storage() for creation method
	var/datum/storage/atom_storage

/// A quick and easy way to create a storage datum for an atom
/atom/proc/create_storage(
	max_slots,
	max_specific_storage,
	max_total_storage,
	numerical_stacking = FALSE,
	allow_quick_gather = FALSE,
	allow_quick_empty = FALSE,
	collection_mode = COLLECT_ONE,
	attack_hand_interact = TRUE,
	list/canhold,
	list/canthold,
	storage_type = /datum/storage,
)

	if(atom_storage)
		QDEL_NULL(atom_storage)

	atom_storage = new storage_type(src, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, collection_mode, attack_hand_interact)

	if(canhold || canthold)
		atom_storage.set_holdable(canhold, canthold)

	return atom_storage

/// A quick and easy way to /clone/ a storage datum for an atom (does not copy over contents, only the datum details)
/atom/proc/clone_storage(datum/storage/cloning)
	if(atom_storage)
		QDEL_NULL(atom_storage)

	atom_storage = new cloning.type(src, cloning.max_slots, cloning.max_specific_storage, cloning.max_total_storage, cloning.numerical_stacking, cloning.allow_quick_gather, cloning.collection_mode, cloning.attack_hand_interact)

	if(cloning.can_hold || cloning.cant_hold)
		if(!atom_storage.can_hold && !atom_storage.cant_hold) //In the event that the can/can't hold lists are already in place (such as from storage objects added on initialize).
			atom_storage.set_holdable(cloning.can_hold, cloning.cant_hold)

	return atom_storage

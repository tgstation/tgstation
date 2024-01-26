/atom
	/// the datum handler for our contents - see create_storage() for creation method
	var/datum/storage/atom_storage

/// A quick and easy way to create a storage datum for an atom
/atom/proc/create_storage(
	max_slots,
	max_specific_storage,
	max_total_storage,
	list/canhold,
	list/canthold,
	storage_type = /datum/storage,
)
	RETURN_TYPE(/datum/storage)

	if(atom_storage)
		QDEL_NULL(atom_storage)

	atom_storage = new storage_type(src, max_slots, max_specific_storage, max_total_storage)

	if(canhold || canthold)
		atom_storage.set_holdable(canhold, canthold)

	return atom_storage

/**
 * A quick and easy way to /clone/ a storage datum for an atom (does not copy over contents, only the datum details)
 *
 * Imperfect, does not copy over ALL variables, only important ones (max storage size, etc)
 */
/atom/proc/clone_storage(datum/storage/cloning)
	RETURN_TYPE(/datum/storage)

	if(atom_storage)
		QDEL_NULL(atom_storage)

	atom_storage = new cloning.type(src, cloning.max_slots, cloning.max_specific_storage, cloning.max_total_storage)

	if(cloning.can_hold || cloning.cant_hold)
		if(!atom_storage.can_hold && !atom_storage.cant_hold) //In the event that the can/can't hold lists are already in place (such as from storage objects added on initialize).
			atom_storage.set_holdable(cloning.can_hold, cloning.cant_hold)

	return atom_storage

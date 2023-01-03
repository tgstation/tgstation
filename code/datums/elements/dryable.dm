// If an item has this element, it can be dried on a drying rack.
/datum/element/dryable
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// The type of atom that is spawned by this element on drying.
	var/dry_result

/datum/element/dryable/Attach(datum/target, atom/dry_result)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	src.dry_result = dry_result

	RegisterSignal(target, COMSIG_ITEM_DRIED, PROC_REF(finish_drying))
	ADD_TRAIT(target, TRAIT_DRYABLE, ELEMENT_TRAIT(type))


/datum/element/dryable/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_FOOD_CONSUMED)
	REMOVE_TRAIT(target, TRAIT_DRYABLE, ELEMENT_TRAIT(type))

/datum/element/dryable/proc/finish_drying(atom/source)
	SIGNAL_HANDLER
	var/atom/dried_atom = source
	if(dry_result == dried_atom.type)//if the dried type is the same as our currrent state, don't bother creating a whole new item, just re-color it.
		var/atom/movable/resulting_atom = dried_atom
		resulting_atom.add_atom_colour(COLOR_DRIED_TAN, FIXED_COLOUR_PRIORITY)
		ADD_TRAIT(resulting_atom, TRAIT_DRIED, ELEMENT_TRAIT(type))
		resulting_atom.forceMove(source.drop_location())
		return

	else if(isstack(source)) //Check if its a sheet
		var/obj/item/stack/itemstack = dried_atom
		for(var/i in 1 to itemstack.amount)
			var/atom/movable/resulting_atom = new dry_result(source.drop_location())
			ADD_TRAIT(resulting_atom, TRAIT_DRIED, ELEMENT_TRAIT(type))
		qdel(source)
		return
	else
		var/atom/movable/resulting_atom = new dry_result(source.drop_location())
		ADD_TRAIT(resulting_atom, TRAIT_DRIED, ELEMENT_TRAIT(type))
		qdel(source)



/**
 * Restore an variable of this atom from a map file which can be either an
 * 1) obj atom
 * 2) custom variable(begins with $)
 * Arguments
 *
 * * attribute - the attribute name
 * * resolved_value - the resolved atom/list of atoms
 */
/atom/proc/restore_saved_value(attribute, resolved_value)
	return

/atom/movable/restore_saved_value(attribute, resolved_value)
	if(attribute == "contents")
		for(var/obj/item in contents)
			qdel(item)

		for(var/obj/item in resolved_value)
			if(atom_storage)
				atom_storage.attempt_insert(item, override = TRUE, messages = FALSE)
			else
				item.forceMove(src)

		return

	var/atom/movable/data = resolved_value
	if(ismovable(data))
		var/value = vars[attribute]
		if(isatom(value)) //it may contain an default value which we want to delete
			qdel(value)
		vars[attribute] = data
		data.forceMove(src)

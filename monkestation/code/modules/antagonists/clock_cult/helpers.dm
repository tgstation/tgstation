///check if an atom is on the reebe z level, will also return FALSE if the atom has no z level
/proc/on_reebe(atom/checked_atom)
	if(!checked_atom.z || !is_reebe_level(checked_atom.z))
		return FALSE
	return TRUE

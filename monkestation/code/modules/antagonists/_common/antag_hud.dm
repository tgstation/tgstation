/datum/atom_hud/alternate_appearance/basic/has_antagonist
	///The key or list of keys that are valid to see this hud, if unset then it will display to everyone with the antag datum like normal
	var/list/valid_keys

/datum/atom_hud/alternate_appearance/basic/has_antagonist/mobShouldSee(mob/M)
	var/datum/antagonist/antag_datum = M.mind?.has_antag_datum(antag_datum_type)
	if(!antag_datum)
		return FALSE

	if(!valid_keys)
		return TRUE

	var/islist_datum_keys = islist(antag_datum.hud_keys)
	if(islist(valid_keys))
		if(islist_datum_keys)
			return length(valid_keys - antag_datum.hud_keys) != length(valid_keys)
		return antag_datum.hud_keys in valid_keys
	else if(islist_datum_keys)
		return valid_keys in antag_datum.hud_keys
	return valid_keys == antag_datum.hud_keys

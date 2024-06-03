/datum/atom_hud/alternate_appearance/basic/has_antagonist
	///The key or list of keys that are valid to see this hud, if unset then it will display to everyone with the antag datum like normal
	var/list/valid_keys

/datum/atom_hud/alternate_appearance/basic/has_antagonist/mobShouldSee(mob/target)
	var/datum/antagonist/antag_datum = target?.mind?.has_antag_datum(antag_datum_type)
	if(!antag_datum)
		return FALSE

	if(!valid_keys)
		return TRUE

	if(!islist(valid_keys))
		valid_keys = list(valid_keys)
	return length(valid_keys - antag_datum.hud_keys) != length(valid_keys)

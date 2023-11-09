/// The first name given to nuclear operative antagonists. The last name will be chosen by the team leader.
/datum/preference/text/operative_alias
	savefile_key = "operative_alias"
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/text/operative_alias/create_informed_default_value(datum/preferences/preferences)
	return "wow" //maybe change this to a preset list

/datum/preference/text/operative_alias/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return FALSE

/datum/preference/text/operative_alias/is_accessible(datum/preferences/preferences)
	. = ..()
	if(!.)
		return FALSE

	// If one of the roles is ticked in the antag prefs menu, this option will show.
	var/static/list/ops_roles = list(ROLE_OPERATIVE, ROLE_LONE_OPERATIVE, ROLE_OPERATIVE_MIDROUND, ROLE_CLOWN_OPERATIVE) //note -- make sure the clown names arent messed with somehow
	if(length(ops_roles & preferences.be_special))
		return TRUE

	return FALSE

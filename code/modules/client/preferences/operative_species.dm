/// When TRUE, will spawn you as a human when selected for an operative role
/// When FALSE, players will be placed into the game as their character's species
/datum/preference/toggle/nuke_ops_species
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	can_randomize = FALSE
	default_value = TRUE
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "operative_species"

/datum/preference/toggle/nuke_ops_species/is_accessible(datum/preferences/preferences)
	. = ..()
	if(!.)
		return FALSE

	// If one of the roles is ticked in the antag prefs menu, this option will show.
	var/static/list/ops_roles = list(ROLE_OPERATIVE, ROLE_LONE_OPERATIVE, ROLE_OPERATIVE_MIDROUND, ROLE_CLOWN_OPERATIVE)
	if(length(ops_roles & preferences.be_special))
		return TRUE

	return FALSE

/datum/preference/toggle/nuke_ops_species/apply_to_human(mob/living/carbon/human/target, value)
	return

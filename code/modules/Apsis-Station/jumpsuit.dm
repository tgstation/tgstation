//Apsis-Station: Jumpskirts are not selectable in character creation.
//Lore reason: they do not provide leg protection per station policy.
//Jumpskirts still exist in lockers as found equipment due to negligence by the construction contractors. 
//This only affects character creator starting loadout selection.

/datum/preference/choiced/jumpsuit/deserialize(input, datum/preferences/preferences)
	if(!isnull(input) && input == PREF_SKIRT)
		if(preferences?.parent)
			to_chat(preferences.parent, span_warning("Jumpskirts are not available for selection during character creation."))
			to_chat(preferences.parent, span_notice("Station policy requires leg protection. Jumpskirts may still be found in station lockers."))
		return PREF_SUIT
	return ..()
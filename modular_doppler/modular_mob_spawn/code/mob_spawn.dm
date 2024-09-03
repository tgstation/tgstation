/obj/effect/mob_spawn/ghost_role
	/// Are we limited to a certain species type? LISTED TYPE
	var/list/restricted_species = list()

/obj/effect/mob_spawn/ghost_role/create(mob/mob_possessor, newname)
	if((restricted_species && !(mob_possessor?.client?.prefs?.read_preference(/datum/preference/choiced/species) in restricted_species)))
		var/text = "Current loaded character doesn't match required species: "
		var/i = 1
		for(var/datum/species/speciesItem as anything in restricted_species)
			text += "[speciesItem.name]"
			if(i < restricted_species.len)
				text += ", "
			i++
		tgui_alert(mob_possessor, text)
		return FALSE
	return ..()

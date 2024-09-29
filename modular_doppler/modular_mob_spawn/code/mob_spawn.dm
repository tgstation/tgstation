/obj/effect/mob_spawn/ghost_role
	/// List of ghost role restricted species
	var/list/restricted_species = list()

/obj/effect/mob_spawn/ghost_role/create(mob/mob_possessor, newname)
	if(restricted_species.len  && !(mob_possessor?.client?.prefs?.read_preference(/datum/preference/choiced/species) in restricted_species))
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

/// Original proc in code/modules/mob_spawn/mob_spawn.dm ~line 39.
/obj/effect/mob_spawn/create(mob/mob_possessor, newname, is_pref_loaded)
	var/mob/living/spawned_mob = new mob_type(get_turf(src)) //living mobs only
	name_mob(spawned_mob, newname)
	special(spawned_mob, mob_possessor)
	if(!is_pref_loaded)
		equip(spawned_mob)
	return spawned_mob

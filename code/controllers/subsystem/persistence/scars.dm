///Saves all scars for everyone's original characters
/datum/controller/subsystem/persistence/proc/save_scars()
	for(var/i in GLOB.joined_player_list)
		var/mob/living/carbon/human/ending_human = get_mob_by_ckey(i)
		if(!istype(ending_human) || !ending_human.mind?.original_character_slot_index || !ending_human.client?.prefs.read_preference(/datum/preference/toggle/persistent_scars))
			continue

		var/mob/living/carbon/human/original_human = ending_human.mind.original_character.resolve()

		if(!original_human)
			continue

		if(original_human.stat == DEAD || !original_human.all_scars || original_human != ending_human)
			original_human.save_persistent_scars(TRUE)
		else
			original_human.save_persistent_scars()


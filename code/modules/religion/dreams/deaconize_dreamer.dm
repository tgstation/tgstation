/datum/religion_rites/deaconize/dreamers
	desc = "Converts someone to your sect. They must be willing, so the first invocation will instead prompt them to join. \
		They will gain the same holy abilities as you. You can deaconize up to three followers, so choose wisely!"
	rite_flags = parent_type::rite_flags & ~RITE_ONE_TIME_USE

/datum/religion_rites/deaconize/dreamers/invoke_effect(mob/living/carbon/human/user, atom/movable/religious_tool)
	if(isnightmare(potential_deacon))
		to_chat(user, span_warning("[potential_deacon] is a nightmare, an affront to [GLOB.deity] and all they stand for!"))
		return FALSE
	return ..()

/datum/religion_rites/deaconize/dreamers/post_invoke_effects(mob/living/user, atom/religious_tool)
	. = ..()
	if(!istype(GLOB.religious_sect, /datum/religion_sect/dreams))
		return

	var/datum/religion_sect/dreams/sect = GLOB.religious_sect
	sect.deacon_count += 1
	if(sect.deacon_count >= sect.max_deacons)
		sect.rites_list -= type

/datum/antagonist
	///The list of keys that are valid to see our antag hud/of huds we can see
	var/list/hud_keys

///Set our hud_keys, please only use this proc when changing them, if override_old_keys is FALSE then we will simply add keys, otherwise we we set our keys to only be passed ones
/datum/antagonist/proc/set_hud_keys(list/keys, override_old_keys = FALSE)
	if(!islist(keys))
		keys = list(keys)

	hud_keys = (override_old_keys ? keys : keys + hud_keys)

/datum/antagonist/proc/antag_token(datum/mind/hosts_mind, mob/spender)
	SHOULD_CALL_PARENT(FALSE)
	if(isobserver(spender))
		var/mob/living/carbon/human/new_mob = spender.change_mob_type(/mob/living/carbon/human, delete_old_mob = TRUE)
		new_mob.equipOutfit(/datum/outfit/job/assistant)
		new_mob.mind.add_antag_datum(type)
	else
		hosts_mind.add_antag_datum(type)

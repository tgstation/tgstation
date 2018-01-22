//returns a list of scriptures and if they're unlocked or not
/proc/scripture_unlock_check()
	. = list(SCRIPTURE_DRIVER = TRUE, SCRIPTURE_SCRIPT = FALSE, SCRIPTURE_APPLICATION = FALSE)
	//Drivers: always unlocked

	.[SCRIPTURE_SCRIPT] = GLOB.script_scripture_unlocked
	//Script: Convert a new servant using a sigil of submission.

	.[SCRIPTURE_APPLICATION] = GLOB.application_scripture_unlocked
	//Application: APPLICATION_SERVANT_REQ or more non-brain servants, APPLICATION_CACHE_REQ or more clockwork caches, and at least APPLICATION_CV_REQ CV

//reports to servants when scripture is locked or unlocked
/proc/scripture_unlock_alert(list/previous_states)
	. = scripture_unlock_check()
	if(!GLOB.servants_active)
		return
	for(var/i in .)
		if(.[i] != previous_states[i])
			update_slab_info()
			for(var/mob/M in GLOB.player_list)
				if(is_servant_of_ratvar(M) || isobserver(M))
					M.playsound_local(M, 'sound/magic/clockwork/scripture_tier_up.ogg', 50, FALSE, pressure_affected = FALSE)

/proc/update_slab_info(obj/item/clockwork/slab/set_slab)
	generate_all_scripture()
	var/needs_update = FALSE //if everything needs an update, for whatever reason
	for(var/s in GLOB.all_scripture)
		var/datum/clockwork_scripture/S = GLOB.all_scripture[s]
		if(S.creation_update())
			needs_update = TRUE
	if(!set_slab || needs_update)
		for(var/obj/item/clockwork/slab/S in GLOB.all_clockwork_objects)
			SStgui.update_uis(S)
			if(needs_update)
				S.update_quickbind()
	else
		SStgui.update_uis(set_slab)
		set_slab.update_quickbind()

/proc/generate_all_scripture()
	if(!GLOB.all_scripture.len)
		for(var/V in sortList(subtypesof(/datum/clockwork_scripture), /proc/cmp_clockscripture_priority))
			var/datum/clockwork_scripture/S = new V
			GLOB.all_scripture[S.type] = S

//changes construction value
/proc/change_construction_value(amount)
	if(!SSticker.current_state != GAME_STATE_PLAYING) //This is primarily so that structures added pre-roundstart don't contribute to construction value
		return
	GLOB.clockwork_construction_value = max(0, GLOB.clockwork_construction_value + amount)

/proc/can_recite_scripture(mob/living/L, can_potentially)
	return (is_servant_of_ratvar(L) && (can_potentially || (L.stat == CONSCIOUS && L.can_speak_vocal())) && (GLOB.ratvar_awakens || (ishuman(L) || issilicon(L))))

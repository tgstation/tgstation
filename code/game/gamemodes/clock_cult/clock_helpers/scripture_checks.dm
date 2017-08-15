//returns a list of scriptures and if they're unlocked or not
/proc/scripture_unlock_check()
	var/servants = 0
	for(var/mob/living/M in GLOB.living_mob_list)
		if(is_servant_of_ratvar(M) && (ishuman(M) || issilicon(M)))
			servants++
	. = list(SCRIPTURE_DRIVER = TRUE, SCRIPTURE_SCRIPT = FALSE, SCRIPTURE_APPLICATION = FALSE)
	//Drivers: Always unlocked.
	.[SCRIPTURE_SCRIPT] = (SSticker.scripture_states[SCRIPTURE_SCRIPT] || (GLOB.initial_ark_time && GLOB.initial_ark_time - (GLOB.initial_ark_time * 0.5) <= world.time))
	//Script: Ark is halfway to activating.
	.[SCRIPTURE_APPLICATION] = (SSticker.scripture_states[SCRIPTURE_APPLICATION] || servants >= GLOB.application_servants_needed)
	//Application: One crewmember converted.

//reports to servants when scripture is locked or unlocked
/proc/scripture_unlock_alert(list/previous_states)
	. = scripture_unlock_check()
	for(var/i in .)
		if(.[i] != previous_states[i])
			hierophant_message("<span class='large_brass'><i>Hierophant Network:</i> <b>[i] Scripture has been [.[i] ? "un":""]locked.</b></span>") //maybe admins fucked with scripture states?
			if(.[i])
				for(var/mob/M in GLOB.player_list)
					if(is_servant_of_ratvar(M) || isobserver(M))
						M.playsound_local(M, 'sound/magic/clockwork/scripture_tier_up.ogg', 50, FALSE, pressure_affected = FALSE)
			update_slab_info()

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

/proc/can_recite_scripture(mob/living/L, can_potentially)
	return (is_servant_of_ratvar(L) && (can_potentially || (L.stat == CONSCIOUS && L.can_speak_vocal())) && (GLOB.ratvar_awakens || (ishuman(L) || issilicon(L))))

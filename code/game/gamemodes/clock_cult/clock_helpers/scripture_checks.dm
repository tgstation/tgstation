//returns a list of scriptures and if they're unlocked or not
/proc/scripture_unlock_check()
	. = list(SCRIPTURE_DRIVER = TRUE, SCRIPTURE_SCRIPT = TRUE, SCRIPTURE_FUNCTION = TRUE, SCRIPTURE_APPLICATION = TRUE)

//reports to servants when scripture is locked or unlocked
/proc/scripture_unlock_alert(list/previous_states)
	. = scripture_unlock_check()
	for(var/i in .)
		if(.[i] != previous_states[i])
			hierophant_message("<span class='large_brass'><i>Hierophant Network:</i> <b>[i] Scripture has been [.[i] ? "un":""]locked.</b></span>") //maybe admins fucked with scripture states?
			update_slab_info()

/proc/get_unconverted_ais()
	. = 0
	for(var/ai in GLOB.ai_list)
		var/mob/living/silicon/ai/AI = ai
		if(AI.deployed_shell && is_servant_of_ratvar(AI.deployed_shell))
			continue
		if(is_servant_of_ratvar(AI) || !isturf(AI.loc) || AI.z != ZLEVEL_STATION || AI.stat == DEAD)
			continue
		.++

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
	GLOB.clockwork_construction_value += amount

/proc/can_recite_scripture(mob/living/L)
	return (is_servant_of_ratvar(L) && L.stat == CONSCIOUS && L.can_speak_vocal() && (GLOB.ratvar_awakens || (ishuman(L) || issilicon(L))))

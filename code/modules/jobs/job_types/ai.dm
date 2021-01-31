/datum/job/ai
	title = "AI"
	auto_deadmin_role_flags = DEADMIN_POSITION_SILICON
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	selection_color = "#ccffcc"
	supervisors = "your laws"
	req_admin_notify = TRUE
	minimal_player_age = 30
	exp_requirements = 180
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_SILICON
	display_order = JOB_DISPLAY_ORDER_AI
	allow_bureaucratic_error = FALSE
	var/do_special_check = TRUE

/datum/job/ai/equip(mob/living/carbon/human/H, visualsOnly, announce, latejoin, datum/outfit/outfit_override, client/preference_source = null)
	if(visualsOnly)
		CRASH("dynamic preview is unsupported")
	. = H.AIize(latejoin,preference_source)

/datum/job/ai/after_spawn(mob/H, mob/M, latejoin)
	. = ..()
	if(latejoin)
		var/obj/structure/ai_core/latejoin_inactive/lateJoinCore
		for(var/obj/structure/ai_core/latejoin_inactive/P in GLOB.latejoin_ai_cores)
			if(P.is_available())
				lateJoinCore = P
				GLOB.latejoin_ai_cores -= P
				break
		if(lateJoinCore)
			lateJoinCore.available = FALSE
			H.forceMove(lateJoinCore.loc)
			qdel(lateJoinCore)
	var/mob/living/silicon/ai/AI = H
	if(SSticker.anonymousnames)
		AI.fully_replace_character_name(AI.real_name, SSticker.anonymousnames.anonymous_ai_name(TRUE))
	else
		AI.apply_pref_name("ai", M.client)			//If this runtimes oh well jobcode is fucked. //what is this no energy attitude man
	AI.set_core_display_icon(null, M.client)

	//we may have been created after our borg
	if(SSticker.current_state == GAME_STATE_SETTING_UP)
		for(var/mob/living/silicon/robot/R in GLOB.silicon_mobs)
			if(!R.connected_ai)
				R.TryConnectToAI()

	if(latejoin)
		announce(AI)

/datum/job/ai/override_latejoin_spawn()
	return TRUE

/datum/job/ai/special_check_latejoin(client/C)
	if(!do_special_check)
		return TRUE
	for(var/i in GLOB.latejoin_ai_cores)
		var/obj/structure/ai_core/latejoin_inactive/LAI = i
		if(istype(LAI))
			if(LAI.is_available())
				return TRUE
	return FALSE

/datum/job/ai/announce(mob/living/silicon/ai/AI)
	. = ..()
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, .proc/minor_announce, "[AI] has been downloaded to an empty bluespace-networked AI core at [AREACOORD(AI)]."))

/datum/job/ai/config_check()
	return CONFIG_GET(flag/allow_ai)


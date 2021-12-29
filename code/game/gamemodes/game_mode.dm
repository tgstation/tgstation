

/*
 * GAMEMODES (by Rastaf0)
 *
 * In the new mode system all special roles are fully supported.
 * You can have proper wizards/traitors/changelings/cultists during any mode.
 * Only two things really depends on gamemode:
 * 1. Starting roles, equipment and preparations
 * 2. Conditions of finishing the round.
 *
 */


/datum/game_mode

///Handles late-join antag assignments
/datum/game_mode/proc/make_antag_chance(mob/living/carbon/human/character)
	return

/datum/game_mode/proc/check_finished(force_ending) //to be called by SSticker
	if(!SSticker.setup_done)
		return FALSE
	if(SSshuttle.emergency && (SSshuttle.emergency.mode == SHUTTLE_ENDGAME))
		return TRUE
	if(GLOB.station_was_nuked)
		return TRUE
	if(force_ending)
		return TRUE

//////////////////////////
//Reports player logouts//
//////////////////////////
/proc/display_roundstart_logout_report()
	var/list/msg = list("[span_boldnotice("Roundstart logout report")]\n\n")
	for(var/i in GLOB.mob_living_list)
		var/mob/living/L = i
		var/mob/living/carbon/C = L
		if (istype(C) && !C.last_mind)
			continue  // never had a client

		if(L.ckey && !GLOB.directory[L.ckey])
			msg += "<b>[L.name]</b> ([L.key]), the [L.job] (<font color='#ffcc00'><b>Disconnected</b></font>)\n"


		if(L.ckey && L.client)
			var/failed = FALSE
			if(L.client.inactivity >= (ROUNDSTART_LOGOUT_REPORT_TIME / 2)) //Connected, but inactive (alt+tabbed or something)
				msg += "<b>[L.name]</b> ([L.key]), the [L.job] (<font color='#ffcc00'><b>Connected, Inactive</b></font>)\n"
				failed = TRUE //AFK client
			if(!failed && L.stat)
				if(L.suiciding) //Suicider
					msg += "<b>[L.name]</b> ([L.key]), the [L.job] ([span_boldannounce("Suicide")])\n"
					failed = TRUE //Disconnected client
				if(!failed && (L.stat == UNCONSCIOUS || L.stat == HARD_CRIT))
					msg += "<b>[L.name]</b> ([L.key]), the [L.job] (Dying)\n"
					failed = TRUE //Unconscious
				if(!failed && L.stat == DEAD)
					msg += "<b>[L.name]</b> ([L.key]), the [L.job] (Dead)\n"
					failed = TRUE //Dead

			continue //Happy connected client
		for(var/mob/dead/observer/D in GLOB.dead_mob_list)
			if(D.mind && D.mind.current == L)
				if(L.stat == DEAD)
					if(L.suiciding) //Suicider
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] ([span_boldannounce("Suicide")])\n"
						continue //Disconnected client
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] (Dead)\n"
						continue //Dead mob, ghost abandoned
				else
					if(D.can_reenter_corpse)
						continue //Adminghost, or cult/wizard ghost
					else
						msg += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job] ([span_boldannounce("Ghosted")])\n"
						continue //Ghosted while alive


	for (var/C in GLOB.admins)
		to_chat(C, msg.Join())

/// Mode specific admin panel.
/datum/game_mode/proc/admin_panel()
	return

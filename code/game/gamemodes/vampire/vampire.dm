/datum/game_mode
	var/list/datum/mind/vampires = list()

/mob/living/carbon/human/Stat()
	. = ..()
	var/datum/antagonist/vampire/vamp = mind.has_antag_datum(ANTAG_DATUM_VAMPIRE)
	if(vamp && statpanel("Status"))
		stat("Total Blood", vamp.total_blood)
		stat("Usable Blood", vamp.usable_blood)

/mob/living/carbon/human/Life()
	. = ..()
	if(is_vampire(src))
		var/datum/antagonist/vampire/vamp = mind.has_antag_datum(ANTAG_DATUM_VAMPIRE)
		vamp.vampire_life()


/datum/game_mode/traitor/vampire
	name = "vampire"
	config_tag = "vampire"
	antag_flag = ROLE_VAMPIRE
	antag_datum = ANTAG_DATUM_VAMPIRE
	false_report_weight = 1
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Head of Security", "Captain", "Security Officer", "Chaplain", "Detective", "Warden")
	required_players = 15
	required_enemies = 1
	recommended_enemies = 3

	announce_text = "There are vampires onboard the station!\n\
		+	<span class='danger'>Vampires</span>: Suck the blood of the crew and complete your objectives!\n\
		+	<span class='notice'>Crew</span>: Kill the unholy vampires!"

/datum/game_mode/proc/auto_declare_completion_vampire()
	if(vampires.len)
		var/text = "<br><font size=3><b>The vampires were:</b></font>"
		for(var/datum/mind/vamp in vampires)
			var/vampwin = TRUE
			if(!vamp.current)
				vampwin = FALSE

			var/datum/antagonist/vampire/V = vamp.has_antag_datum(ANTAG_DATUM_VAMPIRE)

			if(!V)
				continue

			text += printplayer(vamp)

			//Removed sanity if(vampire) because we -want- a runtime to inform us that the vampire list is incorrect and needs to be fixed.
			text += "<br><b>Usable Blood:</b> [V.usable_blood]."
			text += "<br><b>Total Blood:</b> [V.total_blood]"

			if(vamp.objectives.len)
				var/count = 1
				for(var/datum/objective/objective in vamp.objectives)
					if(objective.check_completion())
						text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <font color='green'><b>Success!</b></font>"
						SSblackbox.add_details("vampire_objective","[objective.type]|SUCCESS")
					else
						text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <span class='danger'>Fail.</span>"
						SSblackbox.add_details("vampire_objective","[objective.type]|FAIL")
						vampwin = FALSE
					count++

			if(vampwin)
				text += "<br><font color='green'><b>The vampire was successful!</b></font>"
				SSblackbox.add_details("vampire_success","SUCCESS")
			else
				text += "<br><span class='boldannounce'>The vampire has failed.</span>"
				SSblackbox.add_details("vampire_success","FAIL")
			text += "<br>"

		to_chat(world, text)


	return TRUE


/proc/add_vampire(mob/living/L)
	if(!L || !L.mind || is_vampire(L))
		return FALSE
	var/datum/antagonist/vampire/vamp = L.mind.add_antag_datum(ANTAG_DATUM_VAMPIRE)
	return vamp

/proc/remove_vampire(mob/living/L)
	if(!L || !L.mind || !is_vampire(L))
		return FALSE
	var/datum/antagonist/vamp = L.mind.has_antag_datum(ANTAG_DATUM_VAMPIRE)
	vamp.on_removal()
	return TRUE

/proc/is_vampire(mob/living/M)
	return M && M.mind && M.mind.has_antag_datum(ANTAG_DATUM_VAMPIRE)

/datum/game_mode/proc/update_vampire_icons_added(datum/mind/traitor_mind)
	var/datum/atom_hud/antag/vamphud = GLOB.huds[ANTAG_HUD_VAMPIRE]
	vamphud.join_hud(traitor_mind.current)
	set_antag_hud(traitor_mind.current, "vampire")

/datum/game_mode/proc/update_vampire_icons_removed(datum/mind/traitor_mind)
	var/datum/atom_hud/antag/vamphud = GLOB.huds[ANTAG_HUD_VAMPIRE]
	vamphud.leave_hud(traitor_mind.current)
	set_antag_hud(traitor_mind.current, null)

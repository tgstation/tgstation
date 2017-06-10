/datum/game_mode
	var/list/datum/mind/wizards = list()
	var/list/datum/mind/apprentices = list()

/datum/game_mode/wizard
	name = "wizard"
	config_tag = "wizard"
	antag_flag = ROLE_WIZARD
	required_players = 20
	required_enemies = 1
	recommended_enemies = 1
	enemy_minimum_age = 0
	round_ends_with_antag_death = 1
	announce_span = "danger"
	announce_text = "There is a space wizard attacking the station!\n\
	<span class='danger'>Wizard</span>: Accomplish your objectives and cause mayhem on the station.\n\
	<span class='notice'>Crew</span>: Eliminate the wizard before they can succeed!"
	var/use_huds = 0
	var/finished = 0

	var/antag_datum = ANTAG_DATUM_WIZARD
	var/list/datum/mind/pre_wizards = list()

/datum/game_mode/wizard/pre_setup()

	var/datum/mind/wizard = pick(antag_candidates)
	pre_wizards += wizard
	if(GLOB.wizardstart.len == 0)
		to_chat(wizard.current, "<span class='boldannounce'>A starting location for you could not be found, please report this bug!</span>")
		return FALSE
	for(var/datum/mind/wiz in wizards)
		wiz.current.loc = pick(GLOB.wizardstart)
	return TRUE

/datum/game_mode/wizard/post_setup()
	for(var/datum/mind/wizard in wizards)
		log_game("[wizard.key] (ckey) has been selected as a Wizard")
		wizard.add_antag_datum(antag_datum)
		if(use_huds)
			update_wiz_icons_added(wizard)
	return ..()

/datum/game_mode/wizard/check_finished()

	for(var/datum/mind/wizard in wizards)
		if(isliving(wizard.current) && wizard.current.stat!=DEAD)
			return ..()

	if(SSevents.wizardmode) //If summon events was active, turn it off
		SSevents.toggleWizardmode()
		SSevents.resetFrequency()

	return ..()

/datum/game_mode/wizard/declare_completion()
	if(finished)
		SSticker.mode_result = "loss - wizard killed"
		to_chat(world, "<span class='userdanger'>The wizard[(wizards.len>1)?"s":""] has been killed by the crew! The Space Wizards Federation has been taught a lesson they will not soon forget!</span>")

		SSticker.news_report = WIZARD_KILLED

	..()
	return 1

/datum/game_mode/proc/auto_declare_completion_wizard()
	if(wizards.len)
		var/text = "<br><font size=3><b>the wizards/witches were:</b></font>"

		for(var/datum/mind/wizard in wizards)

			text += "<br><b>[wizard.key]</b> was <b>[wizard.name]</b> ("
			if(wizard.current)
				if(wizard.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(wizard.current.real_name != wizard.name)
					text += " as <b>[wizard.current.real_name]</b>"
			else
				text += "body destroyed"
			text += ")"

			var/count = 1
			var/wizardwin = 1
			for(var/datum/objective/objective in wizard.objectives)
				if(objective.check_completion())
					text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
					SSblackbox.add_details("wizard_objective","[objective.type]|SUCCESS")
				else
					text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
					SSblackbox.add_details("wizard_objective","[objective.type]|FAIL")
					wizardwin = 0
				count++

			if(wizard.current && wizard.current.stat!=2 && wizardwin)
				text += "<br><font color='green'><B>The wizard was successful!</B></font>"
				SSblackbox.add_details("wizard_success","SUCCESS")
			else
				text += "<br><font color='red'><B>The wizard has failed!</B></font>"
				SSblackbox.add_details("wizard_success","FAIL")
			if(wizard.spell_list.len>0)
				text += "<br><B>[wizard.name] used the following spells: </B>"
				var/i = 1
				for(var/obj/effect/proc_holder/spell/S in wizard.spell_list)
					text += "[S.name]"
					if(wizard.spell_list.len > i)
						text += ", "
					i++
			text += "<br>"

		to_chat(world, text)
	return 1

//OTHER PROCS

//To batch-remove wizard spells. Linked to mind.dm.
/mob/proc/spellremove(mob/M)
	if(!mind)
		return
	for(var/X in src.mind.spell_list)
		var/obj/effect/proc_holder/spell/spell_to_remove = X
		qdel(spell_to_remove)
		mind.spell_list -= spell_to_remove

//returns whether the mob is a wizard (or apprentice)
/proc/iswizard(mob/living/M)
	return istype(M) && M.mind && SSticker && SSticker.mode && ((M.mind in SSticker.mode.wizards) || (M.mind in SSticker.mode.apprentices))

/datum/game_mode/proc/update_wiz_icons_added(datum/mind/wiz_mind)
	var/datum/atom_hud/antag/wizhud = GLOB.huds[ANTAG_HUD_WIZ]
	wizhud.join_hud(wiz_mind.current)
	set_antag_hud(wiz_mind.current, ((wiz_mind in wizards) ? "wizard" : "apprentice"))

/datum/game_mode/proc/update_wiz_icons_removed(datum/mind/wiz_mind)
	var/datum/atom_hud/antag/wizhud = GLOB.huds[ANTAG_HUD_WIZ]
	wizhud.leave_hud(wiz_mind.current)
	set_antag_hud(wiz_mind.current, null)

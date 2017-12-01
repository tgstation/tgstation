/datum/game_mode
	var/list/datum/mind/wizards = list()
	var/list/datum/mind/apprentices = list()

/datum/game_mode/wizard
	name = "wizard"
	config_tag = "wizard"
	antag_flag = ROLE_WIZARD
	false_report_weight = 10
	required_players = 20
	required_enemies = 1
	recommended_enemies = 1
	enemy_minimum_age = 14
	round_ends_with_antag_death = 1
	announce_span = "danger"
	announce_text = "There is a space wizard attacking the station!\n\
	<span class='danger'>Wizard</span>: Accomplish your objectives and cause mayhem on the station.\n\
	<span class='notice'>Crew</span>: Eliminate the wizard before they can succeed!"
	var/finished = 0

/datum/game_mode/wizard/pre_setup()
	var/datum/mind/wizard = pick(antag_candidates)
	wizards += wizard
	wizard.assigned_role = "Wizard"
	wizard.special_role = "Wizard"
	log_game("[wizard.key] (ckey) has been selected as a Wizard") //TODO: Move these to base antag datum
	if(GLOB.wizardstart.len == 0)
		to_chat(wizard.current, "<span class='boldannounce'>A starting location for you could not be found, please report this bug!</span>")
		return 0
	for(var/datum/mind/wiz in wizards)
		wiz.current.forceMove(pick(GLOB.wizardstart))
	return 1


/datum/game_mode/wizard/post_setup()
	for(var/datum/mind/wizard in wizards)
		wizard.add_antag_datum(/datum/antagonist/wizard)
	return ..()

/datum/game_mode/wizard/generate_report()
	return "A dangerous Wizards' Federation individual by the name of [pick(GLOB.wizard_first)] [pick(GLOB.wizard_second)] has recently escaped confinement from an unlisted prison facility. This \
		man is a dangerous mutant with the ability to alter himself and the world around him by what he and his leaders believe to be magic. If this man attempts an attack on your station, \
		his execution is highly encouraged, as is the preservation of his body for later study."


/datum/game_mode/wizard/are_special_antags_dead()
	for(var/datum/mind/wizard in wizards)
		if(isliving(wizard.current) && wizard.current.stat!=DEAD)
			return FALSE
	
	for(var/obj/item/phylactery/P in GLOB.poi_list) //TODO : IsProperlyDead()
		if(P.mind && P.mind.has_antag_datum(/datum/antagonist/wizard))
			return FALSE

	if(SSevents.wizardmode) //If summon events was active, turn it off
		SSevents.toggleWizardmode()
		SSevents.resetFrequency()
	
	return TRUE

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
					SSblackbox.record_feedback("nested tally", "wizard_objective", 1, list("[objective.type]", "SUCCESS"))
				else
					text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
					SSblackbox.record_feedback("nested tally", "wizard_objective", 1, list("[objective.type]", "FAIL"))
					wizardwin = 0
				count++

			if(wizard.current && wizardwin)
				text += "<br><font color='green'><B>The wizard was successful!</B></font>"
				SSblackbox.record_feedback("tally", "wizard_success", 1, "SUCCESS")
			else
				text += "<br><font color='red'><B>The wizard has failed!</B></font>"
				SSblackbox.record_feedback("tally", "wizard_success", 1, "FAIL")
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
//returns whether the mob is a wizard (or apprentice)
/proc/iswizard(mob/living/M)
	return M.mind && M.mind.has_antag_datum(/datum/antagonist/wizard,TRUE)

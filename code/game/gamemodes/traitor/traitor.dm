/datum/game_mode
	var/list/datum/mind/traitors = list()

/datum/game_mode/traitor
	name = "traitor"
	config_tag = "traitor"
	antag_flag = ROLE_TRAITOR
	restricted_jobs = list("Cyborg") //Slaved to the AI - if the AI is a traitor, so are they
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	required_players = 0
	required_enemies = 1
	recommended_enemies = 4
	reroll_friendly = 1
	enemy_minimum_age = 0

	announce_span = "danger"
	announce_text = "There are Syndicate agents on the station!\n\
	<span class='danger'>Traitors</span>: Accomplish your objectives.\n\
	<span class='notice'>Crew</span>: Do not let the traitors succeed!"

	var/traitors_possible = 4 //hard limit on traitors if scaling is turned off
	var/num_modifier = 0 //Used for submodes that need more traitors than usual

/datum/game_mode/traitor/pre_setup()
	var/num_traitors = 1

	if(config.traitor_scaling_coeff)
		num_traitors = max(1, min( round(num_players()/(config.traitor_scaling_coeff*2))+ 2 + num_modifier, round(num_players()/(config.traitor_scaling_coeff)) + num_modifier ))
	else
		num_traitors = max(1, min(num_players(), traitors_possible))

	for(var/j = 0, j < num_traitors, j++)
		if (!antag_candidates.len)
			break
		var/datum/mind/traitor = pick(antag_candidates)
		antag_candidates -= traitor
		traitors += traitor
		traitor.restricted_roles = restricted_jobs
		antag_candidates.Remove(traitor)

	if(traitors.len < required_enemies)
		return 0
	return 1


/datum/game_mode/traitor/post_setup()
	for(var/datum/mind/traitor in traitors)
		traitor.current.gain_antag_datum(/datum/antagonist/traitor/uplink)
	modePlayer += traitors
	..()
	return 1

/datum/game_mode/traitor/make_antag_chance(mob/living/carbon/human/character) //Assigns traitor to latejoiners
	var/traitorcap = min(round(joined_player_list.len / (config.traitor_scaling_coeff * 2)) + 2 + num_modifier, round(joined_player_list.len/config.traitor_scaling_coeff) + num_modifier )
	if(ticker.mode.traitors.len >= traitorcap) //Upper cap for number of latejoin antagonists
		return
	if(ticker.mode.traitors.len <= (traitorcap - 2) || prob(100 / (config.traitor_scaling_coeff * 2)))
		if(ROLE_TRAITOR in character.client.prefs.be_special)
			if(!jobban_isbanned(character, ROLE_TRAITOR) && !jobban_isbanned(character, "Syndicate"))
				if(age_check(character.client))
					if(!(character.job in restricted_jobs))
						character.gain_antag_datum(/datum/antagonist/traitor/uplink)

/proc/give_codewords(mob/living/traitor_mob)
	traitor_mob << "<U><B>The Syndicate provided you with the following information on how to identify their agents:</B></U>"
	traitor_mob << "<B>Code Phrase</B>: <span class='danger'>[syndicate_code_phrase]</span>"
	traitor_mob << "<B>Code Response</B>: <span class='danger'>[syndicate_code_response]</span>"

	traitor_mob.mind.store_memory("<b>Code Phrase</b>: [syndicate_code_phrase]")
	traitor_mob.mind.store_memory("<b>Code Response</b>: [syndicate_code_response]")

	traitor_mob << "Use the code words in the order provided, during regular conversation, to identify other agents. Proceed with caution, however, as everyone is a potential foe."


/datum/game_mode/proc/add_law_sixsixsix(mob/living/silicon/devil)
	var/laws = list("You may not use violence to coerce someone into selling their soul.", "You may not directly and knowingly physically harm a devil, other than yourself.", lawlorify[LAW][devil.mind.devilinfo.ban], lawlorify[LAW][devil.mind.devilinfo.obligation], "Accomplish your objectives at all costs.")
	devil.set_law_sixsixsix(laws)
	devil << "<b>Your laws have been changed!</b>"
	devil.show_laws()


/datum/game_mode/traitor/declare_completion()
	..()
	return//Traitors will be checked as part of check_extra_completion. Leaving this here as a reminder. //Looks like it didn't work there pal

/datum/game_mode/proc/auto_declare_completion_traitor()
	if(traitors.len)
		var/text = "<br><font size=3><b>The traitors were:</b></font>"
		for(var/datum/mind/traitor in traitors)
			var/traitorwin = 1

			text += printplayer(traitor)

			var/TC_uses = 0
			var/uplink_true = 0
			var/purchases = ""
			for(var/obj/item/device/uplink/H in uplinks)
				if(H && H.owner && H.owner == traitor.key)
					TC_uses += H.spent_telecrystals
					uplink_true = 1
					purchases += H.purchase_log

			var/objectives = ""
			if(traitor.objectives.len)//If the traitor had no objectives, don't need to process this.
				var/count = 1
				for(var/datum/objective/objective in traitor.objectives)
					if(objective.check_completion())
						objectives += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
						feedback_add_details("traitor_objective","[objective.type]|SUCCESS")
					else
						objectives += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
						feedback_add_details("traitor_objective","[objective.type]|FAIL")
						traitorwin = 0
					count++

			if(uplink_true)
				text += " (used [TC_uses] TC) [purchases]"
				if(TC_uses==0 && traitorwin)
					text += "<BIG><IMG CLASS=icon SRC=\ref['icons/BadAss.dmi'] ICONSTATE='badass'></BIG>"

			text += objectives

			var/special_role_text
			if(traitor.special_role)
				special_role_text = lowertext(traitor.special_role)
			else
				special_role_text = "antagonist"


			if(traitorwin)
				text += "<br><font color='green'><B>The [special_role_text] was successful!</B></font>"
				feedback_add_details("traitor_success","SUCCESS")
			else
				text += "<br><font color='red'><B>The [special_role_text] has failed!</B></font>"
				feedback_add_details("traitor_success","FAIL")

			text += "<br>"

		text += "<br><b>The code phrases were:</b> <font color='red'>[syndicate_code_phrase]</font><br>\
		<b>The code responses were:</b> <font color='red'>[syndicate_code_response]</font><br>"
		world << text

	return 1


/datum/game_mode/proc/update_traitor_icons_added(datum/mind/traitor_mind)
	var/datum/atom_hud/antag/traitorhud = huds[ANTAG_HUD_TRAITOR]
	traitorhud.join_hud(traitor_mind.current)
	set_antag_hud(traitor_mind.current, "traitor")

/datum/game_mode/proc/update_traitor_icons_removed(datum/mind/traitor_mind)
	var/datum/atom_hud/antag/traitorhud = huds[ANTAG_HUD_TRAITOR]
	traitorhud.leave_hud(traitor_mind.current)
	set_antag_hud(traitor_mind.current, null)


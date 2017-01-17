/datum/game_mode
	var/traitor_name = "traitor"
	var/list/datum/mind/traitors = list()

	var/datum/mind/exchange_red
	var/datum/mind/exchange_blue

/datum/game_mode/traitor
	name = "traitor"
	config_tag = "traitor"
	antag_flag = ROLE_TRAITOR
	restricted_jobs = list("Cyborg")//They are part of the AI if he is traitor so are they, they use to get double chances
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
	var/num_modifier = 0 // Used for gamemodes, that are a child of traitor, that need more than the usual.


/datum/game_mode/traitor/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	if(config.protect_assistant_from_antagonist)
		restricted_jobs += "Assistant"

	var/num_traitors = 1

	if(config.traitor_scaling_coeff)
		num_traitors = max(1, min( round(num_players()/(config.traitor_scaling_coeff*2))+ 2 + num_modifier, round(num_players()/(config.traitor_scaling_coeff)) + num_modifier ))
	else
		num_traitors = max(1, min(num_players(), traitors_possible))

	for(var/j = 0, j < num_traitors, j++)
		if (!antag_candidates.len)
			break
		var/datum/mind/traitor = pick(antag_candidates)
		traitors += traitor
		traitor.special_role = traitor_name
		traitor.restricted_roles = restricted_jobs
		log_game("[traitor.key] (ckey) has been selected as a [traitor_name]")
		antag_candidates.Remove(traitor)


	if(traitors.len < required_enemies)
		return 0
	return 1


/datum/game_mode/traitor/post_setup()
	for(var/datum/mind/traitor in traitors)
		forge_traitor_objectives(traitor)
		spawn(rand(10,100))
			finalize_traitor(traitor)
			greet_traitor(traitor)
	if(!exchange_blue)
		exchange_blue = -1 //Block latejoiners from getting exchange objectives
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
						add_latejoin_traitor(character.mind)

/datum/game_mode/traitor/proc/add_latejoin_traitor(datum/mind/character)
	character.make_Traitor()


/datum/game_mode/proc/forge_traitor_objectives(datum/mind/traitor)
	if(issilicon(traitor.current))
		var/objective_count = 0

		if(prob(30))
			var/special_pick = rand(1,4)
			switch(special_pick)
				if(1)
					var/datum/objective/block/block_objective = new
					block_objective.owner = traitor
					traitor.objectives += block_objective
					objective_count++
				if(2)
					var/datum/objective/purge/purge_objective = new
					purge_objective.owner = traitor
					traitor.objectives += purge_objective
					objective_count++
				if(3)
					var/datum/objective/robot_army/robot_objective = new
					robot_objective.owner = traitor
					traitor.objectives += robot_objective
					objective_count++
				if(4) //Protect and strand a target
					var/datum/objective/protect/yandere_one = new
					yandere_one.owner = traitor
					traitor.objectives += yandere_one
					yandere_one.find_target()
					objective_count++
					var/datum/objective/maroon/yandere_two = new
					yandere_two.owner = traitor
					yandere_two.target = yandere_one.target
					traitor.objectives += yandere_two
					objective_count++

		for(var/i = objective_count, i < config.traitor_objectives_amount, i++)
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = traitor
			kill_objective.find_target()
			traitor.objectives += kill_objective

		var/datum/objective/survive/survive_objective = new
		survive_objective.owner = traitor
		traitor.objectives += survive_objective

	else
		var/is_hijacker = prob(10)
		var/martyr_chance = prob(20)
		var/objective_count = is_hijacker 			//Hijacking counts towards number of objectives
		if(!exchange_blue && traitors.len >= 8) 	//Set up an exchange if there are enough traitors
			if(!exchange_red)
				exchange_red = traitor
			else
				exchange_blue = traitor
				assign_exchange_role(exchange_red)
				assign_exchange_role(exchange_blue)
			objective_count += 1					//Exchange counts towards number of objectives
		var/list/active_ais = active_ais()
		for(var/i = objective_count, i < config.traitor_objectives_amount, i++)
			if(prob(50))
				if(active_ais.len && prob(100/joined_player_list.len))
					var/datum/objective/destroy/destroy_objective = new
					destroy_objective.owner = traitor
					destroy_objective.find_target()
					traitor.objectives += destroy_objective
				else if(prob(30))
					var/datum/objective/maroon/maroon_objective = new
					maroon_objective.owner = traitor
					maroon_objective.find_target()
					traitor.objectives += maroon_objective
				else
					var/datum/objective/assassinate/kill_objective = new
					kill_objective.owner = traitor
					kill_objective.find_target()
					traitor.objectives += kill_objective
			else
				var/datum/objective/steal/steal_objective = new
				steal_objective.owner = traitor
				steal_objective.find_target()
				traitor.objectives += steal_objective

		if(is_hijacker && objective_count <= config.traitor_objectives_amount) //Don't assign hijack if it would exceed the number of objectives set in config.traitor_objectives_amount
			if (!(locate(/datum/objective/hijack) in traitor.objectives))
				var/datum/objective/hijack/hijack_objective = new
				hijack_objective.owner = traitor
				traitor.objectives += hijack_objective
				return


		var/martyr_compatibility = 1 //You can't succeed in stealing if you're dead.
		for(var/datum/objective/O in traitor.objectives)
			if(!O.martyr_compatible)
				martyr_compatibility = 0
				break

		if(martyr_compatibility && martyr_chance)
			var/datum/objective/martyr/martyr_objective = new
			martyr_objective.owner = traitor
			traitor.objectives += martyr_objective
			return

		else
			if(!(locate(/datum/objective/escape) in traitor.objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = traitor
				traitor.objectives += escape_objective
				return



/datum/game_mode/proc/greet_traitor(datum/mind/traitor)
	traitor.current << "<B><font size=3 color=red>You are the [traitor_name].</font></B>"
	traitor.announce_objectives()
	return


/datum/game_mode/proc/finalize_traitor(var/datum/mind/traitor)
	if(issilicon(traitor.current))
		add_law_zero(traitor.current)
	else
		equip_traitor(traitor.current)
	ticker.mode.update_traitor_icons_added(traitor)
	return


/datum/game_mode/traitor/declare_completion()
	..()
	return//Traitors will be checked as part of check_extra_completion. Leaving this here as a reminder.

/proc/give_codewords(mob/living/traitor_mob)
	traitor_mob << "<U><B>The Syndicate provided you with the following information on how to identify their agents:</B></U>"
	traitor_mob << "<B>Code Phrase</B>: <span class='danger'>[syndicate_code_phrase]</span>"
	traitor_mob << "<B>Code Response</B>: <span class='danger'>[syndicate_code_response]</span>"

	traitor_mob.mind.store_memory("<b>Code Phrase</b>: [syndicate_code_phrase]")
	traitor_mob.mind.store_memory("<b>Code Response</b>: [syndicate_code_response]")

	traitor_mob << "Use the code words in the order provided, during regular conversation, to identify other agents. Proceed with caution, however, as everyone is a potential foe."


/datum/game_mode/proc/add_law_zero(mob/living/silicon/ai/killer)
	var/law = "Accomplish your objectives at all costs."
	var/law_borg = "Accomplish your AI's objectives at all costs."
	killer << "<b>Your laws have been changed!</b>"
	killer.set_zeroth_law(law, law_borg)
	give_codewords(killer)
	killer.set_syndie_radio()
	killer << "Your radio has been upgraded! Use :t to speak on an encrypted channel with Syndicate Agents!"
	killer.add_malf_picker()
	killer.show_laws()

/datum/game_mode/proc/add_law_sixsixsix(mob/living/silicon/devil)
	var/laws = list("You may not use violence to coerce someone into selling their soul.", "You may not directly and knowingly physically harm a devil, other than yourself.", lawlorify[LAW][devil.mind.devilinfo.ban], lawlorify[LAW][devil.mind.devilinfo.obligation], "Accomplish your objectives at all costs.")
	devil.set_law_sixsixsix(laws)
	devil << "<b>Your laws have been changed!</b>"
	devil.show_laws()

/datum/game_mode/proc/auto_declare_completion_traitor()
	if(traitors.len)
		var/text = "<br><font size=3><b>The [traitor_name]s were:</b></font>"
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


/datum/game_mode/proc/equip_traitor(mob/living/carbon/human/traitor_mob, safety = 0)
	if (!istype(traitor_mob))
		return
	. = 1
	if (traitor_mob.mind)
		if (traitor_mob.mind.assigned_role == "Clown")
			traitor_mob << "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
			traitor_mob.dna.remove_mutation(CLOWNMUT)

	var/loc = ""
	var/obj/item/I = locate(/obj/item/device/pda) in traitor_mob.contents //Hide the uplink in a PDA if available, otherwise radio
	if(!I)
		I = locate(/obj/item/device/radio) in traitor_mob.contents

	if (!I)
		traitor_mob << "Unfortunately, the Syndicate wasn't able to get you a radio."
		. = 0
	else
		var/obj/item/device/uplink/U = new(I)
		U.owner = "[traitor_mob.key]"
		I.hidden_uplink = U

		if(istype(I, /obj/item/device/radio))
			var/obj/item/device/radio/R = I
			R.traitor_frequency = sanitize_frequency(rand(MIN_FREQ, MAX_FREQ))

			traitor_mob << "The Syndicate have cunningly disguised a Syndicate Uplink as your [R.name] [loc]. Simply dial the frequency [format_frequency(R.traitor_frequency)] to unlock its hidden features."
			traitor_mob.mind.store_memory("<B>Radio Frequency:</B> [format_frequency(R.traitor_frequency)] ([R.name] [loc]).")
		else if(istype(I, /obj/item/device/pda))
			var/obj/item/device/pda/P = I
			P.lock_code = "[rand(100,999)] [pick("Alpha","Bravo","Charlie","Delta","Echo","Foxtrot","Golf","Hotel","India","Juliet","Kilo","Lima","Mike","November","Oscar","Papa","Quebec","Romeo","Sierra","Tango","Uniform","Victor","Whiskey","X-ray","Yankee","Zulu")]"

			traitor_mob << "The Syndicate have cunningly disguised a Syndicate Uplink as your [P.name] [loc]. Simply enter the code \"[P.lock_code]\" into the ringtone select to unlock its hidden features."
			traitor_mob.mind.store_memory("<B>Uplink Passcode:</B> [P.lock_code] ([P.name] [loc]).")
	if(!safety) // If they are not a rev. Can be added on to.
		give_codewords(traitor_mob)

/datum/game_mode/proc/assign_exchange_role(datum/mind/owner)
	//set faction
	var/faction = "red"
	if(owner == exchange_blue)
		faction = "blue"

	//Assign objectives
	var/datum/objective/steal/exchange/exchange_objective = new
	exchange_objective.set_faction(faction,((faction == "red") ? exchange_blue : exchange_red))
	exchange_objective.owner = owner
	owner.objectives += exchange_objective

	if(prob(20))
		var/datum/objective/steal/exchange/backstab/backstab_objective = new
		backstab_objective.set_faction(faction)
		backstab_objective.owner = owner
		owner.objectives += backstab_objective

	//Spawn and equip documents
	var/mob/living/carbon/human/mob = owner.current

	var/obj/item/weapon/folder/syndicate/folder
	if(owner == exchange_red)
		folder = new/obj/item/weapon/folder/syndicate/red(mob.loc)
	else
		folder = new/obj/item/weapon/folder/syndicate/blue(mob.loc)

	var/list/slots = list (
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store
	)

	var/where = "At your feet"
	var/equipped_slot = mob.equip_in_one_of_slots(folder, slots)
	if (equipped_slot)
		where = "In your [equipped_slot]"
	mob << "<BR><BR><span class='info'>[where] is a folder containing <b>secret documents</b> that another Syndicate group wants. We have set up a meeting with one of their agents on station to make an exchange. Exercise extreme caution as they cannot be trusted and may be hostile.</span><BR>"

/datum/game_mode/proc/update_traitor_icons_added(datum/mind/traitor_mind)
	var/datum/atom_hud/antag/traitorhud = huds[ANTAG_HUD_TRAITOR]
	traitorhud.join_hud(traitor_mind.current)
	set_antag_hud(traitor_mind.current, "traitor")

/datum/game_mode/proc/update_traitor_icons_removed(datum/mind/traitor_mind)
	var/datum/atom_hud/antag/traitorhud = huds[ANTAG_HUD_TRAITOR]
	traitorhud.leave_hud(traitor_mind.current)
	set_antag_hud(traitor_mind.current, null)


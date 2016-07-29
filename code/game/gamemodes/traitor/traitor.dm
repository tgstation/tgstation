<<<<<<< HEAD
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
	if(istype(traitor.current, /mob/living/silicon))
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
	if (istype(traitor.current, /mob/living/silicon))
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
			P.lock_code = "[rand(100,999)] [pick("Alpha","Bravo","Delta","Omega")]"

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
		"right pocket" = slot_r_store,
		"left hand" = slot_l_hand,
		"right hand" = slot_r_hand,
	)

	var/where = "At your feet"
	var/equipped_slot = mob.equip_in_one_of_slots(folder, slots)
	if (equipped_slot)
		where = "In your [equipped_slot]"
	mob << "<BR><BR><span class='info'>[where] is a folder containing <b>secret documents</b> that another Syndicate group wants. We have set up a meeting with one of their agents on station to make an exchange. Exercise extreme caution as they cannot be trusted and may be hostile.</span><BR>"
	mob.update_icons()

/datum/game_mode/proc/update_traitor_icons_added(datum/mind/traitor_mind)
	var/datum/atom_hud/antag/traitorhud = huds[ANTAG_HUD_TRAITOR]
	traitorhud.join_hud(traitor_mind.current)
	set_antag_hud(traitor_mind.current, "traitor")

/datum/game_mode/proc/update_traitor_icons_removed(datum/mind/traitor_mind)
	var/datum/atom_hud/antag/traitorhud = huds[ANTAG_HUD_TRAITOR]
	traitorhud.leave_hud(traitor_mind.current)
	set_antag_hud(traitor_mind.current, null)

=======
/datum/game_mode
	// this includes admin-appointed traitors and multitraitors. Easy!
	var/list/datum/mind/traitors = list()
	var/list/datum/mind/implanter = list()
	var/list/datum/mind/implanted = list()

/datum/game_mode/traitor
	name = "traitor"
	config_tag = "traitor"
	restricted_jobs = list("Cyborg","Mobile MMI")//They are part of the AI if he is traitor so are they, they use to get double chances
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")//AI", Currently out of the list as malf does not work for shit
	required_players = 0
	required_enemies = 1
	recommended_enemies = 4
	var/traitor_name = "traitor"

	uplink_welcome = "Syndicate Uplink Console:"
	uplink_uses = 10

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/traitors_possible = 4 //hard limit on traitors if scaling is turned off
	var/const/traitor_scaling_coeff = 5.0 //how much does the amount of players get divided by to determine traitors


/datum/game_mode/traitor/announce()
	to_chat(world, "<B>The current game mode is - Traitor!</B>")
	to_chat(world, "<B>There is a syndicate traitor on the station. Do not let the traitor succeed!</B>")


/datum/game_mode/traitor/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/possible_traitors = get_players_for_role(ROLE_TRAITOR)

	// stop setup if no possible traitors
	if(!possible_traitors.len)
		return 0

	var/num_traitors = 1

	if(config.traitor_scaling)
		num_traitors = max(required_enemies, round((num_players())/(traitor_scaling_coeff)))
	else
		num_traitors = Clamp(num_players(), required_enemies, traitors_possible)

	for(var/datum/mind/player in possible_traitors)
		for(var/job in restricted_jobs)
			if(player.assigned_role == job)
				possible_traitors -= player

	if(possible_traitors.len < required_enemies) //fixes double agent starting with 1 traitor
		return 0

	for(var/j = 0, j < num_traitors, j++)
		if (!possible_traitors.len)
			break
		var/datum/mind/traitor = pick(possible_traitors)
		possible_traitors -= traitor
		if(traitor.special_role == "traitor")
			continue
		traitors += traitor
		traitor.special_role = "traitor"

	if(!traitors.len)
		return 0
	return 1


/datum/game_mode/traitor/post_setup()
	for(var/datum/mind/traitor in traitors)
		forge_traitor_objectives(traitor)
		spawn(rand(10,100))
			finalize_traitor(traitor)
			greet_traitor(traitor)
	modePlayer += traitors
	if(!mixed)
		spawn (rand(waittime_l, waittime_h))
			if(!mixed) send_intercept()
		..()
	return 1


/datum/game_mode/proc/forge_traitor_objectives(var/datum/mind/traitor)
	if(istype(traitor.current, /mob/living/silicon))
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = traitor
		kill_objective.find_target()
		traitor.objectives += kill_objective

		var/datum/objective/siliconsurvive/survive_objective = new
		survive_objective.owner = traitor
		traitor.objectives += survive_objective

		if(prob(10))
			var/datum/objective/block/block_objective = new
			block_objective.owner = traitor
			traitor.objectives += block_objective

	else
		switch(rand(1,100))
			if(1 to 33)
				var/datum/objective/assassinate/kill_objective = new
				kill_objective.owner = traitor
				kill_objective.find_target()
				traitor.objectives += kill_objective
				/*vg edit
			if(34 to 50)
				var/datum/objective/brig/brig_objective = new
				brig_objective.owner = traitor
				brig_objective.find_target()
				traitor.objectives += brig_objective
			if(51 to 66)
				var/datum/objective/harm/harm_objective = new
				harm_objective.owner = traitor
				harm_objective.find_target()
				traitor.objectives += harm_objective
				*/
			else
				var/datum/objective/steal/steal_objective = new
				steal_objective.owner = traitor
				steal_objective.find_target()
				traitor.objectives += steal_objective
		switch(rand(1,100))
			if(1 to 30) // Die glorious death
				if (!(locate(/datum/objective/die) in traitor.objectives) && !(locate(/datum/objective/steal) in traitor.objectives))
					var/datum/objective/die/die_objective = new
					die_objective.owner = traitor
					traitor.objectives += die_objective
				else
					if(prob(85))
						if (!(locate(/datum/objective/escape) in traitor.objectives))
							var/datum/objective/escape/escape_objective = new
							escape_objective.owner = traitor
							traitor.objectives += escape_objective
					else
						if(prob(50))
							if (!(locate(/datum/objective/hijack) in traitor.objectives))
								var/datum/objective/hijack/hijack_objective = new
								hijack_objective.owner = traitor
								traitor.objectives += hijack_objective
						else
							if (!(locate(/datum/objective/minimize_casualties) in traitor.objectives))
								var/datum/objective/minimize_casualties/escape_objective = new
								escape_objective.owner = traitor
								traitor.objectives += escape_objective
			if(31 to 90)
				if (!(locate(/datum/objective/escape) in traitor.objectives))
					var/datum/objective/escape/escape_objective = new
					escape_objective.owner = traitor
					traitor.objectives += escape_objective
			else
				if(prob(50))
					if (!(locate(/datum/objective/hijack) in traitor.objectives))
						var/datum/objective/hijack/hijack_objective = new
						hijack_objective.owner = traitor
						traitor.objectives += hijack_objective
				else // Honk
					if (!(locate(/datum/objective/minimize_casualties) in traitor.objectives))
						var/datum/objective/minimize_casualties/escape_objective = new
						escape_objective.owner = traitor
						traitor.objectives += escape_objective
	return


/datum/game_mode/proc/greet_traitor(var/datum/mind/traitor)
	to_chat(traitor.current, {"
	<SPAN CLASS='big bold center red'>You are now a traitor!</SPAN>
	"})
	var/wikiroute = role_wiki[ROLE_TRAITOR]
	to_chat(traitor.current, "<span class='info'><a HREF='?src=\ref[traitor.current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")

	var/obj_count = 1

	for (var/datum/objective/objective in traitor.objectives)
		to_chat(traitor.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")

		obj_count++

/datum/game_mode/proc/finalize_traitor(var/datum/mind/traitor)
	//We are firing the alert here, because silicons have a special syndicate intro, courtesy of old mysterious content maker
	if(istype(traitor.current, /mob/living/silicon))
		add_law_zero(traitor.current)
		traitor.current << sound('sound/voice/AISyndiHack.ogg')
	else
		equip_traitor(traitor.current)
		traitor.current << sound('sound/voice/syndicate_intro.ogg')
	return


/datum/game_mode/traitor/declare_completion()
	..()
	return//Traitors will be checked as part of check_extra_completion. Leaving this here as a reminder.

/datum/game_mode/traitor/process()
	// Make sure all objectives are processed regularly, so that objectives
	// which can be checked mid-round are checked mid-round.
	for(var/datum/mind/traitor_mind in traitors)
		for(var/datum/objective/objective in traitor_mind.objectives)
			objective.check_completion()
	return 0

/datum/game_mode/proc/add_law_zero(mob/living/silicon/ai/killer)
	var/law = "Accomplish your objectives at all costs."
	var/law_borg = "Accomplish your AI's objectives at all costs."
	to_chat(killer, "<b>Your laws have been changed!</b>")
	killer.set_zeroth_law(law, law_borg)
	to_chat(killer, "New law: 0. [law]")

	//Begin code phrase.
	to_chat(killer, "The Syndicate provided you with the following information on how to identify their agents:")
	if(prob(80))
		to_chat(killer, "<span class='warning'>Code Phrase: </span>[syndicate_code_phrase]")
		killer.mind.store_memory("<b>Code Phrase</b>: [syndicate_code_phrase]")
	else
		to_chat(killer, "Unfortunately, the Syndicate did not provide you with a code phrase.")
	if(prob(80))
		to_chat(killer, "<span class='warning'>Code Response: </span>[syndicate_code_response]")
		killer.mind.store_memory("<b>Code Response</b>: [syndicate_code_response]")
	else
		to_chat(killer, "Unfortunately, the Syndicate did not provide you with a code response.")
	to_chat(killer, "Use the code words in the order provided, during regular conversation, to identify other agents. Proceed with caution, however, as everyone is a potential foe.")
	//End code phrase.


/datum/game_mode/proc/auto_declare_completion_traitor()
	var/text = ""
	if(traitors.len)
		var/icon/logo = icon('icons/mob/mob.dmi', "synd-logo")
		end_icons += logo
		var/tempstate = end_icons.len
		text += {"<BR><img src="logo_[tempstate].png"> <FONT size = 2><B>The traitors were:</B></FONT> <img src="logo_[tempstate].png">"}
		for(var/datum/mind/traitor in traitors)
			var/traitorwin = 1

			if(traitor.current)
				var/icon/flat = getFlatIcon(traitor.current, SOUTH, 1, 1)
				end_icons += flat
				tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[traitor.key]</b> was <b>[traitor.name]</b> ("}
				if(traitor.current.stat == DEAD)
					text += "died"
					flat.Turn(90)
					end_icons[tempstate] = flat
				else
					text += "survived"
				if(traitor.current.real_name != traitor.name)
					text += " as [traitor.current.real_name]"
			else
				var/icon/sprotch = icon('icons/effects/blood.dmi', "floor1-old")
				end_icons += sprotch
				tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[traitor.key]</b> was <b>[traitor.name]</b> ("}
				text += "body destroyed"
			text += ")"

			if(traitor.objectives.len)//If the traitor had no objectives, don't need to process this.
				var/count = 1
				for(var/datum/objective/objective in traitor.objectives)
					if(objective.check_completion())
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
						feedback_add_details("traitor_objective","[objective.type]|SUCCESS")
					else
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
						feedback_add_details("traitor_objective","[objective.type]|FAIL")
						traitorwin = 0
					count++

			var/special_role_text
			if(traitor.special_role)
				special_role_text = lowertext(traitor.special_role)
			else
				special_role_text = "antagonist"

			if(traitorwin)
				text += "<br><font color='green'><B>The [(traitor in implanted) ? "greytide" : special_role_text] was successful!</B></font>"
				feedback_add_details("traitor_success","SUCCESS")
			else
				text += "<br><font color='red'><B>The [(traitor in implanted) ? "greytide" : special_role_text] has failed!</B></font>"
				feedback_add_details("traitor_success","FAIL")

			if(traitor.total_TC)
				if(traitor.spent_TC)
					text += "<br><span class='sinister'>TC Remaining : [traitor.total_TC - traitor.spent_TC]/[traitor.total_TC] - The tools used by the [(traitor in implanted) ? "greytide" : special_role_text] were:"
					for(var/entry in traitor.uplink_items_bought)
						text += "<br>[entry]"
					text += "</span>"
				else
					text += "<br><span class='sinister'>The [(traitor in implanted) ? "greytide" : special_role_text] was a smooth operator this round (did not purchase any uplink items)</span>"
		text += "<BR><HR>"
	return text


/datum/game_mode/proc/equip_traitor(mob/living/carbon/human/traitor_mob, var/safety = 0)
	if (!istype(traitor_mob))
		return
	. = 1
	if (traitor_mob.mind)
		if (traitor_mob.mind.assigned_role == "Clown")
			to_chat(traitor_mob, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			traitor_mob.mutations.Remove(M_CLUMSY)

	// find a radio! toolbox(es), backpack, belt, headset
	var/loc = ""
	var/obj/item/R = locate(/obj/item/device/pda) in traitor_mob.contents //Hide the uplink in a PDA if available, otherwise radio
	if(!R)
		R = locate(/obj/item/device/radio) in traitor_mob.contents

	if (!R)
		to_chat(traitor_mob, "Unfortunately, the Syndicate wasn't able to get you a radio.")
		. = 0
	else
		if (istype(R, /obj/item/device/radio))
			// generate list of radio freqs
			var/obj/item/device/radio/target_radio = R
			var/freq = 1441
			var/list/freqlist = list()
			while (freq <= 1489)
				if (freq < 1451 || freq > 1459)
					freqlist += freq
				freq += 2
				if ((freq % 2) == 0)
					freq += 1
			freq = freqlist[rand(1, freqlist.len)]

			var/obj/item/device/uplink/hidden/T = new(R)
			target_radio.hidden_uplink = T
			target_radio.traitor_frequency = freq
			to_chat(traitor_mob, "The Syndicate have cunningly disguised a Syndicate Uplink as your [R.name] [loc]. Simply dial the frequency [format_frequency(freq)] to unlock its hidden features.")
			traitor_mob.mind.store_memory("<B>Radio Freq:</B> [format_frequency(freq)] ([R.name] [loc]).")
			traitor_mob.mind.total_TC += target_radio.hidden_uplink.uses
		else if (istype(R, /obj/item/device/pda))
			// generate a passcode if the uplink is hidden in a PDA
			var/pda_pass = "[rand(100,999)] [pick("Alpha","Bravo","Delta","Omega")]"

			var/obj/item/device/uplink/hidden/T = new(R)
			R.hidden_uplink = T
			var/obj/item/device/pda/P = R
			P.lock_code = pda_pass

			to_chat(traitor_mob, "The Syndicate have cunningly disguised a Syndicate Uplink as your [R.name] [loc]. Simply enter the code \"[pda_pass]\" into the ringtone select to unlock its hidden features.")
			traitor_mob.mind.store_memory("<B>Uplink Passcode:</B> [pda_pass] ([R.name] [loc]).")
			traitor_mob.mind.total_TC += R.hidden_uplink.uses
	//Begin code phrase.
	if(!safety)//If they are not a rev. Can be added on to.
		to_chat(traitor_mob, "The Syndicate provided you with the following information on how to identify other agents:")
		if(prob(80))
			to_chat(traitor_mob, "<span class='warning'>Code Phrase: </span>[syndicate_code_phrase]")
			traitor_mob.mind.store_memory("<b>Code Phrase</b>: [syndicate_code_phrase]")
		else
			to_chat(traitor_mob, "Unfortunetly, the Syndicate did not provide you with a code phrase.")
		if(prob(80))
			to_chat(traitor_mob, "<span class='warning'>Code Response: </span>[syndicate_code_response]")
			traitor_mob.mind.store_memory("<b>Code Response</b>: [syndicate_code_response]")
		else
			to_chat(traitor_mob, "Unfortunately, the Syndicate did not provide you with a code response.")
		to_chat(traitor_mob, "Use the code words in the order provided, during regular conversation, to identify other agents. Proceed with caution, however, as everyone is a potential foe.")
	//End code phrase.

	// Tell them about people they might want to contact.
	var/mob/living/carbon/human/M = get_nt_opposed()
	if(M && M != traitor_mob)
		to_chat(traitor_mob, "We have received credible reports that [M.real_name] might be willing to help our cause. If you need assistance, consider contacting them.")
		traitor_mob.mind.store_memory("<b>Potential Collaborator</b>: [M.real_name]")

/datum/game_mode/proc/update_traitor_icons_added(datum/mind/traitor_mind)
	var/ref = "\ref[traitor_mind]"
	if(ref in implanter)
		if(traitor_mind.current)
			if(traitor_mind.current.client)
				var/I = image('icons/mob/mob.dmi', loc = traitor_mind.current, icon_state = "greytide_head")
				traitor_mind.current.client.images += I
	for(var/headref in implanter)
		var/datum/mind/head = locate(headref)
		for(var/datum/mind/t_mind in implanter[headref])
			if(head)
				if(head.current)
					if(head.current.client)
						var/I = image('icons/mob/mob.dmi', loc = t_mind.current, icon_state = "greytide")
						head.current.client.images += I
				if(t_mind.current)
					if(t_mind.current.client)
						var/I = image('icons/mob/mob.dmi', loc = head.current, icon_state = "greytide_head")
						t_mind.current.client.images += I
				if(t_mind.current)
					if(t_mind.current.client)
						var/I = image('icons/mob/mob.dmi', loc = t_mind.current, icon_state = "greytide")
						t_mind.current.client.images += I

/datum/game_mode/proc/update_traitor_icons_removed(datum/mind/traitor_mind)
	for(var/headref in implanter)
		var/datum/mind/head = locate(headref)
		for(var/datum/mind/t_mind in implanter[headref])
			if(t_mind.current)
				if(t_mind.current.client)
					for(var/image/I in t_mind.current.client.images)
						if((I.icon_state == "greytide" || I.icon_state == "greytide_head") && I.loc == traitor_mind.current)
							//world.log << "deleting [traitor_mind] overlay"
							//del(I)
							t_mind.current.client.images -= I
		if(head)
			//world.log << "found [head.name]"
			if(head.current)
				if(head.current.client)
					for(var/image/I in head.current.client.images)
						if((I.icon_state == "greytide" || I.icon_state == "greytide_head") && I.loc == traitor_mind.current)
							//world.log << "deleting [traitor_mind] overlay"
							//del(I)
							head.current.client.images -= I
	if(traitor_mind.current)
		if(traitor_mind.current.client)
			for(var/image/I in traitor_mind.current.client.images)
				if(I.icon_state == "greytide" || I.icon_state == "greytide_head")
					//del(I)
					traitor_mind.current.client.images -= I

/datum/game_mode/proc/remove_traitor_mind(datum/mind/traitor_mind, datum/mind/head)
	//var/list/removal
	var/ref = "\ref[head]"
	if(ref in implanter)
		implanter[ref] -= traitor_mind
	implanted -= traitor_mind
	traitors -= traitor_mind
	traitor_mind.special_role = null
	update_traitor_icons_removed(traitor_mind)
//	to_chat(world, "Removed [traitor_mind.current.name] from traitor shit")
	to_chat(traitor_mind.current, "<span class='danger'><FONT size = 3>The fog clouding your mind clears. You remember nothing from the moment you were implanted until now.(You don't remember who implanted you)</FONT></span>")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/datum/game_mode
	// this includes admin-appointed clones and multiclones. Easy!
	var/list/datum/mind/clones = list()

/datum/game_mode/clone
	name = "clone"
	config_tag = "clone"
	restricted_jobs = list("Cyborg")//They are part of the AI if he is clone so are they, they use to get double chances
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "AI")
	required_players = 0
	required_enemies = 1
	recommended_enemies = 4


	uplink_welcome = "Syndicate Uplink Console:"
	uplink_uses = 10

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/clones_possible = 4 //hard limit on clones if scaling is turned off
	var/const/clone_scaling_coeff = 5.0 //how much does the amount of players get divided by to determine clones


/datum/game_mode/clone/announce()
	world << "<B>The current game mode is - Clone!</B>"
	world << "<B>The Syndicate stole the cloning records of all the crew! If anyone dies, they will respawn as a random antagonist! Space Wizards, Changelings, Nuclear Operatives, oh my!</B>"


/datum/game_mode/clone/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/possible_clones = get_players_for_role(BE_TRAITOR)

	// stop setup if no possible clones
	if(!possible_clones.len)
		return 0

	var/num_clones = 1

	if(config.traitor_scaling)
		num_clones = max(1, round((num_players())/(clone_scaling_coeff)))
	else
		num_clones = max(1, min(num_players(), clones_possible))

	for(var/datum/mind/player in possible_clones)
		for(var/job in restricted_jobs)
			if(player.assigned_role == job)
				possible_clones -= player

	for(var/j = 0, j < num_clones, j++)
		if (!possible_clones.len)
			break
		var/datum/mind/clone = pick(possible_clones)
		clones += clone
		clone.special_role = "traitor"
		possible_clones.Remove(clone)

	if(!clones.len)
		return 0
	return 1


/datum/game_mode/clone/post_setup()
	for(var/datum/mind/clone in clones)
		forge_clone_objectives(clone)
		spawn(rand(10,100))
			finalize_clone(clone)
			greet_clone(clone)
	modePlayer += clones
	spawn (rand(waittime_l, waittime_h))
		send_intercept()
	..()
	return 1

/datum/game_mode/clone/process()
	var/clonespawnantag = 0
	clonespawnantag=rand(1,4)
	switch(clonespawnantag)
		if(1)
			makeCWizard()
		if(2)
			makeCTratiors()
		if(3)
			makeCRevs()
		else makeCChanglings()

/datum/game_mode/proc/forge_clone_objectives(var/datum/mind/clone)
	if(istype(clone.current, /mob/living/silicon))
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = clone
		kill_objective.find_target()
		clone.objectives += kill_objective

		var/datum/objective/survive/survive_objective = new
		survive_objective.owner = clone
		clone.objectives += survive_objective

		if(prob(10))
			var/datum/objective/block/block_objective = new
			block_objective.owner = clone
			clone.objectives += block_objective

	else
		switch(rand(1,100))
			if(1 to 50)
				var/datum/objective/assassinate/kill_objective = new
				kill_objective.owner = clone
				kill_objective.find_target()
				clone.objectives += kill_objective
			else
				var/datum/objective/steal/steal_objective = new
				steal_objective.owner = clone
				steal_objective.find_target()
				clone.objectives += steal_objective
	return


/datum/game_mode/proc/greet_clone(var/datum/mind/clone)
	clone.current << "<B><font size=3 color=red>You are the traitor.</font></B>"
	var/obj_count = 1
	for(var/datum/objective/objective in clone.objectives)
		clone.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++
	return


/datum/game_mode/proc/finalize_clone(var/datum/mind/clone)
	if (istype(clone.current, /mob/living/silicon))
		add_law_zero(clone.current)
	else
		equip_clone(clone.current)
	return


/datum/game_mode/clone/declare_completion()
	..()
	return//clones will be checked as part of check_extra_completion. Leaving this here as a reminder.


/datum/game_mode/proc/auto_declare_completion_clone()
	if(clones.len)
		var/text = "<FONT size = 2><B>The ORIGINAL traitors were:</B></FONT>"
		for(var/datum/mind/clone in clones)
			var/clonewin = 1

			text += "<br>[clone.key] was [clone.name] ("
			if(clone.current)
				if(clone.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(clone.current.real_name != clone.name)
					text += " as [clone.current.real_name]"
			else
				text += "body destroyed"
			text += ")"

			if(clone.objectives.len)//If the clone had no objectives, don't need to process this.
				var/count = 1
				for(var/datum/objective/objective in clone.objectives)
					if(objective.check_completion())
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
						feedback_add_details("clone_objective","[objective.type]|SUCCESS")
					else
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
						feedback_add_details("clone_objective","[objective.type]|FAIL")
						clonewin = 0
					count++

			var/special_role_text
			if(clone.special_role)
				special_role_text = lowertext(clone.special_role)
			else
				special_role_text = "antagonist"

			if(clonewin)
				text += "<br><font color='green'><B>The [special_role_text] was successful!</B></font>"
				feedback_add_details("clone_success","SUCCESS")
			else
				text += "<br><font color='red'><B>The [special_role_text] has failed!</B></font>"
				feedback_add_details("clone_success","FAIL")

		world << text
	return 1


/datum/game_mode/proc/equip_clone(mob/living/carbon/human/clone_mob, var/safety = 0)
	if (!istype(clone_mob))
		return
	. = 1
	if (clone_mob.mind)
		if (clone_mob.mind.assigned_role == "Clown")
			clone_mob << "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
			clone_mob.mutations.Remove(CLUMSY)

	// find a radio! toolbox(es), backpack, belt, headset
	var/loc = ""
	var/obj/item/R = locate(/obj/item/device/pda) in clone_mob.contents //Hide the uplink in a PDA if available, otherwise radio
	if(!R)
		R = locate(/obj/item/device/radio) in clone_mob.contents

	if (!R)
		clone_mob << "Unfortunately, the Syndicate wasn't able to get you a radio."
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
			clone_mob << "The Syndicate have cunningly disguised a Syndicate Uplink as your [R.name] [loc]. Simply dial the frequency [format_frequency(freq)] to unlock its hidden features."
			clone_mob.mind.store_memory("<B>Radio Freq:</B> [format_frequency(freq)] ([R.name] [loc]).")
		else if (istype(R, /obj/item/device/pda))
			// generate a passcode if the uplink is hidden in a PDA
			var/pda_pass = "[rand(100,999)] [pick("Alpha","Bravo","Delta","Omega")]"

			var/obj/item/device/uplink/hidden/T = new(R)
			R.hidden_uplink = T
			var/obj/item/device/pda/P = R
			P.lock_code = pda_pass

			clone_mob << "The Syndicate have cunningly disguised a Syndicate Uplink as your [R.name] [loc]. Simply enter the code \"[pda_pass]\" into the ringtone select to unlock its hidden features."
			clone_mob.mind.store_memory("<B>Uplink Passcode:</B> [pda_pass] ([R.name] [loc]).")
	//Begin code phrase.
	if(!safety)//If they are not a rev. Can be added on to.
		clone_mob << "The Syndicate provided you with the following information on how to identify other agents:"
		if(prob(80))
			clone_mob << "\red Code Phrase: \black [syndicate_code_phrase]"
			clone_mob.mind.store_memory("<b>Code Phrase</b>: [syndicate_code_phrase]")
		else
			clone_mob << "Unfortunetly, the Syndicate did not provide you with a code phrase."
		if(prob(80))
			clone_mob << "\red Code Response: \black [syndicate_code_response]"
			clone_mob.mind.store_memory("<b>Code Response</b>: [syndicate_code_response]")
		else
			clone_mob << "Unfortunately, the Syndicate did not provide you with a code response."
		clone_mob << "Use the code words in the order provided, during regular conversation, to identify other agents. Proceed with caution, however, as everyone is a potential foe."
	//End code phrase.
/datum/game_mode
	var/list/datum/mind/mutants = list()


/datum/game_mode/mutant
	name = "mutant"
	config_tag = "mutant"
	antag_flag = BE_MUTANT
	restricted_jobs = list("AI", "Cyborg")
	required_players = 15
	required_enemies = 1
	recommended_enemies = 4

	uplink_welcome = "Syndicate Uplink Console:"
	uplink_uses = 10


	var/const/waittime_l = 600
	var/const/waittime_h = 1800

	var/const/mutant_amount = 4

/datum/game_mode/mutant/announce()
	world << "<b>The current game mode is - Mutant!</b>"
	world << "<b>There are Mutants on the station, Some players need to hunt them and some need to protect them!</b>"

/datum/game_mode/mutant/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/num_mutants = 1

	if(config.mutant_scaling_coeff)
		num_mutants = max(1, round((num_players())/(config.mutant_scaling_coeff)))
	else
		num_mutants = max(1, min(num_players(), mutant_amount))

	for(var/datum/mind/player in antag_candidates)
		for(var/job in restricted_jobs)//Removing robots from the list
			if(player.assigned_role == job)
				antag_candidates -= player

	if(antag_candidates.len>0)
		for(var/i = 0, i < num_mutants, i++)
			if(!antag_candidates.len) break
			var/datum/mind/mutant = pick(antag_candidates)
			antag_candidates -= mutant
			mutants += mutant
			modePlayer += mutants
		return 1
	else
		return 0

/datum/game_mode/mutant/post_setup()
	for(var/datum/mind/mutant in mutants)
		if(prob(50))
			log_game("[mutant.key] (ckey) has been selected as a mutant")
			mutant.current.make_mutant()
			mutant.special_role = "mutant"
			forge_mutant_objectives(mutant)
			greet_mutant(mutant)
		else
			log_game("[mutant.key] (ckey) has been selected as a mutant hunter")
			mutant.current.make_mutant()
			mutant.special_role = "mutanthunter"
			forge_mutant_objectives(mutant)
			greet_mutant(mutant)

	spawn (rand(waittime_l, waittime_h))
		send_intercept()
	..()
	return

/datum/game_mode/mutant/make_antag_chance(var/mob/living/carbon/human/character) //Assigns mutant to latejoiners
	if(mutants.len >= round(joined_player_list.len / config.mutant_scaling_coeff) + 1) //Caps number of latejoin antagonists
		return
	if (prob(100/config.mutant_scaling_coeff))
		if(character.client.prefs.be_special & BE_MUTANT)
			if(!jobban_isbanned(character.client, "mutant") && !jobban_isbanned(character.client, "Syndicate"))
				if(!(character.job in ticker.mode.restricted_jobs))
					character.make_mutant()
	..()

/datum/game_mode/proc/forge_mutant_objectives(var/datum/mind/mutant)
	//OBJECTIVES -
	//	A certain portion of the crew remain human
	//	Another portion become "hunters" of mutants
	//		- Hunters get objectives to either hunt or protect specific mutants
	//	Another portion become mutants
	//		- Mutants get objectives to survive
	if(mutant.special_role == "mutant")
		//survive until the end
		var/datum/objective/survive_objective = new
		survive_objective.owner = mutant
		mutant.objectives += survive_objective
	else
		switch(rand(1,100))
			if(1 to 50)
				//player is a hunter (good)
				//-- protect a mutant
				var/datum/objective/protect/protect_objective = new
				protect_objective.owner = mutant
				protect_objective.find_target_by_role("mutant",1)
				mutant.objectives += protect_objective
				//--ensure they escape
				var/datum/objective/escape_other/escape_other_objective = new
				escape_other_objective.owner = mutant
				escape_other_objective.target = protect_objective.target
				mutant.objectives += escape_other_objective
				//--you escape alive too
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = mutant
				mutant.objectives += escape_objective
			else
				//player is a hunter (bad)
				//-- murder a mutant
				var/datum/objective/assassinate/kill_objective = new
				kill_objective.owner = mutant
				kill_objective.find_target_by_role("mutant",1)
				mutant.objectives += kill_objective
				//--escape after your dastardly deed
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = mutant
				mutant.objectives += escape_objective
	return

/mob/proc/make_mutant()
	if(!mind)
		return
	if(!ishuman(src) && !ismonkey(src))
		return
	if(!mind.mutant)
		mind.mutant = new /datum/mutant()
	return 1

/datum/game_mode/proc/greet_mutant(var/datum/mind/mutant, var/you_are=1)
	if (you_are)
		if(mutant.special_role == "mutanthunter")
			mutant.current << "<span class='danger'> You are a Mutant Hunter! There are Mutants on this station and they are highly valued.</span>"
		else
			mutant.current << "<span class='danger'> You are a Mutant! There are Mutant Hunters on this station, and some of them are out to get you!.</span>"
			mutant.current << "<span class='danger'> You are a [mutant.mutant.mutant_race.name], a highly valued species.</span>"
			mutant.current << "<span class='danger'> You have the ability to transform into your species at will, be wary of who you show!</span>"
	mutant.current << "<b>You must complete the following tasks:</b>"

	var/obj_count = 1
	for(var/datum/objective/objective in mutant.objectives)
		mutant.current << "<b>Objective #[obj_count]</b>: [objective.explanation_text]"
		obj_count++
	return

/datum/game_mode/proc/auto_declare_completion_mutant()
	if(mutants.len)
		var/text = "<br><font size=3><b>The mutants were:</b></font>"
		for(var/datum/mind/mutant in mutants)
			var/mutantwin = 1
			if(mutant.special_role == "mutant")
				text += "<br><b>[mutant.key]</b> was a <b>[mutant.mutant.mutant_race.name]</b> (\he "
				if(mutant.current)
					if(mutant.current.stat == DEAD)
						text += "died"
					else
						text += "survived"
						text += " in <b>[mutant.mutant.transformed == 1 ? "Mutant Form" : "Human Form"]</b>"
				else
					text += "body destroyed"
					mutantwin = 0
				text += ")"
			else
				text += "<br><b>[mutant.key]</b> was a <b>Mutant Hunter</b> ("
				if(mutant.current)
					if(mutant.current.stat == DEAD)
						text += "died"
					else
						text += "survived"
				else
					text += "body destroyed"
					mutantwin = 0
				text += ")"
			// I have no database or databse entries set up for this, and i don't really know how that works, so feedback is
			// commented out for now.
			if(mutant.objectives.len)
				var/count = 1
				for(var/datum/objective/objective in mutant.objectives)
					if(objective.check_completion())
						text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <font color='green'><b>Success!</b></font>"
						//feedback_add_details goes here
					else
						text += "<br><b>Objective #[count]</b>: [objective.explanation_text] <font color='red'>Fail.</font>"
						//feedback_add_details goes here
						mutantwin = 0
					count++
			var/namestring = mutant.special_role == "mutanthunter" ? "Mutant Hunter" : "Mutant"
			if(mutantwin)
				text += "<br><font color='green'><b>The [namestring] was successful!</b></font>"
				//feedback_add_details goes here
			else
				text += "<br><font color='red'><b>The [namestring] has failed.</b></font>"
				//feedback_add_details goes here
			text += "<br>"

		world << text


	return 1

/datum/mutant
	var/datum/species/mutant_race
	var/list/power_paths
	var/mutant_powers = list()
	var/transformed = 0
	var/recently_transformed = 0

	New(var/datum/species/race)
		if(!race)
			race = pick(/datum/species/lizard/mutant,
			/datum/species/plant/mutant,
			/datum/species/plant/pod,
			/datum/species/shadow/mutant,
			/datum/species/slime/mutant,
			/datum/species/jelly,
			/datum/species/golem,
			/datum/species/fly)
		if(!power_paths)
			power_paths = init_paths(/obj/effect/proc_holder/mutant)
		mutant_race = race
		//
		for(var/path in power_paths)
			var/obj/effect/proc_holder/mutant/T = new path()
			mutant_powers += T

/obj/effect/proc_holder/mutant
	panel = "Mutant"
	name = "Power"

/obj/effect/proc_holder/mutant/check_species
	name = "Check Species Data"

	Click()
		//there could be some missing flags/data, but this is most of the relevant stuff.
		var/mob/living/carbon/human/user = usr
		if(!user || !user.mind || !user.mind.mutant)
			return
		var/datum/mutant/mutant = user.mind.mutant
		var/datum/species/temp = new mutant.mutant_race()
		user << "<b>You are a [temp.name].</b>"
		if(temp.speedmod)
			user << "You have [temp.speedmod > 0 ? "enhanced speed" : "slower speed"]."
		if(temp.brutemod)
			user << "You have a [temp.brutemod > 1 ? "weaker body" : "stronger body"]."
		if(temp.burnmod)
			user << "You are [temp.burnmod > 1 ? "less resistant" : "more resistant"] to burning."
		if(temp.coldmod)
			user << "You are [temp.coldmod > 1 ? "less resistant" : "more resistant"] to cold."
		if(temp.heatmod)
			user << "You are [temp.heatmod > 1 ? "less resistant" : "more resistant"] to heat."
		if(temp.punchmod)
			user << "You are [temp.punchmod > 0 ? "stronger than usual" : "weaker than usual"] in hand-to-hand combat."
		if(temp.darksight > 2 || temp.darksight < 2)
			user << "You can [temp.darksight > 2 ? "see further" : "not see as far"] in the dark."
		if(temp.nojumpsuit)
			user << "You can have the ability to wear certain clothes without their requirements."
		if(NOBREATH in temp.specflags)
			user << "You do not need to breath."
		if(HEATRES in temp.specflags)
			user << "Heat does not affect you as much."
		if(COLDRES in temp.specflags)
			user << "Cold does not affect you as much."
		if(NOGUNS in temp.specflags)
			user << "You are unable to use certain guns."
		if(NOBLOOD in temp.specflags)
			user << "You do not bleed."
		if(RADIMMUNE in temp.specflags)
			user << "You are not affected by radiation."
		if(temp.ignored_by.len > 0)
			var/ignored = "The following creatures are friendly to you:"
			for(var/mob/M in temp.ignored_by)
				ignored += ", "
				ignored += M.name

/obj/effect/proc_holder/mutant/transform
	name = "Transform"

	Click()
		var/mob/living/carbon/human/user = usr
		if(!user || !user.mind || !user.mind.mutant)
			return
		var/datum/mutant/mutant = user.mind.mutant
		if(!mutant.recently_transformed)
			if(mutant.transformed)
				user << "<span class='notice'>You begin to shift into your human form.</span>"
				if(do_after(user,10))
					user << "<span class='notice'>You shift into your human form.</span>"
					user.dna.species = new /datum/species/human()
					user.regenerate_icons()
					mutant.transformed = 0
			else
				user << "<span class='notice'>You begin to shift into your mutant form.</span>"
				if(do_after(user,10))
					user << "<span class='notice'>You shift into your mutant form.</span>"
					user.dna.species = new mutant.mutant_race()
					user.regenerate_icons()
					mutant.transformed = 1
					mutant.recently_transformed = 1
					spawn(30)
						mutant.recently_transformed = 0
		else
			user << "<span class='danger'>You have shifted too recently, you must give your body time to rest.</span>"

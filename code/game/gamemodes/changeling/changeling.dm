/datum/game_mode
	var/list/datum/mind/changelings = list()


/datum/game_mode/changeling
	name = "changeling"
	config_tag = "changeling"
	restricted_jobs = list("AI", "Cyborg")
	required_players = 15
	required_enemies = 1
	recommended_enemies = 4

	uplink_welcome = "Syndicate Uplink Console:"
	uplink_uses = 10

	var
		const
			prob_int_murder_target = 50 // intercept names the assassination target half the time
			prob_right_murder_target_l = 25 // lower bound on probability of naming right assassination target
			prob_right_murder_target_h = 50 // upper bound on probability of naimg the right assassination target

			prob_int_item = 50 // intercept names the theft target half the time
			prob_right_item_l = 25 // lower bound on probability of naming right theft target
			prob_right_item_h = 50 // upper bound on probability of naming the right theft target

			prob_int_sab_target = 50 // intercept names the sabotage target half the time
			prob_right_sab_target_l = 25 // lower bound on probability of naming right sabotage target
			prob_right_sab_target_h = 50 // upper bound on probability of naming right sabotage target

			prob_right_killer_l = 25 //lower bound on probability of naming the right operative
			prob_right_killer_h = 50 //upper bound on probability of naming the right operative
			prob_right_objective_l = 25 //lower bound on probability of determining the objective correctly
			prob_right_objective_h = 50 //upper bound on probability of determining the objective correctly

			waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
			waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

			const/changeling_amount = 4

/datum/game_mode/changeling/announce()
	world << "<B>The current game mode is - Changeling!</B>"
	world << "<B>There are alien changelings on the station. Do not let the changelings succeed!</B>"

/datum/game_mode/changeling/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_changelings = get_players_for_role(BE_CHANGELING)

	for(var/datum/mind/player in possible_changelings)
		for(var/job in restricted_jobs)//Removing robots from the list
			if(player.assigned_role == job)
				possible_changelings -= player

	if(possible_changelings.len>0)
		for(var/i = 0, i < changeling_amount, i++)
			if(!possible_changelings.len) break
			var/datum/mind/changeling = pick(possible_changelings)
			possible_changelings -= changeling
			changelings += changeling
			modePlayer += changelings
		return 1
	else
		return 0

/datum/game_mode/changeling/post_setup()
	for(var/datum/mind/changeling in changelings)
		grant_changeling_powers(changeling.current)
		changeling.special_role = "Changeling"
		forge_changeling_objectives(changeling)
		greet_changeling(changeling)

	spawn (rand(waittime_l, waittime_h))
		send_intercept()
	..()
	return


/datum/game_mode/proc/forge_changeling_objectives(var/datum/mind/changeling)
	//OBJECTIVES - Always absorb 5 genomes, plus random traitor objectives.
	//If they have two objectives as well as absorb, they must survive rather than escape
	//No escape alone because changelings aren't suited for it and it'd probably just lead to rampant robusting
	//If it seems like they'd be able to do it in play, add a 10% chance to have to escape alone

	var/datum/objective/absorb/absorb_objective = new
	absorb_objective.owner = changeling
	absorb_objective.gen_amount_goal(6,8)
	changeling.objectives += absorb_objective

	switch(rand(1,100))
		if(1 to 45)

			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = changeling
			kill_objective.find_target()
			changeling.objectives += kill_objective

			if (!(locate(/datum/objective/escape) in changeling.objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = changeling
				changeling.objectives += escape_objective

		if(46 to 90)

			var/list/datum/objective/theft = PickObjectiveFromList(GenerateTheft(changeling.assigned_role,changeling))
			var/datum/objective/steal/steal_objective = pick(theft)
			steal_objective.owner = changeling
			changeling.objectives += steal_objective

			if (!(locate(/datum/objective/escape) in changeling.objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = changeling
				changeling.objectives += escape_objective

		else

			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = changeling
			kill_objective.find_target()
			changeling.objectives += kill_objective

			var/list/datum/objective/theft = PickObjectiveFromList(GenerateTheft(changeling.assigned_role,changeling))
			var/datum/objective/steal/steal_objective = pick(theft)
			steal_objective.owner = changeling
			changeling.objectives += steal_objective

			if (!(locate(/datum/objective/survive) in changeling.objectives))
				var/datum/objective/survive/survive_objective = new
				survive_objective.owner = changeling
				changeling.objectives += survive_objective
	return

/datum/game_mode/proc/greet_changeling(var/datum/mind/changeling, var/you_are=1)
	if (you_are)
		changeling.current << "<B>\red You are a changeling!</B>"
	changeling.current << "<b>\red Use say \":g message\" to communicate with your fellow changelings. Remember: you get all of their absorbed DNA if you absorb them.</b>"
	changeling.current << "<B>You must complete the following tasks:</B>"

	var/obj_count = 1
	for(var/datum/objective/objective in changeling.objectives)
		changeling.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++
	return

/*/datum/game_mode/changeling/check_finished()
	var/changelings_alive = 0
	for(var/datum/mind/changeling in changelings)
		if(!istype(changeling.current,/mob/living/carbon))
			continue
		if(changeling.current.stat==2)
			continue
		changelings_alive++

	if (changelings_alive)
		changelingdeath = 0
		return ..()
	else
		if (!changelingdeath)
			changelingdeathtime = world.time
			changelingdeath = 1
		if(world.time-changelingdeathtime > TIME_TO_GET_REVIVED)
			return 1
		else
			return ..()
	return 0*/

/datum/game_mode/proc/grant_changeling_powers(mob/living/carbon/human/changeling_mob)
	if (!istype(changeling_mob))
		return
	changeling_mob.make_changeling()

/datum/game_mode/proc/auto_declare_completion_changeling()
	for(var/datum/mind/changeling in changelings)
		var/changelingwin = 1
		var/changeling_name
		var/totalabsorbed = 0
		if((changeling.current) && (changeling.current.changeling))
			totalabsorbed = ((changeling.current.changeling.absorbed_dna.len) - 1)
			changeling_name = "[changeling.current.real_name] (played by [changeling.key])"
			world << "<B>The changeling was [changeling_name].</B>"
			world << "<b>[changeling.current.gender=="male"?"His":"Her"] changeling ID was [changeling.current.gender=="male"?"Mr.":"Mrs."] [changeling.current.changeling.changelingID]."
			world << "<B>Genomes absorbed: [totalabsorbed]</B>"

			var/count = 1
			for(var/datum/objective/objective in changeling.objectives)
				if(objective.check_completion())
					world << "<B>Objective #[count]</B>: [objective.explanation_text] \green <B>Success</B>"
					feedback_add_details("changeling_objective","[objective.type]|SUCCESS")
				else
					world << "<B>Objective #[count]</B>: [objective.explanation_text] \red Failed"
					feedback_add_details("changeling_objective","[objective.type]|FAIL")
					changelingwin = 0
				count++

		else
			changeling_name = "[changeling.key] (character destroyed)"
			changelingwin = 0

		if(changelingwin)
			world << "<B>The changeling was successful!<B>"
			feedback_add_details("changeling_success","SUCCESS")
		else
			world << "<B>The changeling has failed!<B>"
			feedback_add_details("changeling_success","FAIL")
	return 1

/datum/changeling //stores changeling powers, changeling recharge thingie, changeling absorbed DNA and changeling ID (for changeling hivemind)
	var/changeling_level = 0
	var/list/absorbed_dna = list()
	var/changeling_fakedeath = 0
	var/chem_charges = 20.00
	var/chem_recharge_multiplier = 1
	var/chem_storage = 50
	var/sting_range = 1
	var/changelingID = "none"
	var/mob/living/host = null
	var/geneticdamage = 0.0
	var/isabsorbing = 0
	var/geneticpoints = 5
	var/purchasedpowers = list()



/datum/changeling/New()
	..()
	var/list/possibleIDs = list("Alpha","Beta","Gamma","Delta","Epsilon","Zeta","Eta","Theta","Iota","Kappa","Lambda","Mu","Nu","Xi","Omicron","Pi","Rho","Sigma","Tau","Upsilon","Phi","Chi","Psi","Omega")

	for(var/mob/living/carbon/aChangeling in world)
		if(aChangeling.changeling)
			possibleIDs -= aChangeling.changeling.changelingID

	if(possibleIDs.len)
		changelingID = pick(possibleIDs)
	else
		changelingID = "[rand(1,1000)]"
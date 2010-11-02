/datum/game_mode/changeling
	name = "changeling"
	config_tag = "changeling"

	/var/datum/mind/changeling
	var/list/datum/mind/changelings = list()

	var/const/prob_int_murder_target = 50 // intercept names the assassination target half the time
	var/const/prob_right_murder_target_l = 25 // lower bound on probability of naming right assassination target
	var/const/prob_right_murder_target_h = 50 // upper bound on probability of naimg the right assassination target

	var/const/prob_int_item = 50 // intercept names the theft target half the time
	var/const/prob_right_item_l = 25 // lower bound on probability of naming right theft target
	var/const/prob_right_item_h = 50 // upper bound on probability of naming the right theft target

	var/const/prob_int_sab_target = 50 // intercept names the sabotage target half the time
	var/const/prob_right_sab_target_l = 25 // lower bound on probability of naming right sabotage target
	var/const/prob_right_sab_target_h = 50 // upper bound on probability of naming right sabotage target

	var/const/prob_right_killer_l = 25 //lower bound on probability of naming the right operative
	var/const/prob_right_killer_h = 50 //upper bound on probability of naming the right operative
	var/const/prob_right_objective_l = 25 //lower bound on probability of determining the objective correctly
	var/const/prob_right_objective_h = 50 //upper bound on probability of determining the objective correctly

	var/const/laser = 1
	var/const/hand_tele = 2
	var/const/plasma_bomb = 3
	var/const/jetpack = 4
	var/const/captain_card = 5
	var/const/captain_suit = 6

	var/const/destroy_plasma = 1
	var/const/destroy_ai = 2
	var/const/kill_monkeys = 3
	var/const/cut_power = 4

	var/const/percentage_plasma_destroy = 70 // what percentage of the plasma tanks you gotta destroy
	var/const/percentage_station_cut_power = 80 // what percentage of the tiles have to have power cut
	var/const/percentage_station_evacuate = 80 // what percentage of people gotta leave - you also gotta change the objective in the traitor menu

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/changelingdeathticker = 0

/datum/game_mode/changeling/announce()
	world << "<B>The current game mode is - Changeling!</B>"
	world << "<B>There is an alien changeling on the station. Do not let the changeling succeed!</B>"

/datum/game_mode/changeling/pre_setup()
	// Can't pick a changeling here, as we don't want him to then become the AI.
	return 1

/datum/game_mode/changeling/post_setup()

	var/list/possible_changelings = get_possible_changelings()

	if(possible_changelings.len>0)
		changeling = pick(possible_changelings)


	grant_changeling_powers(changeling.current)
	changelings += changeling

	//OBJECTIVES - Always absorb 5 genomes, plus random traitor objectives.
	//If they have two objectives as well as absorb, they must survive rather than escape
	//No escape alone because changelings aren't suited for it and it'd probably just lead to rampant robusting
	//If it seems like they'd be able to do it in play, add a 10% chance to have to escape alone

	switch(rand(1,100))
		if(1 to 45)

			var/datum/objective/absorb/absorb_objective = new
			absorb_objective.owner = changeling
			absorb_objective.gen_num_to_eat()
			changeling.objectives += absorb_objective

			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = changeling
			kill_objective.find_target()
			changeling.objectives += kill_objective

			var/datum/objective/escape/escape_objective = new
			escape_objective.owner = changeling
			changeling.objectives += escape_objective

		if(46 to 90)

			var/datum/objective/absorb/absorb_objective = new
			absorb_objective.owner = changeling
			absorb_objective.gen_num_to_eat()
			changeling.objectives += absorb_objective

			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = changeling
			steal_objective.find_target()
			changeling.objectives += steal_objective

			var/datum/objective/escape/escape_objective = new
			escape_objective.owner = changeling
			changeling.objectives += escape_objective

		else

			var/datum/objective/absorb/absorb_objective = new
			absorb_objective.owner = changeling
			absorb_objective.gen_num_to_eat()
			changeling.objectives += absorb_objective

			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = changeling
			kill_objective.find_target()
			changeling.objectives += kill_objective

			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = changeling
			steal_objective.find_target()
			changeling.objectives += steal_objective

			var/datum/objective/survive/survive_objective = new
			survive_objective.owner = changeling
			changeling.objectives += survive_objective


	changeling.current << "<B>\red You are a changeling!</B>"
	changeling.current << "<B>You must complete the following tasks:</B>"

	var/obj_count = 1
	for(var/datum/objective/objective in changeling.objectives)
		changeling.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++

	spawn (rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/changeling/proc/get_possible_changelings()
	var/list/candidates = list()
	for(var/mob/living/carbon/player in world)
		if (player.client)
			if(player.be_syndicate)
				candidates += player.mind

	if(candidates.len < 1)
		for(var/mob/living/carbon/player in world)
			if (player.client)
				candidates += player.mind

	return candidates

//Centcom Update - in testing, copied mostly from Wizard.

/datum/game_mode/changeling/send_intercept()
	var/intercepttext = "<FONT size = 3><B>Cent. Com. Update</B> Requested staus information:</FONT><HR>"
	intercepttext += "<B> Cent. Com has recently been contacted by the following syndicate affiliated organisations in your area, please investigate any information you may have:</B>"

	var/list/possible_modes = list()
	possible_modes.Add("revolution", "wizard", "nuke", "traitor", "malf", "changeling", "cult")
	possible_modes -= "[ticker.mode]"
	var/number = pick(2, 3)
	var/i = 0
	for(i = 0, i < number, i++)
		possible_modes.Remove(pick(possible_modes))
	possible_modes.Insert(rand(possible_modes.len), "[ticker.mode]")

	var/datum/intercept_text/i_text = new /datum/intercept_text
	for(var/A in possible_modes)
		intercepttext += i_text.build(A, changeling)

	for (var/obj/machinery/computer/communications/comm in world)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper- 'Cent. Com. Status Summary'"
			intercept.info = intercepttext

			comm.messagetitle.Add("Cent. Com. Status Summary")
			comm.messagetext.Add(intercepttext)

	command_alert("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.")
	world << sound('intercept.ogg')

/datum/game_mode/changeling/check_finished()
	if(changeling.current.stat==2)
		if(changelingdeathticker>=900)
			return 1
		changelingdeathticker++

	if(changeling.current.stat!=2)
		if(changelingdeathticker)
			changelingdeathticker = 0

	return ..()

/datum/game_mode/changeling/declare_completion()
	for(var/datum/mind/changeling in changelings)
		var/changelingwin = 1
		var/changeling_name
		var/totalabsorbed = 0
		if (changeling.current)
			totalabsorbed = changeling.current.absorbed_dna.len - 1

		if(changeling.current)
			changeling_name = "[changeling.current.real_name] (played by [changeling.key])"
		else
			changeling_name = "[changeling.key] (character destroyed)"

		world << "<B>The changeling was [changeling_name]</B>"
		world << "<B>Genomes absorbed: [totalabsorbed]</B>"

		var/count = 1
		for(var/datum/objective/objective in changeling.objectives)
			if(objective.check_completion())
				world << "<B>Objective #[count]</B>: [objective.explanation_text] \green <B>Success</B>"
			else
				world << "<B>Objective #[count]</B>: [objective.explanation_text] \red Failed"
				changelingwin = 0
			count++

		if(changelingwin)
			world << "<B>The changeling was successful!<B>"
		else
			world << "<B>The changeling has failed!<B>"
	return 1
//	. = ..()

/datum/game_mode/changeling/proc/get_mob_list()
	var/list/mobs = list()
	for(var/mob/living/player in world)
		if (player.client)
			mobs += player
	return mobs

/datum/game_mode/changeling/proc/pick_human_name_except(excluded_name)
	var/list/names = list()
	for(var/mob/living/player in world)
		if (player.client && (player.real_name != excluded_name))
			names += player.real_name
	if(!names.len)
		return null
	return pick(names)

/datum/game_mode/changeling/proc/grant_changeling_powers(mob/living/carbon/human/changeling_mob)
	if (!istype(changeling_mob))
		return
	changeling_mob.make_changeling()
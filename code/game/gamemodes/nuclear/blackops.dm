/datum/game_mode/nuclear/blackops
	name = "black ops"
	config_tag = "blackops"
	required_players = 20 // 20 players - 5 players to be the nuke ops = 15 players remaining
	required_enemies = 5
	recommended_enemies = 5
	antag_flag = BE_OPERATIVE
	enemy_minimum_age = 14
	enemy_name = "black ops agent"
	var/AI_magnet_applied = FALSE
	var/datum/mind/blackops_objective_holder = new/datum/mind
	disable_nuke = 1

/datum/game_mode/nuclear/blackops/announce()
	world << "<B>The current game mode is - Black Ops!</B>"
	world << "<B>A [syndicate_name()] Black Ops team is approaching [station_name()]!</B>"
	world << "A [syndicate_name()] Black Ops team is attempting to attack the station and cause chaos! Don't let them succeed!"

/datum/game_mode/nuclear/blackops/post_setup()

	var/list/turf/synd_spawn = list()

	for(var/obj/effect/landmark/A in landmarks_list)
		if(A.name == "Syndicate-Spawn")
			synd_spawn += get_turf(A)
			continue

	var/obj/effect/landmark/uplinklocker = locate("landmark*Syndicate-Uplink")	//i will be rewriting this shortly // no you arent
	var/obj/effect/landmark/nuke_spawn = locate("landmark*Nuclear-Bomb")

	var/leader_selected = 0
	var/agent_number = 1
	var/spawnpos = 1
	forge_blackops_objectives()
	for(var/datum/mind/synd_mind in syndicates)
		if(spawnpos > synd_spawn.len)
			spawnpos = 2
		synd_mind.current.loc = synd_spawn[spawnpos]

		greet_blackops(synd_mind)
		equip_syndicate(synd_mind.current)

		if(!leader_selected)
			prepare_blackops_leader(synd_mind)
			leader_selected = 1
		else
			synd_mind.current.real_name = "[syndicate_name()] Operative #[agent_number]"
			agent_number++
		spawnpos++
		update_synd_icons_added(synd_mind)

	if(uplinklocker)
		new /obj/structure/closet/syndicate/nuclear(uplinklocker.loc)
	if(nuke_spawn)
		new /obj/machinery/computer/syndicate_blackops_console(nuke_spawn.loc)
	return ..()

/datum/game_mode/nuclear/blackops/proc/greet_blackops(datum/mind/syndicate, you_are=1)
	if (you_are)
		syndicate.current << "<span class='notice'>You are a [syndicate_name()] agent!</span>"
	var/obj_count = 1
	for(var/datum/objective/objective in blackops_objective_holder.objectives)
		syndicate.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++
	return

/datum/game_mode/nuclear/blackops/proc/prepare_blackops_leader(datum/mind/synd_mind)
	var/leader_title = pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord")
	spawn(1)
		NukeNameAssign(nukelastname(synd_mind.current),syndicates) //allows time for the rest of the syndies to be chosen
	synd_mind.current.real_name = "[syndicate_name()] [leader_title]"
	synd_mind.current << "<B>You are the Syndicate [leader_title] for this mission. You are responsible for the distribution of telecrystals and your ID is the only one who can open the launch bay doors.</B>"
	synd_mind.current << "<B>If you feel you are not up to this task, give your ID to another operative.</B>"

	var/list/foundIDs = synd_mind.current.search_contents_for(/obj/item/weapon/card/id)
	if(foundIDs.len)
		for(var/obj/item/weapon/card/id/ID in foundIDs)
			ID.name = "lead agent card"
			ID.access += access_syndicate_leader
	else
		message_admins("Warning: Black Ops spawned without access to leave their spawn area!")
	return


/datum/game_mode/nuclear/blackops/proc/forge_blackops_objectives()
	// Blacks ops, being a nuke squad with no nuke needed, get 10 objectives to accomplish.
	// It's held on the holder mind so that the crew can share objectives.
	var/datum/objective/assassinate/syndobj1 = new
	syndobj1.owner = blackops_objective_holder
	blackops_objective_holder.objectives += syndobj1
	syndobj1.find_target()

	var/datum/objective/assassinate/syndobj2 = new
	syndobj2.owner = blackops_objective_holder
	blackops_objective_holder.objectives += syndobj2
	syndobj2.find_target()

	var/datum/objective/assassinate/syndobj3 = new
	syndobj3.owner = blackops_objective_holder
	blackops_objective_holder.objectives += syndobj3
	syndobj3.find_target()

	var/datum/objective/kidnap/syndobj4 = new
	syndobj4.owner = blackops_objective_holder
	blackops_objective_holder.objectives += syndobj4
	syndobj4.find_target()

	var/datum/objective/kidnap/syndobj5 = new
	syndobj5.owner = blackops_objective_holder
	blackops_objective_holder.objectives += syndobj5
	syndobj5.find_target()

	var/list/possible_targets = active_ais(1)
	if(possible_targets.len)
		var/mob/living/silicon/ai/target_ai = pick(possible_targets)
		var/target = target_ai.mind

		if(target)
			var/datum/objective/ai_mag/syndobj6 = new
			syndobj6.owner = blackops_objective_holder
			blackops_objective_holder.objectives += syndobj6
			syndobj6.find_target()

		else
			var/datum/objective/kidnap/syndobj6 = new
			syndobj6.owner = blackops_objective_holder
			blackops_objective_holder.objectives += syndobj6
			syndobj6.find_target()

	else
		var/datum/objective/kidnap/syndobj6 = new
		syndobj6.owner = blackops_objective_holder
		blackops_objective_holder.objectives += syndobj6
		syndobj6.find_target()

/datum/game_mode/nuclear/blackops/check_finished() //to be called by ticker
	if(replacementmode && round_converted == 2)
		return replacementmode.check_finished()
	if(SSshuttle.emergency.mode >= SHUTTLE_ENDGAME || station_was_nuked)
		return 1
	if(are_operatives_dead())
		return 1
	if(operatives_returned_to_home)
		return 1
	..()

/datum/game_mode/proc/auto_declare_completion_blackops()
	if( syndicates.len || (ticker && istype(ticker.mode,/datum/game_mode/nuclear/blackops)) )
		var/datum/game_mode/nuclear/blackops/bops = ticker.mode
		var/text = "<br><font size=3><b>The syndicate operatives had the following objectives:</b></font>"
		if(bops.blackops_objective_holder.objectives.len)
			var/objectives
			var/count = 1
			for(var/datum/objective/objective in bops.blackops_objective_holder.objectives)
				if(objective.check_completion())
					objectives += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
					feedback_add_details("traitor_objective","[objective.type]|SUCCESS")
				else
					objectives += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
					feedback_add_details("traitor_objective","[objective.type]|FAIL")
				count++
			text += objectives
		world << text
		..()
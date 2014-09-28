/datum/game_mode
	var/list/datum/mind/crystal_holders = list()

/datum/game_mode/crystal
	name = "crystal"
	config_tag = "crystal"
	restricted_jobs = list("Cyborg", "AI", "Captain", "Head of Personnel", "Chief Medical Officer", "Research Director", "Chief Engineer", "Head of Security")
	protected_jobs = list("Security Officer", "Warden", "Detective")
	required_players = 12
	required_enemies = 3
	recommended_enemies = 3

/datum/game_mode/crystal/announce()
	world << "<B>The current game mode is - Crystal!</B>"
	world << "<B>There are crystal zealots trying to bring a powerful alien crystal to centcom. Stop them at all costs!</B>"

/datum/game_mode/crystal/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/possible_zealots = get_players_for_role(BE_TRAITOR) // will make a new role type if this mode becomes a serious candidate for being a new mode type
	if(!possible_zealots.len)
		return 0

	for(var/i = 0; i < required_enemies; i++)
		if(!possible_zealots.len)
			break
		var/datum/mind/zealot = pick(possible_zealots)
		crystal_holders += zealot
		zealot.special_role = "crystal zealot"
		possible_zealots -= zealot

	if(crystal_holders.len < required_enemies)
		return 0
	return 1

/datum/game_mode/crystal/post_setup()
	for(var/datum/mind/zealot in crystal_holders)
		spawn(rand(10,100))
			equip_and_greet_zealots(zealot)
	modePlayer += traitors
	spawn (rand(waittime_l, waittime_h))
		send_intercept()
	..()
	return 1

/datum/game_mode/crystal/proc/assign_objectives(var/datum/mind/zealot)
	var/datum/objective/crystal_steal/crystal_obj = new
	crystal_obj.owner = zealot
	crystal_obj.find_target()
	zealot.objectives += crystal_obj

	zealot.current << "<B><font size=3 color=red>You are the zealot.</font></B>"
	var/obj_count = 1
	for(var/datum/objective/objective in zealot.objectives)
		zealot.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++
	zealot.current << "\nYou are tasked with smuggling the required number of crystals onto Central Command from their Escape Shuttle."
	zealot.current << "If you do not have enough crystals you can steal some from other zealots who have the same task."
	zealot.current << "Your crystal glows when other crystals are near, examine it to see how close you are. You can touch your crystal to activate it's alien power."
	zealot.current << "All crystals have different powers which you can use to help complete your objective, make sure you aren't seen with it however."

/datum/game_mode/crystal/proc/equip_and_greet_zealots(var/datum/mind/zealot)

	if(crystal_types.len)
		if(zealot && ishuman(zealot.current))

			var/crystal_type = pick_n_take(crystal_types)
			var/mob/living/carbon/human/H = zealot.current

			var/obj/item/crystal/C = new crystal_type(null)

			var/obj/item/weapon/storage/backpack/B = locate() in H

			if(B && B.storage_slots > B.contents.len)
				C.loc = B
			else
				C.loc = H
				H.put_in_hands(C)

			assign_objectives(zealot)

			return


/datum/game_mode/proc/auto_declare_completion_crystal()
	if(crystal_holders.len)
		var/text = "<FONT size = 2><B>The zealots were:</B></FONT>"
		for(var/datum/mind/zealot in crystal_holders)
			var/zealotwin = 1

			text += "<br>[zealot.key] was [zealot.name] ("
			if(zealot.current)
				if(zealot.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(zealot.current.real_name != zealot.name)
					text += " as [zealot.current.real_name]"
			else
				text += "body destroyed"
			text += ")"

			if(zealot.objectives.len)//If the zealot had no objectives, don't need to process this.
				var/count = 1
				for(var/datum/objective/objective in zealot.objectives)
					if(objective.check_completion())
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
						feedback_add_details("traitor_objective","[objective.type]|SUCCESS")
					else
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
						feedback_add_details("traitor_objective","[objective.type]|FAIL")
						zealotwin = 0
					count++

			var/special_role_text
			if(zealot.special_role)
				special_role_text = lowertext(zealot.special_role)
			else
				special_role_text = "antagonist"

			if(zealotwin)
				text += "<br><font color='green'><B>The [special_role_text] was successful!</B></font>"
				feedback_add_details("traitor_success","SUCCESS")
			else
				text += "<br><font color='red'><B>The [special_role_text] has failed!</B></font>"
				feedback_add_details("traitor_success","FAIL")

		world << text
	return 1
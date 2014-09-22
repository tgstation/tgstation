/**
 * vox heist roundtype
 */

/datum/game_mode/
	var/list/datum/mind/raiders = list()  //Antags.

/datum/game_mode/heist
	name = "heist"
	config_tag = "heist"
	required_players = 15
	required_players_secret = 25
	required_enemies = 4
	recommended_enemies = 6

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/list/raid_objectives = list()     //Raid objectives.

/datum/game_mode/heist/announce()
	world << {"
		<B>The current game mode is - Heist!</B>
		<B>An unidentified bluespace signature has slipped past the Icarus and is approaching [station_name()]!</B>
		Whoever they are, they're likely up to no good. Protect the crew and station resources against this dastardly threat!
		<B>Raiders:</B> Loot [station_name()] for anything and everything you need.
		<B>Personnel:</B> Repel the raiders and their low, low prices and/or crossbows."}

/datum/game_mode/heist/can_start()

	if(!..())
		return 0

	var/list/candidates = get_players_for_role(BE_RAIDER)
	var/raider_num = 0

	//Check that we have enough vox.
	if(candidates.len < required_enemies)
		return 0
	else if(candidates.len < recommended_enemies)
		raider_num = candidates.len
	else
		raider_num = recommended_enemies

	//Grab candidates randomly until we have enough.
	while(raider_num > 0)
		var/datum/mind/new_raider = pick(candidates)
		raiders += new_raider
		candidates -= new_raider
		raider_num--

	for(var/datum/mind/raider in raiders)
		raider.assigned_role = "MODE"
		raider.special_role = "Vox Raider"
	return 1

/datum/game_mode/heist/pre_setup()
	return 1

/datum/game_mode/heist/post_setup()

	//Build a list of spawn points.
	var/list/turf/raider_spawn = list()

	for(var/obj/effect/landmark/start in landmarks_list)
		if(start.name == "voxstart")
			raider_spawn += get_turf(start)
			qdel(start)

	// generate objectives for the group.
	forge_vox_objectives()

	var/index = 1

	//Spawn the vox!
	for(var/datum/mind/raider in raiders)

		if(index > raider_spawn.len)
			index = 1

		raider.current.loc = raider_spawn[index]
		index++


		var/mob/living/carbon/human/vox = raider.current
		raider.name = vox.name
		vox.age = rand(12,20)
		vox.dna.mutantrace = "vox"
		vox.set_species("Vox")
		vox.generate_name()
		vox.languages = list() // Removing language from chargen.
		vox.flavor_text = ""
		vox.add_language("Vox-pidgin")
		vox.h_style = "Short Vox Quills"
		vox.f_style = "Shaved"
		for(var/datum/organ/external/limb in vox.organs)
			limb.status &= ~(ORGAN_DESTROYED | ORGAN_ROBOT)
		vox.equip_vox_raider()
		vox.regenerate_icons()

		raider.objectives = raid_objectives
		greet_vox(raider)

	spawn (rand(waittime_l, waittime_h))
		send_intercept()

/datum/game_mode/heist/proc/is_raider_crew_alive()
	var/raider_crew_count = raiders.len

	for(var/datum/mind/raider in raiders)
		if(raider && ishuman(raider.current) && raider.current.stat != DEAD)
			continue

		raider_crew_count--

	if(raider_crew_count <= 0)
		return FALSE

	return TRUE

/datum/game_mode/heist/proc/is_raider_crew_safe()
	if(!is_raider_crew_alive())
		return FALSE

	var/end_area = get_area_master(locate(/area/shuttle/vox/station))

	for(var/datum/mind/raider in raiders)
		if(get_area_master(raider.current) != end_area)
			return FALSE

	return TRUE

/datum/game_mode/heist/proc/forge_vox_objectives()


	//Commented out for testing.
	/* var/i = 1
	var/max_objectives = pick(2,2,2,3,3)
	var/list/objs = list()
	while(i<= max_objectives)
		var/list/goals = list("kidnap","loot","salvage")
		var/goal = pick(goals)
		var/datum/objective/heist/O

		if(goal == "kidnap")
			goals -= "kidnap"
			O = new /datum/objective/heist/kidnap()
		else if(goal == "loot")
			O = new /datum/objective/heist/loot()
		else
			O = new /datum/objective/heist/salvage()
		O.choose_target()
		objs += O

		i++

	//-All- vox raids have these two objectives. Failing them loses the game.
	objs += new /datum/objective/heist/inviolate_crew
	objs += new /datum/objective/heist/inviolate_death */

	if(prob(25))
		raid_objectives += new/datum/objective/heist/kidnap

	raid_objectives += new/datum/objective/steal/heist
	raid_objectives += new/datum/objective/steal/salvage
	raid_objectives += new/datum/objective/heist/inviolate_crew
	raid_objectives += new/datum/objective/heist/inviolate_death

	for(var/datum/objective/heist/O in raid_objectives)
		O.choose_target()

	for(var/datum/objective/steal/O in raid_objectives)
		O.find_target()

/datum/game_mode/heist/proc/greet_vox(const/datum/mind/raider)
	raider.current << {"\blue <B>You are a Vox Raider, fresh from the Shoal!</b>
The Vox are a race of cunning, sharp-eyed nomadic raiders and traders endemic to Tau Ceti and much of the unexplored galaxy. You and the crew have come to the Exodus for plunder, trade or both.
Vox are cowardly and will flee from larger groups, but corner one or find them en masse and they are vicious.
Use :V to voxtalk, :H to talk on your encrypted channel, and <b>don't forget to turn on your nitrogen internals!"}

	var/obj_count = 0

	for(var/datum/objective/objective in raider.objectives)
		raider.current << "<B>Objective #[obj_count++]</B>: [objective.explanation_text]"

/datum/game_mode/heist/declare_completion()
	// no objectives, go straight to the feedback
	if(isnull(raid_objectives) || raid_objectives.len <= 0)
		return ..()

	var/win_type = "Major"
	var/win_group = "Crew"
	var/win_msg = ""

	var/success = raid_objectives.len

	//Decrease success for failed objectives.
	for(var/datum/objective/O in raid_objectives)
		if(!(O.check_completion()))
			success--

	//Set result by objectives.
	if(success == raid_objectives.len)
		win_type = "Major"
		win_group = "Vox"
	else if(success > 2)
		win_type = "Minor"
		win_group = "Vox"
	else
		win_type = "Minor"
		win_group = "Crew"

	// now we modify that result by the state of the vox crew
	if(!is_raider_crew_alive())
		win_type = "Major"
		win_group = "Crew"
		win_msg += "<B>The Vox Raiders have been wiped out!</B>"
	else if(!is_raider_crew_safe())
		if(win_group == "Crew" && win_type == "Minor")
			win_type = "Major"

		win_group = "Crew"
		win_msg += "<B>The Vox Raiders have left someone behind!</B>"
	else
		if(win_group == "Vox")
			if(win_type == "Minor")
				win_type = "Major"

			win_msg += "<B>The Vox Raiders escaped the station!</B>"
		else
			win_msg += "<B>The Vox Raiders were repelled!</B>"

	world << "\red <FONT size = 3><B>[win_type] [win_group] victory!</B></FONT><br>[win_msg]"

	feedback_set_details("round_end_result","heist - [win_type] [win_group]")

	var/count = 0

	for(var/datum/objective/objective in raid_objectives)
		count++

		if(objective.check_completion())
			world << "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
			feedback_add_details("traitor_objective","[objective.type]|SUCCESS")
		else
			world << "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
			feedback_add_details("traitor_objective","[objective.type]|FAIL")

	var/text = "<FONT size = 2><B>The vox raiders were:</B></FONT>"
	var/end_area = get_area_master(locate(/area/shuttle/vox/station))

	for(var/datum/mind/vox in raiders)
		text += "<br>[vox.key] was [vox.name] ("

		if(vox.current)
			if(get_area_master(vox.current) != end_area) // areaMaster var can be used on this if move_contents_to proc refactored to use Move()
				text += "left behind, "

			if(vox.current.stat != DEAD)
				text += "survived"
			else
				text += "died"

			if(vox.current.real_name != vox.name)
				text += " as [vox.current.real_name]"
		else
			text += "body destroyed"

		text += ")"

	world << text
	..()
	return 1

/datum/game_mode/heist/check_finished()
	if(!is_raider_crew_alive() || vox_shuttle_location == "start")
		return 1

	return ..()

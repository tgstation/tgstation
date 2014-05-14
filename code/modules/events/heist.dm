/*
VOX HEIST ROUNDTYPE
*/

#define MAX_VOX_KILLS 10 //Number of kills during the round before the Inviolate is broken.
						 //Would be nice to use vox-specific kills but is currently not feasible.

var/global/vox_kills = 0 //Used to check the Inviolate.
var/global/vox_sent=0

var/global/list/datum/mind/raiders = list()  //Antags.

/datum/event/heist
	var/list/raid_objectives = list()     //Raid objectives.
	var/list/obj/cortical_stacks = list() //Stacks for 'leave nobody behind' objective.

	announceWhen	= 600
	oneShot			= 1

	var/required_candidates = 4
	var/max_candidates = 6
	var/successSpawn = 0	//So we don't make a command report if nothing gets spawned.

/datum/event/heist/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)
	sent_aliens_to_station = 1

/datum/event/heist/announce()
	return


/datum/event/heist/start()

	if(!..())
		return 0

	var/list/candidates = get_candidates(BE_RAIDER)
	var/raider_num = 0

	//Check that we have enough vox.
	if(candidates.len < required_candidates)
		return 0
	else if(candidates.len < max_candidates)
		raider_num = candidates.len
	else
		raider_num = max_candidates

	//Grab candidates randomly until we have enough.
	while(raider_num > 0)
		var/datum/mind/new_raider = pick(candidates)
		raiders += new_raider
		candidates -= new_raider
		raider_num--

	for(var/datum/mind/raider in raiders)
		raider.assigned_role = "MODE"
		raider.special_role = "Vox Raider"

	//Build a list of spawn points.
	var/list/turf/raider_spawn = list()

	for(var/obj/effect/landmark/L in landmarks_list)
		if(L.name == "voxstart")
			raider_spawn += get_turf(L)
			del(L)
			continue

	//Generate objectives for the group.
	raid_objectives = forge_vox_objectives()

	var/index = 1

	//Spawn the vox!
	for(var/datum/mind/raider in raiders)

		if(index > raider_spawn.len)
			index = 1

		raider.current.loc = raider_spawn[index]
		index++

		var/mob/living/carbon/human/vox = raider.current
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

	vox_sent=1

/datum/event/heist/proc/is_raider_crew_safe()

	if(cortical_stacks.len == 0)
		return 0

	for(var/obj/stack in cortical_stacks)
		if (get_area(stack) != locate(/area/shuttle/vox/station))
			return 0
	return 1

/datum/event/heist/proc/is_raider_crew_alive()

	for(var/datum/mind/raider in raiders)
		if(raider.current)
			if(istype(raider.current,/mob/living/carbon/human) && raider.current.stat != 2)
				return 1
	return 0

/datum/event/heist/proc/forge_vox_objectives()


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

	if(prob(25)) // This is an asspain.
		raid_objectives += new /datum/objective/heist/kidnap
	raid_objectives += new /datum/objective/heist/loot
	raid_objectives += new /datum/objective/heist/salvage
	raid_objectives += new /datum/objective/heist/inviolate_crew
	raid_objectives += new /datum/objective/heist/inviolate_death

	for(var/datum/objective/heist/O in raid_objectives)
		O.choose_target()

	return raid_objectives

/datum/event/heist/proc/greet_vox(var/datum/mind/raider)
	raider.current << {"\blue <B>You are a Vox Raider, fresh from the Shoal!</b>
The Vox are a race of cunning, sharp-eyed nomadic raiders and traders endemic to Tau Ceti and much of the unexplored galaxy. You and the crew have come to the [station_name()] for plunder, trade or both.
Vox are cowardly and will flee from larger groups, but corner one or find them en masse and they are vicious.
Use :V to voxtalk, :H to talk on your encrypted channel, and <b>don't forget to turn on your nitrogen internals!</b>"}
	var/obj_count = 1
	for(var/datum/objective/objective in raider.objectives)
		raider.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++


/datum/event/heist/proc/declare_completion()

	//No objectives, go straight to the feedback.
	if(!(raid_objectives.len)) return ..()

	var/win_type = "Major"
	var/win_group = "Crew"
	var/win_msg = ""

	var/success = raid_objectives.len

	//Decrease success for failed objectives.
	for(var/datum/objective/O in raid_objectives)
		if(!(O.check_completion())) success--

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

	//Now we modify that result by the state of the vox crew.
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

	world << {"\red <FONT size = 3><B>[win_type] [win_group] victory!</B></FONT>
		[win_msg]"}
	feedback_set_details("round_end_result","heist - [win_type] [win_group]")

	var/count = 1
	for(var/datum/objective/objective in raid_objectives)
		if(objective.check_completion())
			world << "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
			feedback_add_details("traitor_objective","[objective.type]|SUCCESS")
		else
			world << "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
			feedback_add_details("traitor_objective","[objective.type]|FAIL")
		count++

	..()

/datum/event/heist/proc/check_finished()
	if (!(is_raider_crew_alive()) || (vox_shuttle_location && (vox_shuttle_location == "start")))
		return 1
	return ..()
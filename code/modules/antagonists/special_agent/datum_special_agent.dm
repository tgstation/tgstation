/*!
A new antagonist.

This antagonist works directly in counter to the other antagonists present on the map, while also attempting to complete covert and ***NON LETHAL*** Objectives. Please keep that in mind when you add objectives to tis antag.

*/
/datum/antagonist/special_agent
	name = "Special Agent"
	roundend_category = "agents"
	antagpanel_category = "Special Agent"
	job_rank = ROLE_SPECIAL_AGENT
	antag_moodlet = /datum/mood_event/focused
	/var/employer = "The Syndicate"
	/var/give_objectives = TRUE
	/var/give_equipment = TRUE

/datum/antagonist/special_agent/on_gain()
	owner.special_role = special_role
	if(give_objective)
		forge_agent_objectives()
	if(give_equpment)
		give_equipment()

/datum/antagonist/special_agent/proc/give_equipment()
	/var/mob/living/carbon/human/H = owner.current
	/// Adds Equipment to the mob
	H.equip_to_slot_or_del(/obj/item/card/id/advemag,SLOT_WEAR_ID)
	H.equip_to_slot_or_del(/obj/item/inducer/netgun,SLOT_IN_BACKPACK)
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/antagonist/special_agent/on_removal()
	. = ..()
	if(!silent && owner.current)
		to_chat(owner.current,"<span class='userdanger'> You are no longer the [special_role]! </span>"
	owner.special_role = null

/datum/antagonist/special_agent/greet()
	to_chat(owner.current, "<span class='alertsyndie'>You are the [owner.special_role].</span>\n\
	One or more syndicate operatives have been compromised in your sector, take your equipment and secure them for capture. DO NOT inform them of your objective.")
	owner.announce_objectives()

///Gives objectives
/datum/antagonist/special_agent/proc/add_objective(datum/objective/O)
	objectives += O

///Removes Objectives
/datum/antagonist/special_agent/proc/remove_objective(datum/objective/O)
	objectives -= O

///gives agent its objectives
/datum/antagonist/special_agent/proc/forge_agent_objectives()
	/var/is_hijacker = FALSE
	/var/saoa = CONFIG_GET(number/special_agent_objective_amount)
	var/datum/objective/agent_capture = new
	
	agent_capture.owner = owner
	agent_capture.find_target_by_role("traitor")
	add_objective(agent_capture)
	
	for(var/i = 1, i < saoa, i++)
		forge_single_objective()
	
	var/datum/objective/escape/escape_objective = new
	escape_objective.owner = owner
	add_objective(escape_objective)
	return

/datum/antagonist/special_agent/proc/forge_single_objective
	.=1
	if(prob(33) && !(locate(/datum/objective/download) in objectives) && !(owner.assigned_role in list("Research Director", "Scientist", "Roboticist")))
		var/datum/objective/download/download_objective = new
		download_objective.owner = owner
		download_objective.gen_amount_goal()
		add_objective(download_objective)
		return
	else if(prob(33))
		var/datum/objective/steal/steal_objective = new
		steal_objective.owner = owner
		steal_objective.find_target()
		add_objective(steal_objective)
		return
	else
		var/datum/objective/agent_capture = new
		agent_capture.owner = owner
		agent_capture.find_target_by_role("traitor")
		add_objective(agent_capture)
		return

/datum/antagonist/special_agent/roundend_report()
	/var/list/results = list()
	/var/agentwin = TRUE

	results += printplayer(owner)

	var/objectives_text = ""
	if(objectives.len)//If the traitor had no objectives, don't need to process this.
		var/count = 1
		for(var/datum/objective/objective in objectives)
			if(objective.check_completion())
				objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <span class='greentext'>Success!</span>"
			else
				objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
				traitorwin = FALSE
			count++
	if(traitorwin)
		results += "<span class='greentext'>The [special_role_text] was successful!</span>"
	else
		results += "<span class='redtext'>The [special_role_text] has failed!</span>"
		SEND_SOUND(owner.current, 'sound/ambience/ambifailure.ogg')

	return results.Join("<br>")

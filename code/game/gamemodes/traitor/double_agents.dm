/datum/game_mode/traitor/internal_affairs
	name = "Internal Affairs"
	config_tag = "internal_affairs"
	employer = "Internal Affairs"
	required_players = 1
	required_enemies = 1
	recommended_enemies = 8
	reroll_friendly = 0
	traitor_name = "Nanotrasen Internal Affairs Agent"

	traitors_possible = 10 //hard limit on traitors if scaling is turned off
	num_modifier = 4 // Four additional traitors

	announce_text = "There are Nanotrasen Internal Affairs Agents trying to kill each other!\n\
	<span class='danger'>IAA</span>: Eliminate your targets and protect yourself!\n\
	<span class='notice'>Crew</span>: Stop the IAA agents before they can cause too much mayhem."

	var/list/target_list = list()
	var/list/late_joining_list = list()

/datum/game_mode/traitor/internal_affairs/post_setup()
	var/i = 0
	for(var/datum/mind/traitor in traitors)
		i++
		if(i + 1 > traitors.len)
			i = 0
		target_list[traitor] = traitors[i + 1]
		if(traitor.current)
			traitor.current.disabilities|=NOCLONE //makes things a little less messy
	..()



/datum/objective/assassinate/internal/proc/give_pinpointer()
	if(owner && owner.current)
		if(ishuman(owner.current))
			var/mob/living/carbon/human/H = owner.current
			var/list/slots = list ("backpack" = slot_in_backpack)
			var/obj/item/weapon/pinpointer/internal/pinpointer = new
			pinpointer.owner=owner
			H.equip_in_one_of_slots(pinpointer, slots)

/datum/game_mode/traitor/internal_affairs/forge_traitor_objectives(datum/mind/traitor)

	if(target_list.len && target_list[traitor]) // Is a double agent

		// Assassinate
		var/datum/mind/target_mind = target_list[traitor]
		if(issilicon(target_mind.current))
			var/datum/objective/destroy/destroy_objective = new
			destroy_objective.owner = traitor
			destroy_objective.target = target_mind
			destroy_objective.update_explanation_text()
			traitor.objectives += destroy_objective
		else
			var/datum/objective/assassinate/internal/kill_objective = new
			kill_objective.owner = traitor
			kill_objective.target = target_mind
			kill_objective.update_explanation_text()
			traitor.objectives += kill_objective
			if(!issilicon(traitor.current))
				kill_objective.give_pinpointer()

		// Escape
		if(issilicon(traitor.current))
			var/datum/objective/survive/survive_objective = new
			survive_objective.owner = traitor
			traitor.objectives += survive_objective
		else
			var/datum/objective/escape/escape_objective = new
			escape_objective.owner = traitor
			traitor.objectives += escape_objective

	else
		..() // Give them standard objectives.
	return

/datum/game_mode/traitor/internal_affairs/add_latejoin_traitor(datum/mind/character)

	check_potential_agents()

	// As soon as we get 3 or 4 extra latejoin traitors, make them traitors and kill each other.
	if(late_joining_list.len >= rand(3, 4))
		// True randomness
		shuffle_inplace(late_joining_list)
		// Reset the target_list, it'll be used again in force_traitor_objectives
		target_list = list()

		// Basically setting the target_list for who is killing who
		var/i = 0
		for(var/datum/mind/traitor in late_joining_list)
			i++
			if(i + 1 > late_joining_list.len)
				i = 0
			target_list[traitor] = late_joining_list[i + 1]
			traitor.special_role = traitor_name

		// Now, give them their targets
		for(var/datum/mind/traitor in target_list)
			..(traitor)

		late_joining_list = list()
	else
		late_joining_list += character
	return

/datum/game_mode/traitor/internal_affairs/proc/check_potential_agents()

	for(var/M in late_joining_list)
		if(istype(M, /datum/mind))
			var/datum/mind/agent_mind = M
			if(ishuman(agent_mind.current))
				var/mob/living/carbon/human/H = agent_mind.current
				if(H.stat != DEAD)
					if(H.client)
						continue // It all checks out.

		// If any check fails, remove them from our list
		late_joining_list -= M


/datum/game_mode/traitor/internal_affairs/greet_traitor(datum/mind/traitor)
	var/crime = pick("distribution of contraband" , "unauthorized erotic action on duty", "embezzlement", "piloting under the influence", "dereliction of duty", "syndicate collaboration", "mutiny", "multiple homicides", "corporate espionage", "recieving bribes", "malpractice", "worship of prohbited life forms", "possession of profane texts", "murder", "arson", "insulting their manager", "grand theft", "conspiracy", "attempting to unionize", "vandalism", "gross incompetence")
	to_chat(traitor.current, "<B><font size=3 color=red>You are the [traitor_name].</font></B>")
	to_chat(traitor.current, "<B><font size=3 color=red>Your target is suspected of [crime], and you have been tasked with eliminating them by any means necessary to avoid a costly and embarrassing public trial.</font></B>")
	to_chat(traitor.current, "<B><font size=5 color=red>While you have a license to kill, unneeded property damage or loss of employee life will lead to your contract being terminated.</font></B>")
	to_chat(traitor.current, "<B><font size=3 color=red>For the sake of plausible deniability, you have been equipped with an array of captured Syndicate weaponry available via uplink.</font></B>")
	to_chat(traitor.current, "<B><font size=3 color=red>Finally, watch your back. Your target has friends in high places, and intel suggests someone may have taken out a contract of their own to protect them.</font></B>")
	traitor.announce_objectives()



/datum/game_mode/traitor/internal_affairs/give_codewords(mob/living/traitor_mob)
	return

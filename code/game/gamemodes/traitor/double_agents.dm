/datum/game_mode/traitor/internal_affairs
	name = "Internal Affairs"
	config_tag = "internal_affairs"
	employer = "Internal Affairs"
	required_players = 25
	required_enemies = 5
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
		target_list[traitor] = traitors[i+1]	
	..()

/datum/objective/assassinate/internal/proc/give_pinpointer()
	if(owner && owner.current)
		if(ishuman(owner.current))
			var/mob/living/carbon/human/H = owner.current
			var/list/slots = list ("backpack" = slot_in_backpack)
			var/obj/item/weapon/pinpointer/internal/pinpointer = new
			pinpointer.owner=owner
			H.equip_in_one_of_slots(pinpointer, slots)

/proc/is_internal_objective(datum/objective/O)
	return (istype(O, /datum/objective/assassinate/internal)||istype(O, /datum/objective/destroy/internal))


/proc/steal_targets(datum/mind/owner,datum/mind/victim)
	if(!owner.current||owner.current.stat==DEAD) //Should already be guaranteed if this is only called from steal_targets_timer_func, but better to be safe code than sorry code 
		return
	var/traitored = 0
	var/failed_traitored = 0
	for(var/objective_ in victim.objectives)
		if(istype(objective_, /datum/objective/assassinate/internal))
			var/datum/objective/assassinate/internal/objective = objective_
			if(objective.target==owner)
				to_chat(owner.current,"<B><font size=3 color=red> Now that all the loyalist agents have been purged, your syndicate sleeper training activates - YOU ARE THE TRAITOR! You now have no limits on collateral damage.</font></B>")
				traitored = 1
			else
				var/datum/objective/assassinate/internal/new_objective = new
				new_objective.owner = owner
				new_objective.target = objective.target
				new_objective.update_explanation_text()
				owner.objectives += new_objective
				var/status_text = objective.check_completion() ? "neutralised" : "active"
				to_chat(owner.current, "<B><font size=3 color=red> New target added to database: [objective.target.name] ([status_text]) </font></B>")
		else if(istype(objective_, /datum/objective/destroy/internal))
			var/datum/objective/destroy/internal/objective = objective_
			var/datum/objective/destroy/internal/new_objective = new
			if(objective.target==owner)
				traitored = 1
			else
				new_objective.owner = owner
				new_objective.target = objective.target
				new_objective.update_explanation_text()
				owner.objectives += new_objective
				var/status_text = objective.check_completion() ? "neutralised" : "active"
				to_chat(owner.current, "<B><font size=3 color=red> New target added to database: [objective.target.name] ([status_text]) </font></B>")
	if(traitored)
		for(var/objective_ in victim.objectives)
			if(!is_internal_objective(objective_))
				continue
			var/datum/objective/assassinate/internal/objective = objective_
			if(!objective.check_completion())
				failed_traitored = 1
				break
			objective.traitored = 1
		to_chat(owner.current,"<B><font size=3 color=red> Now that all the loyalist agents have been purged, your syndicate sleeper training activates - YOU ARE THE TRAITOR! You now have no limits on collateral damage.</font></B>")
	if(failed_traitored)
		for(var/objective_ in victim.objectives)
			if(!is_internal_objective(objective_))
				continue
			var/datum/objective/assassinate/internal/objective = objective_
			objective.traitored = 0
		
			
	
/proc/steal_targets_timer_func(datum/mind/owner)
	if(owner&&owner.current&&owner.current.stat!=DEAD)
		var/undo_traitored = 0
		for(var/objective_ in owner.objectives)
			if(!is_internal_objective(objective_))
				continue
			var/datum/objective/assassinate/internal/objective = objective_
			if(!objective.target)
				continue
			if(objective.check_completion())
				if(objective.stolen)
					continue
				else
					steal_targets(owner,objective.target)
					objective.stolen=1
			else
				if(objective.stolen)
					var/fail_msg = "<B><font size=3 color=red>Your sensors tell you that [objective.target.current.real_name], one of the targets you were meant to have killed, pulled one over on you, and is still alive - do the job properly this time! </font></B>"
					if(objective.traitored)
						fail_msg += "<B><font size=3 color=red>As a safety measure, the syndicate have wiped your memories and reinstated your belief that you are an internal affairs agent. </font><B><font size=5 color=red>While you have a license to kill, unneeded property damage or loss of employee life will lead to your contract being terminated.</font></B>"
						undo_traitored = 1
					to_chat(owner.current, fail_msg)
					objective.stolen=0
		if(undo_traitored)
			for(var/objective_ in owner.objectives)
				if(!is_internal_objective(objective_))
					continue
				var/datum/objective/assassinate/internal/objective = objective_
				objective.traitored = 0
	add_steal_targets_timer(owner)

/proc/add_steal_targets_timer(datum/mind/owner)
	var/datum/callback/C = new(null, /proc/steal_targets_timer_func, owner)
	addtimer(C, 30)

/datum/game_mode/traitor/internal_affairs/forge_traitor_objectives(datum/mind/traitor)

	if(target_list.len && target_list[traitor]) // Is a double agent

		// Assassinate
		var/datum/mind/target_mind = target_list[traitor]
		if(issilicon(target_mind.current))
			var/datum/objective/destroy/internal/destroy_objective = new
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
		add_steal_targets_timer(traitor)

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

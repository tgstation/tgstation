#define PINPOINTER_MINIMUM_RANGE 15 
#define PINPOINTER_EXTRA_RANDOM_RANGE 10
#define PINPOINTER_PING_TIME 40
#define PROB_ACTUAL_TRAITOR 20
#define TRAITOR_AGENT_ROLE "Syndicate External Affairs Agent"

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


/datum/status_effect/agent_pinpointer
	id = "agent_pinpointer"
	duration = -1
	tick_interval = PINPOINTER_PING_TIME
	alert_type = /obj/screen/alert/status_effect/agent_pinpointer
	var/minimum_range = PINPOINTER_MINIMUM_RANGE
	var/mob/scan_target = null

/obj/screen/alert/status_effect/agent_pinpointer
	name = "Internal Affairs Integrated Pinpointer"
	desc = "Even stealthier than a normal implant."
	icon = 'icons/obj/device.dmi'
	icon_state = "pinon"

/datum/status_effect/agent_pinpointer/proc/point_to_target() //If we found what we're looking for, show the distance and direction
	if(!scan_target)
		linked_alert.icon_state = "pinonnull"
		return
	var/turf/here = get_turf(owner)
	var/turf/there = get_turf(scan_target)
	if(here.z != there.z)
		linked_alert.icon_state = "pinonnull"
		return
	if(get_dist_euclidian(here,there)<=minimum_range + rand(0, PINPOINTER_EXTRA_RANDOM_RANGE))
		linked_alert.icon_state = "pinondirect"
	else
		linked_alert.setDir(get_dir(here, there))
		switch(get_dist(here, there))
			if(1 to 8)
				linked_alert.icon_state = "pinonclose"
			if(9 to 16)
				linked_alert.icon_state = "pinonmedium"
			if(16 to INFINITY)
				linked_alert.icon_state = "pinonfar"
		

/datum/status_effect/agent_pinpointer/proc/scan_for_target()
	scan_target = null
	if(owner)
		if(owner.mind)
			if(owner.mind.objectives)
				for(var/datum/objective/objective_ in owner.mind.objectives)
					if(!is_internal_objective(objective_))
						continue
					var/datum/objective/assassinate/internal/objective = objective_
					var/mob/current = objective.target.current
					if(current&&current.stat!=DEAD)
						scan_target = current
					break
					

/datum/status_effect/agent_pinpointer/tick()
	if(!owner)
		qdel(src)
		return
	scan_for_target()
	point_to_target()

/proc/give_pinpointer(datum/mind/owner)
	if(owner && owner.current)
		owner.current.apply_status_effect(/datum/status_effect/agent_pinpointer)


/datum/internal_agent_state
	var/traitored = FALSE
	var/datum/mind/owner = null
	var/list/datum/mind/targets_stolen = list()

/proc/is_internal_objective(datum/objective/O)
	return (istype(O, /datum/objective/assassinate/internal)||istype(O, /datum/objective/destroy/internal))

/proc/replace_escape_objective(datum/mind/owner)
	if(!owner||!owner.objectives)
		return
	for (var/objective_ in owner.objectives)
		if(!(istype(objective_, /datum/objective/escape)||istype(objective_,/datum/objective/survive)))
			continue
		owner.objectives -= objective_
	var/datum/objective/martyr/martyr_objective = new
	martyr_objective.owner = owner
	owner.objectives += martyr_objective

/proc/reinstate_escape_objective(datum/mind/owner)
	if(!owner||!owner.objectives)
		return
	for (var/objective_ in owner.objectives)
		if(!istype(objective_, /datum/objective/martyr))
			continue
		owner.objectives -= objective_
	if(issilicon(owner))	
		var/datum/objective/survive/survive_objective = new
		survive_objective.owner = owner
		owner.objectives += survive_objective
	else
		var/datum/objective/escape/escape_objective = new
		escape_objective.owner = owner
		owner.objectives += escape_objective

/datum/internal_agent_state/proc/steal_targets(datum/mind/victim)
	if(!owner.current||owner.current.stat==DEAD) //Should already be guaranteed if this is only called from steal_targets_timer_func, but better to be safe code than sorry code 
		return
	var/already_traitored = traitored
	to_chat(owner.current, "<span class='userdanger'> Target eliminated: [victim.name]</span>")
	for(var/objective_ in victim.objectives)
		if(istype(objective_, /datum/objective/assassinate/internal))
			var/datum/objective/assassinate/internal/objective = objective_
			if(objective.target==owner)
				traitored = TRUE
			else if(targets_stolen.Find(objective.target) == 0)
				var/datum/objective/assassinate/internal/new_objective = new
				new_objective.owner = owner
				new_objective.target = objective.target
				new_objective.update_explanation_text()
				owner.objectives += new_objective
				targets_stolen += objective.target
				var/status_text = objective.check_completion() ? "neutralised" : "active"
				to_chat(owner.current, "<span class='userdanger'> New target added to database: [objective.target.name] ([status_text]) </span>")
		else if(istype(objective_, /datum/objective/destroy/internal))
			var/datum/objective/destroy/internal/objective = objective_
			var/datum/objective/destroy/internal/new_objective = new
			if(objective.target==owner)
				traitored = TRUE
			else if(targets_stolen.Find(objective.target) == 0)
				new_objective.owner = owner
				new_objective.target = objective.target
				new_objective.update_explanation_text()
				owner.objectives += new_objective
				targets_stolen += objective.target
				var/status_text = objective.check_completion() ? "neutralised" : "active"
				to_chat(owner.current, "<span class='userdanger'> New target added to database: [objective.target.name] ([status_text]) </span>")
	if(traitored&&!already_traitored)
		for(var/objective_ in owner.objectives)
			if(!is_internal_objective(objective_))
				continue
			var/datum/objective/assassinate/internal/objective = objective_
			if(!objective.check_completion())
				traitored = FALSE
				return
		if(owner.special_role == TRAITOR_AGENT_ROLE)
			to_chat(owner.current,"<span class='userdanger'> All the loyalist agents are dead, and no more is required of you. Die a glorious death, agent. </span>")
		else
			to_chat(owner.current,"<span class='userdanger'> All the other agents are dead, and you're the last loose end. Stage a Syndicate terrorist attack to cover up for today's events. You no longer have any limits on collateral damage.</span>")
		replace_escape_objective(owner)
		
			
	
/datum/internal_agent_state/proc/steal_targets_timer_func()
	if(owner&&owner.current&&owner.current.stat!=DEAD)
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
					steal_targets(objective.target)
					objective.stolen = TRUE
			else
				if(objective.stolen)
					var/fail_msg = "<span class='userdanger'>Your sensors tell you that [objective.target.current.real_name], one of the targets you were meant to have killed, pulled one over on you, and is still alive - do the job properly this time! </span>"
					if(traitored)
						if(owner.special_role == TRAITOR_AGENT_ROLE)
							fail_msg += "<span class='userdanger'> You no longer have permission to die. </span>"
						else
							fail_msg += "<span class='userdanger'> The truth could still slip out!</font><B><font size=5 color=red> Cease any terrorist actions as soon as possible, unneeded property damage or loss of employee life will lead to your contract being terminated.</span>"
						reinstate_escape_objective(owner)
						traitored = FALSE
					to_chat(owner.current, fail_msg)
					objective.stolen = FALSE
	add_steal_targets_timer(owner)

/datum/internal_agent_state/proc/add_steal_targets_timer()
	var/datum/callback/C = new(src, .steal_targets_timer_func)
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

		// Escape
		if(issilicon(traitor.current))
			var/datum/objective/survive/survive_objective = new
			survive_objective.owner = traitor
			traitor.objectives += survive_objective
		else
			var/datum/objective/escape/escape_objective = new
			escape_objective.owner = traitor
			traitor.objectives += escape_objective
		var/datum/internal_agent_state/state = new
		state.owner=traitor
		state.add_steal_targets_timer()
		if(!issilicon(traitor.current))
			give_pinpointer(traitor)
		//Optional traitor objective
		if(prob(PROB_ACTUAL_TRAITOR))
			traitor.special_role = TRAITOR_AGENT_ROLE
			forge_single_objective(traitor)	

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
	if(traitor.special_role == TRAITOR_AGENT_ROLE)
		to_chat(traitor.current, "<span class='userdanger'>You are the [TRAITOR_AGENT_ROLE].</span>")
		to_chat(traitor.current, "<span class='userdanger'>Your target has been framed for [crime], and you have been tasked with eliminating them to prevent them defending themselves in court.</span>")
		to_chat(traitor.current, "<B><font size=5 color=red>Any damage you cause will be a further embarrassment to Nanotrasen, so you have no limits on collateral damage.</font></B>")
		to_chat(traitor.current, "<span class='userdanger'> You have been provided with a standard uplink to accomplish your task. </span>")
		to_chat(traitor.current, "<span class='userdanger'>Finally, watch your back. Your target has friends in high places, and intel suggests someone may have taken out a contract of their own to protect them.</span>")
	else
		to_chat(traitor.current, "<span class='userdanger'>You are the [traitor_name].</span>")
		to_chat(traitor.current, "<span class='userdanger'>Your target is suspected of [crime], and you have been tasked with eliminating them by any means necessary to avoid a costly and embarrassing public trial.</span>")
		to_chat(traitor.current, "<B><font size=5 color=red>While you have a license to kill, unneeded property damage or loss of employee life will lead to your contract being terminated.</font></B>")
		to_chat(traitor.current, "<span class='userdanger'>For the sake of plausible deniability, you have been equipped with an array of captured Syndicate weaponry available via uplink.</span>")
		to_chat(traitor.current, "<span class='userdanger'>Finally, watch your back. Your target has friends in high places, and intel suggests someone may have taken out a contract of their own to protect them.</span>")
	traitor.announce_objectives()



/datum/game_mode/traitor/internal_affairs/give_codewords(mob/living/traitor_mob)
	return

#undef PROB_ACTUAL_TRAITOR
#undef PINPOINTER_EXTRA_RANDOM_RANGE
#undef PINPOINTER_MINIMUM_RANGE
#undef PINPOINTER_PING_TIME


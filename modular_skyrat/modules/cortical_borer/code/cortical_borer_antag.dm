/proc/printborer(datum/mind/ply)
	var/text = list()
	var/mob/living/simple_animal/cortical_borer/player_borer = ply.current
	text = span_bold(ply.name)
	if(player_borer)
		text = span_bold("[player_borer.name]")
		if(ply.current.stat != DEAD)
			text += span_greentext(" survived")
		else
			text += span_redtext(" died")
		text += span_bold(" The borer produced [player_borer.children_produced] borers.")
	else
		text += span_redtext(" had their body destroy.")
	return text

/proc/printborerlist(list/players,fleecheck)
	var/list/parts = list()

	parts += "<ul class='playerlist'>"
	for(var/datum/mind/M in players)
		parts += "<li>[printborer(M)]</li>"
	parts += "</ul>"
	return parts.Join()

/datum/antagonist/cortical_borer
	name = "Cortical Borer"
	job_rank = ROLE_ALIEN
	show_in_antagpanel = TRUE
	roundend_category = "cortical borers"
	antagpanel_category = "Cortical borers"
	prevent_roundtype_conversion = FALSE
	show_to_ghosts = TRUE
	var/datum/team/cortical_borers/borers

/datum/antagonist/cortical_borer/get_team()
	return borers

/datum/antagonist/cortical_borer/create_team(datum/team/cortical_borers/new_team)
	if(!new_team)
		for(var/datum/antagonist/cortical_borer/P in GLOB.antagonists)
			if(!P.owner)
				stack_trace("Antagonist datum without owner in GLOB.antagonists: [P]")
				continue
			if(P.borers)
				borers = P.borers
				return
		if(!new_team)
			borers = new /datum/team/cortical_borers
			return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	borers = new_team

/datum/team/cortical_borers
	name = "Cortical borers"

/datum/team/cortical_borers/roundend_report()
	var/list/parts = list()
	parts += "<span class='header'>The [name] were:</span>"
	parts += printborerlist(members)
	var/survival = FALSE
	for(var/mob/living/simple_animal/cortical_borer/check_borer in GLOB.cortical_borers)
		if(check_borer.stat == DEAD)
			continue
		survival = TRUE
	if(survival)
		parts += span_greentext("Borers were able to survive the shift!")
	else
		parts += span_redtext("Borers were unable to survive the shift!")
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/round_event_control/cortical_borer
	name = "Cortical Borer Infestation"
	typepath = /datum/round_event/ghost_role/cortical_borer
	weight = 10
	min_players = 999
	max_occurrences = 1 //should only ever happen once
	dynamic_should_hijack = TRUE

/datum/round_event/ghost_role/cortical_borer
	announceWhen = 400

/datum/round_event/ghost_role/cortical_borer/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)

/datum/round_event/ghost_role/cortical_borer/announce(fake)
	priority_announce("Unidentified lifesigns detected coming aboard [station_name()]. Secure any exterior access, including ducting and ventilation.", "Lifesign Alert", ANNOUNCER_ALIENS)

/datum/round_event/ghost_role/cortical_borer/start()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in GLOB.machines)
		if(QDELETED(temp_vent))
			continue
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			var/datum/pipeline/temp_vent_parent = temp_vent.parents[1]
			if(!temp_vent_parent)
				continue // No parent vent
			// Stops Cortical Borers getting stuck in small networks.
			// See: Security, Virology
			if(temp_vent_parent.other_atmos_machines.len > 20)
				vents += temp_vent
	if(!vents.len)
		return MAP_ERROR
	var/list/mob/dead/observer/candidates = poll_ghost_candidates("Do you want to spawn as a cortical borer?", ROLE_PAI, FALSE, 10 SECONDS, POLL_IGNORE_CORTICAL_BORER)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS
	var/living_number = max(GLOB.player_list.len / 30, 1)
	var/choosing_number = min(candidates.len, living_number)
	for(var/repeating_code in 1 to choosing_number)
		var/mob/dead/observer/new_borer = pick(candidates)
		candidates -= new_borer
		var/turf/vent_turf = get_turf(pick(vents))
		var/mob/living/simple_animal/cortical_borer/spawned_cb = new /mob/living/simple_animal/cortical_borer(vent_turf)
		spawned_cb.ckey = new_borer.ckey
		spawned_cb.mind.add_antag_datum(/datum/antagonist/cortical_borer)
		to_chat(spawned_cb, span_warning("You are a cortical borer! You can fear someone to make them stop moving, but make sure to inhabit them! You only grow/heal/talk when inside a host!"))
	for(var/mob/dead_mob in GLOB.dead_mob_list)
		to_chat(dead_mob, span_notice("The cortical borers have been selected, you are able to orbit them! Remember, they can reproduce!"))

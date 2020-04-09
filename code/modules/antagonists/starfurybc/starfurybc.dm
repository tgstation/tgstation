/datum/antagonist/starfuryop
	name = "Syndicate Operative"
	roundend_category = "starfury battlecruiser operatives"
	antagpanel_category = "Starfury Operative"
	job_rank = ROLE_TRAITOR
	antag_hud_type = ANTAG_HUD_OPS
	antag_hud_name = "synd"
	antag_moodlet = /datum/mood_event/focused
	var/datum/team/starfuryop/sbccrew
	can_hijack = HIJACK_HIJACKER

/datum/antagonist/starfuryop/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	add_antag_hud(antag_hud_type, antag_hud_name, M)

/datum/antagonist/starfuryop/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	remove_antag_hud(antag_hud_type, M)

/datum/antagonist/starfuryop/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ops.ogg',100,0)
	to_chat(owner, "<span class='boldannounce'>You are a Syndicate Operative onboard Starfury BattleCruiser!</span>")
	to_chat(owner, "<B>Nanotrasen tried to hide, but we discovered their location and now it's time to teach them a lesson.</B>")
	owner.announce_objectives()

/datum/antagonist/starfuryop/get_team()
	return sbccrew

/datum/antagonist/starfuryop/create_team(datum/team/starfuryop/new_team)
	if(!new_team)
		for(var/datum/antagonist/starfuryop/P in GLOB.antagonists)
			if(!P.owner)
				continue
			if(P.sbccrew)
				sbccrew = P.sbccrew
				return
		if(!new_team)
			sbccrew = new /datum/team/starfuryop
			//sbccrew.forge_objectives()
			return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	sbccrew = new_team

/datum/antagonist/starfuryop/on_gain()
	if(sbccrew)
		objectives |= sbccrew.objectives
	. = ..()

/datum/team/starfuryop
	name = "Starfury battlecruiser operatives"

/*/datum/team/pirate/proc/forge_objectives()
	var/datum/objective/loot/getbooty = new()
	getbooty.team = src
	for(var/obj/machinery/computer/piratepad_control/P in GLOB.machines)
		var/area/A = get_area(P)
		if(istype(A,/area/shuttle/pirate))
			getbooty.cargo_hold = P
			break
	getbooty.update_explanation_text()
	objectives += getbooty
	for(var/datum/mind/M in members)
		var/datum/antagonist/pirate/P = M.has_antag_datum(/datum/antagonist/pirate)
		if(P)
			P.objectives |= objectives

/datum/team/pirate/roundend_report()
	var/list/parts = list()

	parts += "<span class='header'>Space Pirates were:</span>"

	var/all_dead = TRUE
	for(var/datum/mind/M in members)
		if(considered_alive(M))
			all_dead = FALSE
	parts += printplayerlist(members)

	parts += "Loot stolen: "
	var/datum/objective/loot/L = locate() in objectives
	parts += L.loot_listing()
	parts += "Total loot value : [L.get_loot_value()]/[L.target_value] credits"

	if(L.check_completion() && !all_dead)
		parts += "<span class='greentext big'>The pirate crew was successful!</span>"
	else
		parts += "<span class='redtext big'>The pirate crew has failed.</span>"

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"*/

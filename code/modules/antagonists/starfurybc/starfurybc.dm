/datum/antagonist/starfuryop
	name = "Syndicate Operative"
	roundend_category = "starfury battlecruiser operatives"
	antagpanel_category = "Starfury Operative"
	job_rank = ROLE_TRAITOR
	antag_hud_type = ANTAG_HUD_OPS
	antag_hud_name = "synd"
	antag_moodlet = /datum/mood_event/badass_antag //focused
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
			sbccrew.forge_objectives()
			return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	sbccrew = new_team

/datum/antagonist/starfuryop/on_gain()
	forge_objectives()
	. = ..()

/datum/team/starfuryop
	name = "Starfury battlecruiser operatives"

/datum/team/starfuryop/proc/add_objective(datum/objective/O, needs_target = FALSE)
	O.team = src
	O.update_explanation_text()
	objectives += O

/datum/antagonist/starfuryop/proc/forge_objectives()
	if(sbccrew)
		objectives |= sbccrew.objectives

/datum/team/starfuryop/proc/forge_objectives()
	add_objective(new/datum/objective/syndicatesupermatter, TRUE)

/datum/team/starfuryop/roundend_report()
	var/list/parts = list()

	parts += "<span class='header'>The crew of syndicate battle cruiser were:</span>"
	for(var/datum/mind/M in members)
		parts += printplayer(M)
	var/win = TRUE
	var/objective_count = 1
	for(var/datum/objective/objective in objectives)
		if(objective.check_completion())
			parts += "<B>Objective #[objective_count]</B>: [objective.explanation_text] <span class='greentext'>Success!</span>"
		else
			parts += "<B>Objective #[objective_count]</B>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
			win = FALSE
		objective_count++
	if(win)
		parts += "<span class='greentext'>Crew of syndicate battle cruiser were successful!</span>"
	else
		parts += "<span class='redtext'>Crew of syndicate battle cruiser have failed!</span>"

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

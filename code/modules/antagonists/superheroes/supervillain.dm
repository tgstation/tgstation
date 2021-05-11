/datum/outfit/superhero/villain
	name = "Default Supervillain Outfit"
	uniform = /obj/item/clothing/under/color/black
	shoes = /obj/item/clothing/shoes/sneakers/black
	id = /obj/item/card/id/advanced/black
	id_trim = /datum/id_trim/centcom/superhero/supervillain

/datum/antagonist/supervillain
	name = "Supervillain"
	job_rank = ROLE_SUPERVILLAIN
	roundend_category = "supervillains"
	antagpanel_category = "Supervillain"
	show_to_ghosts = TRUE
	var/datum/team/supervillains/villains

/datum/antagonist/supervillain/greet()
	to_chat(owner, "<span class='boldannounce'>You are a Supervillain!</span>")
	to_chat(owner, "<B>Your main goal is to catch your enemies, Superheroes. Althrough you may antagonise the station, mass-murdering is not allowed.</B>")
	owner.announce_objectives()

/datum/antagonist/supervillain/get_team()
	return villains

/datum/antagonist/supervillain/create_team(datum/team/pirate/new_team)
	if(!new_team)
		for(var/datum/antagonist/supervillain/P in GLOB.antagonists)
			if(!P.owner)
				stack_trace("Antagonist datum without owner in GLOB.antagonists: [P]")
				continue
			if(P.villains)
				villains = P.villains
				return
		if(!new_team)
			villains = new /datum/team/supervillains
			villains.forge_objectives()
			return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	villains = new_team

/datum/antagonist/supervillain/on_gain()
	if(villains)
		objectives |= villains.objectives
	. = ..()

/datum/team/supervillains
	name = "Supervillain Team"

/datum/team/supervillains/proc/forge_objectives()

	var/datum/objective/catch_heroes/objective = new()
	objective.team = src
	objectives += objective

	for(var/datum/mind/M in members)
		var/datum/antagonist/supervillain/villain = M.has_antag_datum(/datum/antagonist/supervillain)
		if(villain)
			villain.objectives |= objectives

/datum/objective/catch_heroes
	name = "Catch All Superheroes"
	explanation_text = "Catch all superheroes before the round ends!"

/datum/objective/catch_heroes/check_completion()
	var/are_heroes_caught = TRUE
	for(var/mob/living/target in GLOB.player_list)
		if(!target.mind && target.mind.assigned_role != ROLE_SUPERHERO)
			continue

		if(!considered_alive(target))
			continue

		if(iscarbon(target))
			var/mob/living/carbon/hero = target
			if(hero.handcuffed || considered_exiled(hero))
				continue

		are_heroes_caught = FALSE
	return ..() || are_heroes_caught

/datum/team/supervillains/roundend_report()
	var/list/parts = list()

	parts += "<span class='header'>Supervillains were:</span>"

	var/all_dead = TRUE
	for(var/datum/mind/M in members)
		if(considered_alive(M))
			all_dead = FALSE
	parts += printplayerlist(members)

	var/datum/objective/catch_heroes/objective = locate() in objectives

	if(objective.check_completion() && !all_dead)
		parts += "<span class='greentext big'>The Supervillain Team was successful!</span>"
	else
		parts += "<span class='redtext big'>The Supervillain Team has failed.</span>"

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

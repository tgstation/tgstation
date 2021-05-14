/datum/outfit/superhero
	name = "Default Superhero Outfit"
	uniform = /obj/item/clothing/under/color/white
	shoes = /obj/item/clothing/shoes/sneakers/white
	back = /obj/item/storage/backpack
	ears = /obj/item/radio/headset
	id = /obj/item/card/id/advanced
	id_trim = /datum/id_trim/centcom/superhero

/datum/antagonist/superhero
	name = "Superhero"
	job_rank = ROLE_SUPERHERO
	roundend_category = "superheroes"
	antagpanel_category = "Superhero"
	show_to_ghosts = TRUE
	var/datum/team/superheroes/heroes
	var/hero_role = "Coder's Fuckup"

/datum/antagonist/superhero/greet()
	to_chat(owner, "<span class='boldannounce'>You are a Superhero!</span>")
	to_chat(owner, "<B>Protect the station and the crew, help security and catch the pesky villains! Do not hurt innocent people!</B>")
	owner.announce_objectives()

/datum/antagonist/superhero/get_team()
	return heroes

/datum/antagonist/superhero/create_team(datum/team/pirate/new_team)
	if(!new_team)
		for(var/datum/antagonist/superhero/P in GLOB.antagonists)
			if(!P.owner)
				stack_trace("Antagonist datum without owner in GLOB.antagonists: [P]")
				continue
			if(P.heroes)
				heroes = P.heroes
				return
		if(!new_team)
			heroes = new /datum/team/superheroes
			heroes.forge_objectives()
			return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	heroes = new_team

/datum/antagonist/superhero/on_gain()
	if(heroes)
		objectives |= heroes.objectives
	. = ..()

/datum/team/superheroes
	name = "Superhero Team"

/datum/team/superheroes/proc/forge_objectives()

	var/datum/objective/catch_villains/objective = new()
	objective.team = src
	objectives += objective

	for(var/datum/mind/M in members)
		var/datum/antagonist/superhero/hero = M.has_antag_datum(/datum/antagonist/superhero)
		if(hero)
			hero.objectives |= objectives

/datum/objective/catch_villains
	name = "Catch All Supervillains"
	explanation_text = "Catch all supervillains aboard the station! Ensure that they are all handcuffed when the round ends."

/datum/objective/catch_villains/check_completion()
	var/are_villains_caught = TRUE
	for(var/mob/living/target in GLOB.player_list)
		if(!target.mind && target.mind.assigned_role != ROLE_SUPERVILLAIN)
			continue

		if(!considered_alive(target))
			continue

		if(iscarbon(target))
			var/mob/living/carbon/villain = target
			if(villain.handcuffed || considered_exiled(villain))
				continue

		are_villains_caught = FALSE
	return ..() || are_villains_caught

/datum/team/superheroes/roundend_report()
	var/list/parts = list()

	parts += "<span class='header'>Superheroes were:</span>"

	var/all_dead = TRUE
	for(var/datum/mind/M in members)
		if(considered_alive(M))
			all_dead = FALSE
	parts += printplayerlist(members)

	var/datum/objective/catch_villains/objective = locate() in objectives

	if(objective.check_completion() && !all_dead)
		parts += "<span class='greentext big'>The Superhero Team was successful!</span>"
	else
		parts += "<span class='redtext big'>The Superhero Team has failed.</span>"

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

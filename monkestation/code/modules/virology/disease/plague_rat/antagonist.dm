/datum/antagonist/plague_rat
	name = "Plague Rat"
	job_rank = ROLE_PLAGUERAT

	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE

	antag_hud_name = "plaguerat"

	var/static/datum/team/plague_rat/rats_rats_we_are_the_rats
	var/disease_id
	var/datum/disease/advanced/bacteria/plague
	var/turf/invasion

/datum/antagonist/plague_rat/on_gain()
	if(!rats_rats_we_are_the_rats)
		rats_rats_we_are_the_rats = new
		rats_rats_we_are_the_rats.setup_diseases()

	rats_rats_we_are_the_rats.add_member(owner)

	disease_id = rats_rats_we_are_the_rats.disease_id
	plague = rats_rats_we_are_the_rats.plague
	invasion = rats_rats_we_are_the_rats.invasion

	if (invasion)
		for(var/datum/mind/M in rats_rats_we_are_the_rats.members)
			M.current.forceMove(invasion)
	owner.current.infect_disease(plague,1, "Plague Mice")
	ADD_TRAIT(owner.current, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	return ..()

/datum/antagonist/plague_rat/greet()
	. = ..()
	to_chat(owner.current, " <span class='warning'><B>You are a [name]! Carrier of a dangerous Bacteria!</B><BR>Try and spread your contagion across the station!</span>")

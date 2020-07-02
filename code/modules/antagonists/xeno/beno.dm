/datum/team/beno
	name = "Aliens"

//Simply lists them.
/datum/team/beno/roundend_report()
	var/list/parts = list()
	parts += "<span class='header'>The [name] were:</span>"
	parts += printplayerlist(members)
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/antagonist/beno
	name = "Benomorph"
	job_rank = ROLE_ALIEN
	show_in_antagpanel = FALSE
	prevent_roundtype_conversion = FALSE
	show_to_ghosts = TRUE
	var/datum/team/beno/xeno_team

/datum/antagonist/beno/create_team(datum/team/beno/new_team)
	if(!new_team)
		for(var/datum/antagonist/beno/X in GLOB.antagonists)
			if(!X.owner || !X.xeno_team)
				continue
			xeno_team = X.xeno_team
			return
		xeno_team = new
	else
		if(!istype(new_team))
			CRASH("Wrong beno team type provided to create_team")
		xeno_team = new_team

/datum/antagonist/beno/get_team()
	return xeno_team

//BENO
/mob/living/carbon/alien/mind_initialize()
	..()
	if(!mind.has_antag_datum(/datum/antagonist/beno))
		mind.add_antag_datum(/datum/antagonist/beno)

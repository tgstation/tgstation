/datum/team/swarmer
	name = "Swarmers"

//Simply lists them.
/datum/team/swarmer/roundend_report()
	var/list/parts = list()
	parts += "<span class='header'>The [name] were:</span>"
	parts += printplayerlist(members)
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/antagonist/swarmer
	name = "\improper Swarmer"
	job_rank = ROLE_SWARMER
	show_to_ghosts = TRUE
	show_in_antagpanel = FALSE
	prevent_roundtype_conversion = FALSE
	var/datum/team/swarmer/swarmer_team

/datum/antagonist/swarmer/create_team(datum/team/swarmer/new_team)
	if(!new_team)
		for(var/datum/antagonist/swarmer/swarmerantag in GLOB.antagonists)
			if(!swarmerantag.owner || !swarmerantag.swarmer_team)
				continue
			swarmer_team = swarmerantag.swarmer_team
			return
		swarmer_team = new
	else
		if(!istype(new_team))
			CRASH("Wrong swarmer team type provided to create_team")
		swarmer_team = new_team

/datum/antagonist/swarmer/get_team()
	return swarmer_team

/datum/antagonist/swarmer/get_preview_icon()
	var/icon/swarmer_icon = icon('icons/mob/swarmer.dmi', "swarmer")
	swarmer_icon.Shift(NORTH, 8)
	return finish_preview_icon(swarmer_icon)

//SWARMER
/mob/living/simple_animal/hostile/swarmer/mind_initialize()
	..()
	if(!mind.has_antag_datum(/datum/antagonist/swarmer))
		mind.add_antag_datum(/datum/antagonist/swarmer)

/datum/antagonist/mimic
	name = "Mimic"
	roundend_category = "mimics"
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	show_in_antagpanel = FALSE
	//The file id for the antag tip window that will pop up
	tips = "mimic"
	var/datum/team/mimic/mimic_team


/datum/antagonist/mimic/get_team()
	return mimic_team

/datum/antagonist/mimic/create_team(datum/team/mimic/new_team)
	var/mob/living/simple_animal/hostile/alien_mimic/current_mimic = owner.current
	if(!istype(current_mimic))
		stack_trace("Mimic antagonist datum assigned to a non-mimic.")

	if(!new_team)
		for(var/datum/antagonist/mimic/mimic_antag in GLOB.antagonists)
			if(!mimic_antag.owner)
				continue
			if(mimic_antag.mimic_team)
				mimic_team = mimic_antag.mimic_team
				return
		mimic_team = new /datum/team/mimic
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	mimic_team = new_team

/datum/antagonist/mimic/greet()
	owner.current.playsound_local(get_turf(owner.current), 'monkestation/sound/ambience/antag/mimic.ogg',100,0, use_reverb = FALSE)
	var/mob/living/simple_animal/hostile/alien_mimic/spawned_mimic = owner.current
	to_chat(spawned_mimic, spawned_mimic.playstyle_string)


//Mimic Team
/datum/team/mimic
	name = "Mimic"

	var/people_absorbed = 0
	var/total_people_absorbed = 0

	var/list/datum/mind/original_members = list()

	//List of all mimics, both sentient and non sentient
	var/list/mob/living/mimics = list()


/datum/team/mimic/roundend_report()
	var/list/parts = list()

	if(members.len)
		parts += "<span class='greentext big'>The mimics have survived!</span>"
	else
		parts += "<span class='redtext big'>The mimics have been exterminated!</span>"

	parts += "<b>The mimic's statistics were:</b>"

	parts += "The final amount of mimics: [mimics.len]"
	parts += "The total amount of people absorbed: [total_people_absorbed]"

	if(original_members.len)
		parts += "<span class='header'>The original mimics were:</span>"
		parts += printplayerlist(original_members)

	if(members.len)
		parts += "<span class='header'>The mimics were:</span>"
		parts += printplayerlist(members - original_members)

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/team/ashwalkers
	name = "Ashwalkers"
	var/obj/structure/tendril
	var/show_roundend_report = FALSE

/datum/team/ashwalkers/New(starting_members, var/obj/structure/goal)
	..()
	tendril = goal

/datum/team/ashwalkers/roundend_report()
	if(show_roundend_report)
		. = ..()

/datum/team/ashwalkers/proc/forge_objectives()
	var/datum/objective/nest/protect = new()
	protect.team = src
	protect.update_explanation_text()
	objectives += protect

/datum/objective/nest
	explanation_text = "Protect the tendril at all costs."

/datum/objective/nest/update_explanation_text()
	..()
	var/datum/team/ashwalkers/ashies = team
	if(istype(ashies) && ashies.tendril)
		explanation_text = "Protect \the [ashies.tendril] at all costs."

/datum/objective/nest/check_completion()
	var/datum/team/ashwalkers/ashies = team
	if(istype(ashies))
		return ashies.tendril

/datum/antagonist/ashwalker
	name = "Ash Walker"
	job_rank = ROLE_ASHWALKER
	show_in_antagpanel = FALSE
	var/datum/team/ashwalkers/ashie_team

/datum/antagonist/ashwalker/create_team(datum/team/team)
	if(team)
		ashie_team = team
		objectives |= ashie_team.objectives
	else
		ashie_team = new()

/datum/antagonist/ashwalker/get_team()
	return ashie_team

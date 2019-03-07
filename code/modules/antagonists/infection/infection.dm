/datum/antagonist/infection
	name = "Infection"
	roundend_category = "infections"
	antagpanel_category = "Infection"
	job_rank = ROLE_INFECTION

	var/starting_points_human_infection = 60
	var/point_rate_human_infection = 2

/datum/antagonist/infection/roundend_report()
	var/basic_report = ..()
	//Display max infection points for infectiowns that lost
	var/mob/camera/commander/overmind = owner.current
	if(!overmind.victory_in_progress) //if it won this doesn't really matter
		var/point_report = "<br><b>[owner.name]</b> left [GLOB.infection_beacons.len] beacons at the height of its growth."
		return basic_report+point_report
	return basic_report

/datum/antagonist/infection/greet()
	to_chat(owner,"<span class='userdanger'>You feel radiant.</span>")

/datum/antagonist/infection/on_gain()
	create_objectives()
	. = ..()

/datum/antagonist/infection/proc/create_objectives()
	var/datum/objective/infection_takeover/main = new
	main.owner = owner
	objectives += main

/datum/objective/infection_takeover
	explanation_text = "Destroy all of the beacons!"

/datum/antagonist/infection/antag_listing_status()
	. = ..()
	if(owner && owner.current)
		var/mob/camera/commander/I = owner.current
		if(istype(I))
			. += "(Progress: [GLOB.infection_beacons.len])"
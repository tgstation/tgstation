/*
Fallout 13 Job Base Class
*/
/datum/job/f13
	title = "Default - please implement the title in your dataum/job/f13/yourjob file"
	supervisors = "N/A - please implement the supervisors in your dataum/job/f13/yourjob file"
	faction = "Wasteland"

//These are base jobs, we don't want them appearing at all
/datum/job/f13/config_check()
	if(type == /datum/job/f13)
		return FALSE
	return ..()

/datum/job/f13/map_check()
	if(type == /datum/job/f13)
		return FALSE
	return ..()

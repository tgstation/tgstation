//Just a check antags holder, all abilities are innate to camera mob because this is a hack for one week   

/datum/antagonist/ghostmaster
	name = "ghostmaster"
	roundend_category = "ghost masters"
	antagpanel_category = "ghostmaster"
	job_rank = ROLE_BLOB

	var/datum/action/innate/blobpop/pop_action
	var/starting_points_human_blob = 60
	var/point_rate_human_blob = 2

/datum/antagonist/ghostmaster/on_gain()
	create_objectives()
	. = ..()

/datum/antagonist/ghostmaster/proc/create_objectives()
	var/datum/objective/main = new
	main.explanation_text = "Scare everyone off the station"
	main.owner = owner
	objectives += main
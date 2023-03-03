/datum/antagonist/frogression_traitor
	name = "\improper Frogression Traitor"
	job_rank = ROLE_FROGRESSION_TRAITOR
	hijack_speed = 0.5
	suicide_cry = "FOR THE CROAKDICATE!!" //don't even know how you would manage to do this
	antagpanel_category = "Traitor"

/datum/antagonist/frogression_traitor/get_preview_icon()
	var/icon/frog_icon = icon('icons/mob/simple/animal.dmi', "frog")
	frog_icon.Scale(ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)
	//TODO syndicate logo as background?
	return frog_icon

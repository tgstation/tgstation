/datum/antagonist/nightmare
	name = "\improper Nightmare"
	antagpanel_category = "Nightmare"
	job_rank = ROLE_NIGHTMARE
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	ui_name = "AntagInfoNightmare"
	suicide_cry = "FOR THE DARKNESS!!"
	preview_outfit = /datum/outfit/nightmare

/datum/outfit/nightmare
	name = "Nightmare (Preview only)"

/datum/outfit/nightmare/post_equip(mob/living/carbon/human/human, visualsOnly)
	human.set_species(/datum/species/shadow/nightmare)

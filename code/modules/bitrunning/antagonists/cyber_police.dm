/datum/job/cyber_police
	title = ROLE_CYBER_POLICE

/datum/antagonist/bitrunning_glitch/cyber_police
	name = ROLE_CYBER_POLICE
	antagpanel_category = ANTAG_GROUP_GLITCH
	job_rank = ROLE_CYBER_POLICE
	preview_outfit = /datum/outfit/cyber_police
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	suicide_cry = "ALT F4!"
	ui_name = "AntagInfoCyberAuth"

/datum/antagonist/bitrunning_glitch/cyber_police/on_gain()
	if(!ishuman(owner.current))
		stack_trace("humans only for this position")
		return

	var/mob/living/carbon/human/player = owner.current

	player.equipOutfit(/datum/outfit/cyber_police)
	player.fully_replace_character_name(player.name, pick(GLOB.cyberauth_names))

	var/datum/martial_art/the_sleeping_carp/carp = new()
	carp.teach(player)

	return ..()


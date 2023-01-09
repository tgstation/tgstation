/datum/antagonist/blobbernaut
	name = "\improper Blobbernaut"
	antagpanel_category = ANTAG_GROUP_BIOHAZARDS
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	show_in_antagpanel = FALSE

/datum/antagonist/blobbernaut/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/blobbernaut/greet()
	. = ..()
	owner.announce_objectives()

/datum/antagonist/blobbernaut/forge_objectives()
	var/mob/living/simple_animal/hostile/blob/blobbernaut/naut = owner.current
	if(!naut)
		return
	naut.create_objectives(src)

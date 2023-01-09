/datum/antagonist/blobspore
	name = "\improper Blob Spore"
	antagpanel_category = ANTAG_GROUP_BIOHAZARDS
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	show_in_antagpanel = FALSE

/datum/antagonist/blobspore/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/blobspore/greet()
	. = ..()
	owner.announce_objectives()

/datum/antagonist/blobspore/forge_objectives()
	var/mob/living/simple_animal/hostile/blob/blobspore/spore = owner.current
	if(!spore)
		return
	spore.create_objectives(src)

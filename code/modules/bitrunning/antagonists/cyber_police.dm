/datum/antagonist/bitrunning_glitch/cyber_police
	name = ROLE_CYBER_POLICE
	show_in_antagpanel = TRUE

/datum/antagonist/bitrunning_glitch/cyber_police/on_gain()
	. = ..()

	if(!ishuman(owner.current))
		stack_trace("humans only for this position")
		return

	var/mob/living/player = owner.current
	convert_agent(player, /datum/outfit/cyber_police)

	var/datum/martial_art/the_sleeping_carp/carp = new()
	carp.teach(player)

/datum/outfit/cyber_police
	name = ROLE_CYBER_POLICE

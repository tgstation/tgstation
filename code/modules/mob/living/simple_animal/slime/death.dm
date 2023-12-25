/mob/living/simple_animal/slime/death(gibbed)
	if(stat == DEAD)
		return
	if(!gibbed)
		if(is_adult)
			var/mob/living/simple_animal/slime/new_slime = new(drop_location(), slime_type.type)
			new_slime.rabid = TRUE
			new_slime.regenerate_icons()

			is_adult = FALSE
			maxHealth = 150
			for(var/datum/action/innate/slime/reproduce/reproduce_action in actions)
				reproduce_action.Remove(src)
			var/datum/action/innate/slime/evolve/evolve_action = new
			evolve_action.Grant(src)
			revive(HEAL_ALL)
			regenerate_icons()
			update_name()
			return

	if(buckled)
		stop_feeding(silent = TRUE) //releases ourselves from the mob we fed on.

	cut_overlays()

	return ..(gibbed)

/mob/living/simple_animal/slime/gib()
	death(TRUE)
	qdel(src)

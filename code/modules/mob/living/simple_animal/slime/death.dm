/mob/living/simple_animal/slime/death(gibbed)
	if(stat == DEAD)
		return
	if(!gibbed)
		if(is_adult)
			var/mob/living/simple_animal/slime/M = new(drop_location(), colour)
			M.rabid = TRUE
			M.regenerate_icons()

			is_adult = FALSE
			maxHealth = 150
			for(var/datum/action/innate/slime/reproduce/R in actions)
				R.Remove(src)
			var/datum/action/innate/slime/evolve/E = new
			E.Grant(src)
			revive(HEAL_ALL)
			regenerate_icons()
			update_name()
			return

	if(buckled)
		Feedstop(silent = TRUE) //releases ourselves from the mob we fed on.

	set_stat(DEAD)
	cut_overlays()

	return ..(gibbed)

/mob/living/simple_animal/slime/gib()
	death(TRUE)
	qdel(src)

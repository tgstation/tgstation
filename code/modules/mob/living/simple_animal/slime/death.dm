/mob/living/simple_animal/slime/death(gibbed)
	if(stat == DEAD)
		return
	if(!gibbed)
		if(is_adult)
			var/mob/living/simple_animal/slime/M = new(loc, colour)
			M.rabid = TRUE
			M.regenerate_icons()

			is_adult = FALSE
			maxHealth = 150
			for(var/datum/action/innate/slime/reproduce/R in actions)
				R.Remove(src)
			var/datum/action/innate/slime/evolve/E = new
			E.Grant(src)
			revive(full_heal = 1)
			regenerate_icons()
			update_name()
			return

	if(buckled)
		Feedstop(silent = 1) //releases ourselves from the mob we fed on.

	stat = DEAD
	cut_overlays()

	update_canmove()

	if(SSticker.mode)
		SSticker.mode.check_win()

	return ..(gibbed)

/mob/living/simple_animal/slime/gib()
	death(1)
	qdel(src)


/mob/living/simple_animal/slime/Destroy()
	for(var/obj/machinery/computer/camera_advanced/xenobio/X in GLOB.machines)
		if(src in X.stored_slimes)
			X.stored_slimes -= src
	return ..()

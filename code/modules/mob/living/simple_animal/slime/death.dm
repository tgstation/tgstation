/mob/living/simple_animal/slime/death(gibbed)
	if(stat == DEAD)
		return
	if(!gibbed)
		if(is_adult)
			var/mob/living/simple_animal/slime/M = new /mob/living/simple_animal/slime(loc)
			M.colour = colour
			M.rabid = 1
			M.regenerate_icons()
			is_adult = 0
			maxHealth = 150
			for(var/datum/action/innate/slime/reproduce/R in actions)
				R.Remove(src)
			var/datum/action/innate/slime/evolve/E = new
			E.Grant(src)
			revive(full_heal = 1)
			regenerate_icons()
			number = rand(1, 1000)
			name = "[colour] [is_adult ? "adult" : "baby"] slime ([number])"
			return

	if(buckled)
		Feedstop(silent = 1) //releases ourselves from the mob we fed on.

	stat = DEAD
	overlays.len = 0

	update_canmove()

	if(ticker && ticker.mode)
		ticker.mode.check_win()

	return ..(gibbed)

/mob/living/simple_animal/slime/gib()
	death(1)
	qdel(src)


/mob/living/simple_animal/slime/Destroy()
	for(var/obj/machinery/computer/camera_advanced/xenobio/X in machines)
		if(src in X.stored_slimes)
			X.stored_slimes -= src
	return ..()

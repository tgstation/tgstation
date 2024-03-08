/mob/living/simple_animal/slime/death(gibbed)
	if(stat == DEAD)
		return
	if(!gibbed && life_stage == SLIME_LIFE_STAGE_ADULT)
		var/mob/living/simple_animal/slime/new_slime = new(drop_location(), slime_type.type)
		new_slime.rabid = TRUE
		new_slime.regenerate_icons()

		//revives us as a baby
		set_life_stage(SLIME_LIFE_STAGE_BABY)
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

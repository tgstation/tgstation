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
			revive()
			regenerate_icons()
			number = rand(1, 1000)
			name = "[colour] [is_adult ? "adult" : "baby"] slime ([number])"
			return

	stat = DEAD
	overlays.len = 0

	update_canmove()
	if(blind)
		blind.layer = 0

	if(ticker && ticker.mode)
		ticker.mode.check_win()

	return ..(gibbed)

/mob/living/simple_animal/slime/gib()
	death(1)
	qdel(src)

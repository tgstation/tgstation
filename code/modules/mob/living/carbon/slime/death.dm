/mob/living/carbon/slime/death(gibbed)
	if(stat == DEAD)
		return
	if(!gibbed)
		if(is_adult)
			var/mob/living/carbon/slime/M = new /mob/living/carbon/slime(loc)
			M.colour = colour
			M.rabid = 1
			is_adult = 0
			maxHealth = 150
			revive()
			regenerate_icons()
			number = rand(1, 1000)
			name = "[colour] [is_adult ? "adult" : "baby"] slime ([number])"
			return
		else
			visible_message("<b>The [name]</b> seizes up and falls limp...")

	stat = DEAD
	icon_state = "[colour] baby slime dead"
	overlays.len = 0

	update_canmove()
	if(blind)	blind.layer = 0

	if(ticker && ticker.mode)
		ticker.mode.check_win()

	return ..(gibbed)

/mob/living/carbon/slime/gib()
	death(1)
	qdel(src)
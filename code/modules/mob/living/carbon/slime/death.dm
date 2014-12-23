/mob/living/carbon/slime/death(gibbed)
	if(!gibbed)
		if(is_adult)
			var/mob/living/carbon/slime/M = new /mob/living/carbon/slime(loc)
			M.color = color
			M.rabid = 1
			is_adult = 0
			maxHealth = 150
			revive()
			regenerate_icons()
			number = rand(1, 1000)
			name = "[color] [is_adult ? "adult" : "baby"] slime ([number])"
			return

	if(stat == DEAD)	return
	stat = DEAD
	icon_state = "[color] baby slime dead"
	overlays.len = 0
	visible_message("<b>The [name]</b> seizes up and falls limp...") //ded -- Urist

	update_canmove()
	if(blind)	blind.layer = 0

	if(ticker && ticker.mode)
		ticker.mode.check_win()

	return ..(gibbed)
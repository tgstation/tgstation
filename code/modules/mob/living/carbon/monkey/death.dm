/mob/living/carbon/monkey/gib_animation()
	PoolOrNew(/obj/effect/overlay/temp/gib_animation, list(loc, "gibbed-m"))

/mob/living/carbon/monkey/dust_animation()
	PoolOrNew(/obj/effect/overlay/temp/dust_animation, list(loc, "dust-m"))

/mob/living/carbon/monkey/death(gibbed)
	if(stat == DEAD)
		return

	if(!gibbed)
		emote("deathgasp")

	stat = DEAD

	if(ticker && ticker.mode)
		ticker.mode.check_win()

	return ..(gibbed)
/mob/living/silicon/pai/death(gibbed)
	if(stat == DEAD)
		return
	stat = DEAD
	canmove = 0
	card.removePersonality()
	card.forceMove(loc)
	update_sight()
	clear_fullscreens()

	//New pAI's get a brand new mind to prevent meta stuff from their previous life. This new mind causes problems down the line if it's not deleted here.
	GLOB.living_mob_list -= src
	ghostize()
	qdel(src)

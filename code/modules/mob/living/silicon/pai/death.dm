/mob/living/silicon/pai/death(gibbed)
	if(stat == DEAD)	return
	stat = DEAD
	canmove = 0
	if(blind)	blind.layer = 0
	sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
	see_in_dark = 8
	see_invisible = 2

	//var/tod = time2text(world.realtime,"hh:mm:ss") //weasellos time of death patch
	//mind.store_memory("Time of death: [tod]", 0)

	//New pAI's get a brand new mind to prevent meta stuff from their previous life. This new mind causes problems down the line if it's not deleted here.
	//Read as: I have no idea what I'm doing but asking for help got me nowhere so this is what you get. - Nodrak
	del(mind)
	if(key)	ghostize(0)
	del(src)
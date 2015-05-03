/mob/living/silicon/robot/mommi/gib(var/animation = 1)
	..()


/mob/living/silicon/robot/mommi/dust(var/animation = 1)
	if(mmi)
		qdel(mmi)
	..()

/mob/living/silicon/robot/mommi/death(gibbed)
	if(stat == DEAD)	return
	if(!gibbed)
		emote("deathgasp")
	stat = DEAD
	update_canmove()
	if(camera)
		camera.status = 0
/*
	if(in_contents_of(/obj/machinery/recharge_station))//exit the recharge station
		var/obj/machinery/recharge_station/RC = loc
		if(RC.upgrading)
			RC.upgrading = 0
			RC.upgrade_finished = -1
		RC.go_out()
*/
	if(blind)	blind.layer = 0
	sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO
	updateicon()

	tod = worldtime2text() //weasellos time of death patch
	if(mind)	mind.store_memory("Time of death: [tod]", 0)

	sql_report_cyborg_death(src)
	return ..(gibbed)
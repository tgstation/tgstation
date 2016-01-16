/mob/living/silicon/robot/gib()
	//robots don't die when gibbed. instead they drop their MMI'd brain
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	anim(target = src, a_icon = 'icons/mob/mob.dmi', flick_anim = "gibbed-r", sleeptime = 15)
	robogibs(loc, viruses)

	if(mind) //To make sure we're gibbing a player, who knows
		if(!suiciding) //I don't know how that could happen, but you can't be too sure
			score["deadsilicon"] += 1

	living_mob_list -= src
	dead_mob_list -= src
	qdel(src)

/mob/living/silicon/robot/dust()
	death(1)
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	anim(target = src, a_icon = 'icons/mob/mob.dmi', flick_anim = "dust-r", sleeptime = 15)
	new /obj/effect/decal/remains/robot(loc)
	if(mmi)
		qdel(mmi)	//Delete the MMI first so that it won't go popping out.

	dead_mob_list -= src
	qdel(src)


/mob/living/silicon/robot/death(gibbed)
	if(stat == DEAD)	return
	if(!gibbed)
		emote("deathgasp")
	stat = DEAD
	update_canmove()
	if(camera)
		camera.status = 0

	if(in_contents_of(/obj/machinery/recharge_station))//exit the recharge station
		var/obj/machinery/recharge_station/RC = loc
		if(RC.upgrading)
			RC.upgrading = 0
			RC.upgrade_finished = -1
		RC.go_out()

	if(blind)	blind.layer = 0
	sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO
	updateicon()

	tod = worldtime2text() //weasellos time of death patch
	if(mind)
		mind.store_memory("Time of death: [tod]", 0)
		if(!suiciding)
			score["deadsilicon"] += 1

	sql_report_cyborg_death(src)

	return ..(gibbed)
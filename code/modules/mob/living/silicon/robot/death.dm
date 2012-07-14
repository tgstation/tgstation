/mob/living/silicon/robot/gib()
	//robots don't die when gibbed. instead they drop their MMI'd brain
	var/atom/movable/overlay/animation = null
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'mob.dmi'
	animation.master = src

	flick("gibbed-r", animation)
	robogibs(loc, viruses)

	spawn(15)
		if(animation)	del(animation)
		if(src)			del(src)

/mob/living/silicon/robot/dust()
	death(1)
	var/atom/movable/overlay/animation = null
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'mob.dmi'
	animation.master = src

	flick("dust-r", animation)
	new /obj/effect/decal/remains/robot(loc)
	if(mmi)		del(mmi)	//Delete the MMI first so that it won't go popping out.

	spawn(15)
		if(animation)	del(animation)
		if(src)			del(src)


/mob/living/silicon/robot/death(gibbed)
	if(stat == DEAD)	return
	if(!gibbed)
		emote("deathgasp")
	stat = DEAD
	update_canmove()

	tension_master.death(src)

	camera.status = 0

	if(in_contents_of(/obj/machinery/recharge_station))//exit the recharge station
		var/obj/machinery/recharge_station/RC = loc
		RC.go_out()

	if(blind)	blind.layer = 0
	sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
	see_in_dark = 8
	see_invisible = 2
	updateicon()

	tod = worldtime2text() //weasellos time of death patch
	if(mind)	mind.store_memory("Time of death: [tod]", 0)

	sql_report_cyborg_death(src)

	return ..(gibbed)
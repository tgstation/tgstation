/mob/living/silicon/robot/gib(animation = 1)
	..()

/mob/living/silicon/robot/spawn_gibs()
	robogibs(loc, viruses)

/mob/living/silicon/robot/gib_animation(animate)
	..(animate, "gibbed-r")

/mob/living/silicon/robot/dust(animation = 1)
	if(mmi)
		qdel(mmi)
	..()

/mob/living/silicon/robot/spawn_dust()
	new /obj/effect/decal/remains/robot(loc)

/mob/living/silicon/robot/dust_animation(animate)
	..(animate, "dust-r")

/mob/living/silicon/robot/death(gibbed)
	if(stat == DEAD)
		return
	if(!gibbed)
		emote("deathgasp")
	locked = 0 //unlock cover
	stat = DEAD
	update_canmove()
	if(camera)
		camera.status = 0
	update_headlamp(1) //So borg lights are disabled when killed.

	uneq_all() // particularly to ensure sight modes are cleared

	if(blind)
		blind.layer = 0
	sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO
	update_icons()
	tod = worldtime2text() //weasellos time of death patch
	if(mind)	mind.store_memory("Time of death: [tod]", 0)

	sql_report_cyborg_death(src)

	return ..(gibbed)
/mob/living/silicon/robot/mommi/gib(var/animation = 1)
	if(generated)
		src.dust()
	if(src.module && istype(src.module))
		var/obj/item/found = locate(tool_state) in src.module.modules
		if(!found && tool_state != src.module.emag)
			var/obj/item/TS = tool_state
			drop_item()
			if(TS && TS.loc)
				TS.loc = src.loc

	..()


/mob/living/silicon/robot/mommi/dust(var/animation = 1)
	if(src.module && istype(src.module)) //Drop what it's holding if it isn't a module
		var/obj/item/found = locate(tool_state) in src.module.modules
		if(!found && tool_state != src.module.emag)
			var/obj/item/TS = tool_state
			drop_item()
			if(TS && TS.loc)
				TS.loc = src.loc
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
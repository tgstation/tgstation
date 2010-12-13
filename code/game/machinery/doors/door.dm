/obj/machinery/door/Bumped(atom/AM)
	if(p_open || operating) return
	if(ismob(AM))
		var/mob/M = AM
		if(world.timeofday - AM.last_bumped <= 60) return
		if(M.client && !M:handcuffed)
			bumpopen(M)
	else if(istype(AM, /obj/machinery/bot))
		var/obj/machinery/bot/bot = AM
		if(src.check_access(bot.botcard))
			if(density)
				open()
	else if(istype(AM, /obj/livestock))
		var/obj/livestock/ani =AM
		if(src.check_access(ani.anicard))
			if(density)
				open()
	else if(istype(AM, /obj/alien/facehugger))
		if(src.check_access(null))
			if(density)
				open()

/obj/machinery/door/proc/bumpopen(mob/user as mob)
	if (src.operating)
		return
	//if(world.timeofday-last_used <= 10)
	//	return
	src.add_fingerprint(user)
	if (!src.requiresID())
		//don't care who they are or what they have, act as if they're NOTHING
		user = null

	if (src.allowed(user))
		if (src.density)
			//last_used = world.timeofday
			open()
	else if (src.density)
		flick("door_deny", src)
	return


/obj/machinery/door/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group) return 0
	if(istype(mover, /obj/beam))
		return !opacity
	return !density

/obj/machinery/door/proc/update_nearby_tiles(need_rebuild)
	if(!air_master) return 0

	var/turf/simulated/source = loc
	var/turf/simulated/north = get_step(source,NORTH)
	var/turf/simulated/south = get_step(source,SOUTH)
	var/turf/simulated/east = get_step(source,EAST)
	var/turf/simulated/west = get_step(source,WEST)

	if(need_rebuild)
		if(istype(source)) //Rebuild/update nearby group geometry
			if(source.parent)
				air_master.groups_to_rebuild += source.parent
			else
				air_master.tiles_to_update += source
		if(istype(north))
			if(north.parent)
				air_master.groups_to_rebuild += north.parent
			else
				air_master.tiles_to_update += north
		if(istype(south))
			if(south.parent)
				air_master.groups_to_rebuild += south.parent
			else
				air_master.tiles_to_update += south
		if(istype(east))
			if(east.parent)
				air_master.groups_to_rebuild += east.parent
			else
				air_master.tiles_to_update += east
		if(istype(west))
			if(west.parent)
				air_master.groups_to_rebuild += west.parent
			else
				air_master.tiles_to_update += west
	else
		if(istype(source)) air_master.tiles_to_update += source
		if(istype(north)) air_master.tiles_to_update += north
		if(istype(south)) air_master.tiles_to_update += south
		if(istype(east)) air_master.tiles_to_update += east
		if(istype(west)) air_master.tiles_to_update += west

	return 1

/obj/machinery/door
	New()
		..()

		update_nearby_tiles(need_rebuild=1)

	Del()
		update_nearby_tiles()

		..()


/obj/machinery/door/meteorhit(obj/M as obj)
	src.open()
	return

/obj/machinery/door/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/door/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/door/attack_hand(mob/user as mob)
	return src.attackby(user, user)

/obj/machinery/door/proc/requiresID()
	return 1

/obj/machinery/door/attackby(obj/item/I as obj, mob/user as mob)
	if (src.operating)
		return
	src.add_fingerprint(user)
	if (!src.requiresID())
		//don't care who they are or what they have, act as if they're NOTHING
		user = null
	if (src.density && istype(I, /obj/item/weapon/card/emag))
		src.operating = -1
		flick("door_spark", src)
		sleep(6)
		open()
		return 1
	if (src.allowed(user))
		if (src.density)
			open()
		else
			close()
	else if (src.density)
		flick("door_deny", src)
	return

/obj/machinery/door/blob_act()
	if(prob(40))
		del(src)

/obj/machinery/door/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
		if(2.0)
			if(prob(25))
				del(src)
		if(3.0)
			if(prob(80))
				var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
				s.set_up(2, 1, src)
				s.start()

/obj/machinery/door/proc/update_icon()
	if(density)
		icon_state = "door1"
	else
		icon_state = "door0"
	return

/obj/machinery/door/proc/animate(animation)
	switch(animation)
		if("opening")
			if(p_open)
				flick("o_doorc0", src)
			else
				flick("doorc0", src)
		if("closing")
			if(p_open)
				flick("o_doorc1", src)
			else
				flick("doorc1", src)
		if("deny")
			flick("door_deny", src)
	return

/obj/machinery/door/proc/open()
	if(!density)
		return 1
	if (src.operating == 1) //doors can still open when emag-disabled
		return
	if (!ticker)
		return 0
	if(!src.operating) //in case of emag
		src.operating = 1

	animate("opening")
	sleep(10)
	src.density = 0
	update_icon()

	src.sd_SetOpacity(0)
	update_nearby_tiles()

	if(operating == 1) //emag again
		src.operating = 0

	if(autoclose)
		spawn(150)
			autoclose()
	return 1

/obj/machinery/door/proc/close()
	if(density)
		return 1
	if (src.operating)
		return
	src.operating = 1

	animate("closing")
	src.density = 1
	sleep(10)
	update_icon()

	if (src.visible && (!istype(src, /obj/machinery/door/airlock/glass)))
		src.sd_SetOpacity(1)
	if(operating == 1)
		operating = 0
	update_nearby_tiles()

/obj/machinery/door/proc/autoclose()
	var/obj/machinery/door/airlock/A = src
	if ((!A.density) && !( A.operating ) && !(A.locked) && !( A.welded ))
		close()
	else return

/////////////////////////////////////////////////// Unpowered doors

/obj/machinery/door/unpowered/Bumped(atom/AM)
	if(p_open || operating) return
	if (src.locked)
		return
	if(ismob(AM))
		var/mob/M = AM
		if(world.timeofday - AM.last_bumped <= 60) return
		if(M.client && !M:handcuffed)
			bumpopen(M)
	else if(istype(AM, /obj/machinery/bot))
		var/obj/machinery/bot/bot = AM
		if(src.check_access(bot.botcard))
			if(density)
				open()
	else if(istype(AM, /obj/livestock))
		var/obj/livestock/ani =AM
		if(src.check_access(ani.anicard))
			if(density)
				open()
	else if(istype(AM, /obj/alien/facehugger))
		if(src.check_access(null))
			if(density)
				open()

/obj/machinery/door/unpowered
	autoclose = 0
	var/locked = 0

/obj/machinery/door/unpowered/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/door/unpowered/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/door/unpowered/attack_hand(mob/user as mob)
	return src.attackby(null, user)

/obj/machinery/door/unpowered/attackby(obj/item/I as obj, mob/user as mob)
	if (src.operating)
		return
	if (src.locked)
		return
	src.add_fingerprint(user)
	if (src.allowed(user))
		if (src.density)
			open()
		else
			close()
	return

/obj/machinery/door/unpowered/shuttle
	icon = 'shuttle.dmi'
	name = "door"
	icon_state = "door1"
	opacity = 1
	density = 1
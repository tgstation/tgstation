//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/door
	name = "Door"
	desc = "It opens and closes."
	icon = 'doorint.dmi'
	icon_state = "door1"
	anchored = 1
	opacity = 1
	density = 1
	layer = 2.7

	var/secondsElectrified = 0
	var/visible = 1
	var/p_open = 0
	var/operating = 0
	var/autoclose = 0
	var/glass = 0
	var/normalspeed = 1

	proc/bumpopen(mob/user as mob)
	proc/update_nearby_tiles(need_rebuild)
	proc/requiresID()	return 1
	proc/animate(animation)
	proc/open()
	proc/close()

	New()
		..()
		if(density)
			layer = 3.1 //Above most items if closed
		else
			layer = 2.7 //Under all objects if opened. 2.7 due to tables being at 2.6
		update_nearby_tiles(need_rebuild=1)
		return


	Del()
		update_nearby_tiles()
		..()
		return

	//process()
		//return

	Bumped(atom/AM)
		if(p_open || operating) return
		if(ismob(AM))
			var/mob/M = AM
			if(world.time - M.last_bumped <= 60) return
			if(M.client && !M:handcuffed)
				bumpopen(M)
			return

		if(istype(AM, /obj/machinery/bot))
			var/obj/machinery/bot/bot = AM
			if(src.check_access(bot.botcard))
				if(density)
					open()
			return

		if(istype(AM, /obj/effect/critter))
			var/obj/effect/critter/critter = AM
			if(critter.opensdoors)	return
			if(src.check_access_list(critter.access_list))
				if(density)
					open()
			return

		if(istype(AM, /obj/mecha))
			var/obj/mecha/mecha = AM
			if(density)
				if(mecha.occupant && (src.allowed(mecha.occupant) || src.check_access_list(mecha.operation_req_access)))
					open()
				else
					flick("door_deny", src)
			return
		return


	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if(air_group) return 0
		if(istype(mover) && mover.checkpass(PASSGLASS))
			return !opacity
		return !density


	bumpopen(mob/user as mob)
		if(operating)	return
		src.add_fingerprint(user)
		if(!src.requiresID())
			user = null

		if(allowed(user) && density)
			open()
		else if(density)
			flick("door_deny", src)
		return

	meteorhit(obj/M as obj)
		src.open()
		return


	attack_ai(mob/user as mob)
		return src.attack_hand(user)


	attack_paw(mob/user as mob)
		return src.attack_hand(user)


	attack_hand(mob/user as mob)
		return src.attackby(user, user)


	attackby(obj/item/I as obj, mob/user as mob)
		if(src.operating || isrobot(user))	return //borgs can't attack doors open because it conflicts with their AI-like interaction with them.
		src.add_fingerprint(user)
		if(!src.requiresID())
			user = null
		if(src.density && (istype(I, /obj/item/weapon/card/emag)||istype(I, /obj/item/weapon/melee/energy/blade)))
			flick("door_spark", src)
			sleep(6)
			open()
			operating = -1
			return 1
		if(src.allowed(user))
			if(src.density)
				open()
			else
				close()
			return
		if(src.density)
			flick("door_deny", src)
		return


	blob_act()
		if(prob(40))
			del(src)
		return


	emp_act(severity)
		if(prob(20/severity) && (istype(src,/obj/machinery/door/airlock) || istype(src,/obj/machinery/door/window)) )
			open()
		if(prob(40/severity))
			if(secondsElectrified == 0)
				secondsElectrified = -1
				spawn(300)
					secondsElectrified = 0
		..()


	ex_act(severity)
		switch(severity)
			if(1.0)
				del(src)
			if(2.0)
				if(prob(25))
					del(src)
			if(3.0)
				if(prob(80))
					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
					s.set_up(2, 1, src)
					s.start()
		return


	update_icon()
		if(density)
			icon_state = "door1"
		else
			icon_state = "door0"
		return


	animate(animation)
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


	open()
		if(!density)	return 1
		if(operating > 0)	return
		if(!ticker)	return 0
		if(!operating)	operating = 1

		animate("opening")
		src.sd_SetOpacity(0)
		sleep(10)
		src.layer = 2.7
		src.density = 0
		update_icon()
		src.sd_SetOpacity(0)
		update_nearby_tiles()

		if(operating)	operating = 0

		if(autoclose  && normalspeed)
			spawn(150)
				autoclose()
		if(autoclose && !normalspeed)
			spawn(5)
				autoclose()

		return 1


	close()
		if(density)	return 1
		if(operating)	return
		operating = 1

		animate("closing")
		src.density = 1
		src.layer = 3.1
		sleep(10)
		update_icon()

		if(visible && !glass)
			src.sd_SetOpacity(1)
		operating = 0
		update_nearby_tiles()
		return


	update_nearby_tiles(need_rebuild)
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


/obj/machinery/door/proc/autoclose()
	var/obj/machinery/door/airlock/A = src
	if(!A.density && !A.operating && !A.locked && !A.welded && A.autoclose)
		close()
	return


/*
/obj/machinery/door/airlock/proc/ion_act()
	if(src.z == 1 && src.density)
		if(length(req_access) > 0 && !(12 in req_access))
			if(prob(4))
				world << "\red Airlock emagged in [src.loc.loc]"
				src.operating = -1
				flick("door_spark", src)
				sleep(6)
				open()
		else
			if(prob(8))
				world << "\red non vital Airlock emagged in [src.loc.loc]"
				src.operating = -1
				flick("door_spark", src)
				sleep(6)
				open()
	return

/obj/machinery/door/firedoor/proc/ion_act()
	if(src.z == 1)
		if(prob(15))
			if(density)
				open()
			else
				close()
	return
*/

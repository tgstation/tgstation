/obj/machinery/door
	name = "door"
	desc = "It opens and closes."
	icon = 'icons/obj/doors/Doorint.dmi'
	icon_state = "door1"
	anchored = 1
	opacity = 1
	density = 1
	layer = 2.7
	power_channel = ENVIRON

	var/secondsElectrified = 0
	var/visible = 1
	var/p_open = 0
	var/operating = 0
	var/glass = 0
	var/normalspeed = 1
	var/heat_proof = 0 // For plasteel-plated airlocks and firedoors
	var/emergency = 0 // Emergency access override
	var/sub_door = 0 // 1 if it's meant to go under another door.

/obj/machinery/door/New()
	..()
	if(density)
		layer = 3.1 //Above most items if closed
	else
		layer = 2.7 //Under all objects if opened. 2.7 due to tables being at 2.6
	update_freelook_sight()
	air_update_turf(1)
	airlocks += src
	return


/obj/machinery/door/Destroy()
	density = 0
	air_update_turf(1)
	update_freelook_sight()
	airlocks -= src
	..()
	return

//process()
	//return

/obj/machinery/door/Bumped(atom/AM)
	if(operating || emagged) return
	if(ismob(AM))
		var/mob/M = AM
		if(world.time - M.last_bumped <= 10) return	//Can bump-open one airlock per second. This is to prevent shock spam.
		M.last_bumped = world.time
		if(!M.restrained())
			bumpopen(M)
		return

	if(istype(AM, /obj/machinery/bot))
		var/obj/machinery/bot/bot = AM
		if(src.check_access(bot.botcard) || emergency == 1)
			if(density)
				open()
		return

	if(istype(AM, /obj/mecha))
		var/obj/mecha/mecha = AM
		if(density)
			if(mecha.occupant && (src.allowed(mecha.occupant) || src.check_access_list(mecha.operation_req_access) || emergency == 1))
				open()
			else
				flick("door_deny", src)
		return
	return

/obj/machinery/door/Move()
	var/turf/T = loc
	..()
	move_update_air(T)

/obj/machinery/door/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return !opacity
	return !density

/obj/machinery/door/CanAtmosPass()
	return !density

//used in the AStar algorithm to determinate if the turf the door is on is passable
/obj/machinery/door/proc/CanAStarPass(var/obj/item/weapon/card/id/ID)
	return !density

/obj/machinery/door/proc/bumpopen(mob/user as mob)
	if(operating)
		return
	src.add_fingerprint(user)
	if(!src.requiresID())
		user = null

	if(density && !emagged)
		if(allowed(user) || src.emergency == 1)
			open()
		else
			flick("door_deny", src)
	return


/obj/machinery/door/attack_ai(mob/user as mob)
	return src.attack_hand(user)


/obj/machinery/door/attack_paw(mob/user as mob)
	return src.attack_hand(user)


/obj/machinery/door/attack_hand(mob/user as mob)
	return src.attackby(user, user)


/obj/machinery/door/attack_tk(mob/user as mob)
	if(requiresID() && !allowed(null))
		return
	..()

/obj/machinery/door/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I, /obj/item/device/detective_scanner))
		return
	if(isrobot(user))	return //borgs can't attack doors open because it conflicts with their AI-like interaction with them.
	src.add_fingerprint(user)
	if(operating || emagged)	return
	if(!Adjacent(user))
		user = null
	if(!src.requiresID())
		user = null
	if(src.allowed(user) || src.emergency == 1)
		if(src.density)
			open()
		else
			close()
		return
	if(src.density)
		flick("door_deny", src)
	return

/obj/machinery/door/emag_act(mob/user as mob)
	if(density && hasPower() && !emagged)
		flick("door_spark", src)
		sleep(6)
		open()
		emagged = 1
		desc = "<span class='warning'>Its access panel is smoking slightly.</span>"
		if(istype(src, /obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/A = src
			A.lights = 0
			A.locked = 1
			A.loseMainPower()
			A.loseBackupPower()
			A.update_icon()

/obj/machinery/door/blob_act()
	if(prob(40))
		qdel(src)
	return


/obj/machinery/door/emp_act(severity)
	if(prob(20/severity) && (istype(src,/obj/machinery/door/airlock) || istype(src,/obj/machinery/door/window)) )
		open()
	if(prob(40/severity))
		if(secondsElectrified == 0)
			secondsElectrified = -1
			spawn(300)
				secondsElectrified = 0
	..()


/obj/machinery/door/ex_act(severity, target)
	if(severity == 3)
		if(prob(80))
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(2, 1, src)
			s.start()
		return
	..()

/obj/machinery/door/update_icon()
	if(density)
		icon_state = "door1"
	else
		icon_state = "door0"
	return


/obj/machinery/door/proc/do_animate(animation)
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
	if(operating)
		return
	if(!ticker)
		return 0
	operating = 1

	do_animate("opening")
	icon_state = "door0"
	src.SetOpacity(0)
	sleep(5)
	src.density = 0
	sleep(5)
	src.layer = 2.7
	update_icon()
	SetOpacity(0)
	operating = 0
	air_update_turf(1)
	update_freelook_sight()
	return 1


/obj/machinery/door/proc/close()
	if(density)
		return 1
	if(operating)
		return
	operating = 1

	do_animate("closing")
	src.layer = 3.1
	sleep(5)
	src.density = 1
	sleep(5)
	update_icon()
	if(visible && !glass)
		SetOpacity(1)
	operating = 0
	air_update_turf(1)
	update_freelook_sight()
	return

/obj/machinery/door/proc/crush()
	for(var/mob/living/L in get_turf(src))
		if(isalien(L))  //For xenos
			L.adjustBruteLoss(DOOR_CRUSH_DAMAGE * 1.5) //Xenos go into crit after aproximately the same amount of crushes as humans.
			L.emote("roar")
		else if(ishuman(L)) //For humans
			L.adjustBruteLoss(DOOR_CRUSH_DAMAGE)
			L.emote("scream")
			L.Weaken(5)
		else if(ismonkey(L)) //For monkeys
			L.adjustBruteLoss(DOOR_CRUSH_DAMAGE)
			L.Weaken(5)
		else //for simple_animals & borgs
			L.adjustBruteLoss(DOOR_CRUSH_DAMAGE)
		var/turf/location = src.loc
		if(istype(location, /turf/simulated)) //add_blood doesn't work for borgs/xenos, but add_blood_floor does.
			location.add_blood_floor(L)
	for(var/obj/mecha/M in get_turf(src))
		M.take_damage(DOOR_CRUSH_DAMAGE)

/obj/machinery/door/proc/requiresID()
	return 1

/obj/machinery/door/proc/hasPower()
	return !(stat & NOPOWER)

/obj/machinery/door/BlockSuperconductivity() // All non-glass airlocks block heat, this is intended.
	if(opacity || heat_proof)
		return 1
	return 0

/obj/machinery/door/morgue
	icon = 'icons/obj/doors/doormorgue.dmi'
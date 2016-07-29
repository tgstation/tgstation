<<<<<<< HEAD
/obj/machinery/door
	name = "door"
	desc = "It opens and closes."
	icon = 'icons/obj/doors/Doorint.dmi'
	icon_state = "door1"
	anchored = 1
	opacity = 1
	density = 1
	layer = OPEN_DOOR_LAYER
	power_channel = ENVIRON

	var/secondsElectrified = 0
	var/shockedby = list()
	var/visible = 1
	var/operating = 0
	var/glass = 0
	var/welded = 0
	var/normalspeed = 1
	var/heat_proof = 0 // For rglass-windowed airlocks and firedoors
	var/emergency = 0 // Emergency access override
	var/sub_door = 0 // 1 if it's meant to go under another door.
	var/closingLayer = CLOSED_DOOR_LAYER
	var/autoclose = 0 //does it automatically close after some time
	var/safe = 1 //whether the door detects things and mobs in its way and reopen or crushes them.
	var/locked = 0 //whether the door is bolted or not.
	var/assemblytype //the type of door frame to drop during deconstruction
	var/auto_close //TO BE REMOVED, no longer used, it's just preventing a runtime with a map var edit.

/obj/machinery/door/New()
	..()
	if(density)
		layer = CLOSED_DOOR_LAYER //Above most items if closed
	else
		layer = OPEN_DOOR_LAYER //Under all objects if opened. 2.7 due to tables being at 2.6
	update_freelook_sight()
	air_update_turf(1)
	airlocks += src
	return


/obj/machinery/door/Destroy()
	density = 0
	air_update_turf(1)
	update_freelook_sight()
	airlocks -= src
	return ..()

//process()
	//return

/obj/machinery/door/Bumped(atom/AM)
	if(operating || emagged) return
	if(isliving(AM))
		var/mob/living/M = AM
		if(world.time - M.last_bumped <= 10) return	//Can bump-open one airlock per second. This is to prevent shock spam.
		M.last_bumped = world.time
		if(!M.restrained())
			bumpopen(M)
		return

	if(istype(AM, /obj/mecha))
		var/obj/mecha/mecha = AM
		if(density)
			if(mecha.occupant)
				if(world.time - mecha.occupant.last_bumped <= 10)
					return
				mecha.occupant.last_bumped = world.time
			if(mecha.occupant && (src.allowed(mecha.occupant) || src.check_access_list(mecha.operation_req_access) || emergency == 1))
				open()
			else
				do_animate("deny")
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

/obj/machinery/door/proc/bumpopen(mob/user)
	if(operating)
		return
	src.add_fingerprint(user)
	if(!src.requiresID())
		user = null

	if(density && !emagged)
		if(allowed(user) || src.emergency == 1)
			open()
		else
			do_animate("deny")
	return


/obj/machinery/door/attack_ai(mob/user)
	return src.attack_hand(user)


/obj/machinery/door/attack_paw(mob/user)
	if(user.a_intent != "harm")
		return src.attack_hand(user)
	else
		attack_generic(user, 5)

/obj/machinery/door/proc/attack_generic(mob/user, damage = 0, damage_type = BRUTE)
	if(operating)
		return
	user.do_attack_animation(src)
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("<span class='danger'>[user] smashes against the [src.name]!</span>", \
				"<span class='userdanger'>You smash against the [src.name]!</span>")
	take_damage(damage, damage_type)

/obj/machinery/door/attack_slime(mob/living/simple_animal/slime/S)
	if(!S.is_adult)
		attack_generic(S, 0)
	else
		attack_generic(S, 25)

/obj/machinery/door/attack_hand(mob/user)
	return try_to_activate_door(user)


/obj/machinery/door/attack_tk(mob/user)
	if(requiresID() && !allowed(null))
		return
	..()

/obj/machinery/door/proc/try_to_activate_door(mob/user)
	add_fingerprint(user)
	if(operating || emagged)
		return
	if(!requiresID())
		user = null //so allowed(user) always succeeds
	if(allowed(user) || emergency == 1)
		if(density)
			open()
		else
			close()
		return
	if(density)
		do_animate("deny")

/obj/machinery/door/proc/try_to_weld(obj/item/weapon/weldingtool/W, mob/user)
	return

obj/machinery/door/proc/try_to_crowbar(obj/item/I, mob/user)
	return

/obj/machinery/door/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/crowbar) || istype(I, /obj/item/weapon/twohanded/fireaxe))
		try_to_crowbar(I, user)
		return 1
	else if(istype(I, /obj/item/weapon/weldingtool))
		try_to_weld(I, user)
		return 1
	else if(!(I.flags & NOBLUDGEON) && user.a_intent != "harm")
		try_to_activate_door(user)
		return 1
	else
		return ..()

/obj/machinery/door/take_damage(damage, damage_type = BRUTE, sound_effect = 1)
	switch(damage_type)
		if(BRUTE)
			if(sound_effect)
				if(glass)
					playsound(loc, 'sound/effects/Glasshit.ogg', 90, 1)
				else
					playsound(loc, 'sound/weapons/smash.ogg', 50, 1)
		if(BURN)
			if(sound_effect)
				playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)


/obj/machinery/door/blob_act(obj/effect/blob/B)
	if(prob(40))
		qdel(src)

/obj/machinery/door/emp_act(severity)
	if(prob(20/severity) && (istype(src,/obj/machinery/door/airlock) || istype(src,/obj/machinery/door/window)) )
		open()
	if(prob(40/severity))
		if(secondsElectrified == 0)
			secondsElectrified = -1
			shockedby += "\[[time_stamp()]\]EM Pulse"
			addtimer(src, "unelectrify", 300)
	..()

/obj/machinery/door/proc/unelectrify()
	secondsElectrified = 0

/obj/machinery/door/ex_act(severity, target)
	if(severity == 3)
		if(prob(80))
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(2, 1, src)
			s.start()
		return
	..()

/obj/machinery/door/update_icon()
	if(density)
		icon_state = "door1"
	else
		icon_state = "door0"

/obj/machinery/door/proc/do_animate(animation)
	switch(animation)
		if("opening")
			if(panel_open)
				flick("o_doorc0", src)
			else
				flick("doorc0", src)
		if("closing")
			if(panel_open)
				flick("o_doorc1", src)
			else
				flick("doorc1", src)
		if("deny")
			if(!stat)
				flick("door_deny", src)


/obj/machinery/door/proc/open()
	if(!density)
		return 1
	if(operating)
		return
	if(!ticker || !ticker.mode)
		return 0
	operating = 1
	do_animate("opening")
	SetOpacity(0)
	sleep(5)
	density = 0
	sleep(5)
	layer = OPEN_DOOR_LAYER
	update_icon()
	SetOpacity(0)
	operating = 0
	air_update_turf(1)
	update_freelook_sight()
	if(autoclose)
		spawn(autoclose)
			close()
	return 1

/obj/machinery/door/proc/close()
	if(density)
		return 1
	if(operating)
		return
	if(safe)
		for(var/atom/movable/M in get_turf(src))
			if(M.density && M != src) //something is blocking the door
				if(autoclose)
					addtimer(src, "autoclose", 60)
				return
	operating = 1

	do_animate("closing")
	layer = closingLayer
	sleep(5)
	density = 1
	sleep(5)
	update_icon()
	if(visible && !glass)
		SetOpacity(1)
	operating = 0
	air_update_turf(1)
	update_freelook_sight()
	if(safe)
		CheckForMobs()
	else
		crush()
	return 1

/obj/machinery/door/proc/CheckForMobs()
	if(locate(/mob/living) in get_turf(src))
		sleep(1)
		open()

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
		var/turf/location = get_turf(src)
		//add_blood doesn't work for borgs/xenos, but add_blood_floor does.
		L.add_splatter_floor(location)
	for(var/obj/mecha/M in get_turf(src))
		M.take_damage(DOOR_CRUSH_DAMAGE)

/obj/machinery/door/proc/autoclose()
	if(!qdeleted(src) && !density && !operating && !locked && !welded && autoclose)
		close()

/obj/machinery/door/proc/requiresID()
	return 1

/obj/machinery/door/proc/hasPower()
	return !(stat & NOPOWER)

/obj/machinery/door/proc/update_freelook_sight()
	if(!glass && cameranet)
		cameranet.updateVisibility(src, 0)

/obj/machinery/door/BlockSuperconductivity() // All non-glass airlocks block heat, this is intended.
	if(opacity || heat_proof)
		return 1
	return 0

/obj/machinery/door/morgue
	icon = 'icons/obj/doors/doormorgue.dmi'

/obj/machinery/door/storage_contents_dump_act(obj/item/weapon/storage/src_object, mob/user)
	return 0

/obj/machinery/door/proc/lock()
	return

/obj/machinery/door/proc/unlock()
	return

/obj/machinery/door/proc/hostile_lockdown(mob/origin)
	if(!stat) //So that only powered doors are closed.
		close() //Close ALL the doors!

/obj/machinery/door/proc/disable_lockdown()
	if(!stat) //Opens only powered doors.
		open() //Open everything!
=======
//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

#define BLOB_PROBABILITY 40
#define HEADBUTT_PROBABILITY 40
#define BRAINLOSS_FOR_HEADBUTT 60

#define DOOR_LAYER		2.7
#define DOOR_CLOSED_MOD	0.3 //how much the layer is increased when the door is closed

var/list/all_doors = list()
/obj/machinery/door
	name = "door"
	desc = "It opens and closes."
	icon = 'icons/obj/doors/door.dmi'
	icon_state = "door_closed"
	anchored = 1
	opacity = 1
	density = 1
	layer = DOOR_LAYER
	penetration_dampening = 10
	var/base_layer = DOOR_LAYER

	var/secondsElectrified = 0
	var/visible = 1
	var/operating = 0
	var/autoclose = 0
	var/glass = 0
	var/normalspeed = 1

	machine_flags = SCREWTOGGLE

	// for glass airlocks/opacity firedoors
	var/heat_proof = 0

	var/air_properties_vary_with_direction = 0

	// multi-tile doors
	dir = EAST
	var/width = 1

	// from old /vg/
	// the object that's jammed us open/closed
	var/obj/jammed = null

	// if the door has certain variation, like rapid (r_)
	var/prefix = null

	// TODO: refactor to best :(
	var/animation_delay = 12
	var/animation_delay_2 = null

	// turf animation
	var/atom/movable/overlay/c_animation = null

	var/soundeffect = 'sound/machines/airlock.ogg'

	var/explosion_block = 0 //regular airlocks are 1, blast doors are 3, higher values mean increasingly effective at blocking explosions.
	forceinvertredraw = 1

/obj/machinery/door/projectile_check()
	if(opacity)
		return PROJREACT_WALLS
	else
		return PROJREACT_WINDOWS

/obj/machinery/door/Bumped(atom/AM)
	if (ismob(AM))
		var/mob/M = AM

		if(!M.restrained() && (M.size > SIZE_TINY))
			bump_open(M)

		return

	if (istype(AM, /obj/machinery/bot))
		var/obj/machinery/bot/bot = AM

		if (check_access(bot.botcard) && !operating)
			open()

		return

	if (istype(AM, /obj/mecha))
		var/obj/mecha/mecha = AM

		if (density)
			if (mecha.occupant && !operating && (allowed(mecha.occupant) || check_access_list(mecha.operation_req_access)))
				open()
			else if(!operating)
				playsound(src.loc, 'sound/machines/denied.ogg', 50, 1)
				door_animate("deny")

	if (istype(AM, /obj/structure/bed/chair/vehicle))
		var/obj/structure/bed/chair/vehicle/vehicle = AM

		if (density)
			if (vehicle.locked_atoms.len && !operating && allowed(vehicle.locked_atoms[1]))
				if(istype(vehicle, /obj/structure/bed/chair/vehicle/wizmobile))
					vehicle.forceMove(get_step(vehicle,vehicle.dir))//Firebird doesn't wait for no slowpoke door to fully open before dashing through!
				open()
			else if(!operating)
				playsound(src.loc, 'sound/machines/denied.ogg', 50, 1)
				door_animate("deny")

/obj/machinery/door/proc/bump_open(mob/user as mob)
	// TODO: analyze this
	if(user.last_airflow > world.time - zas_settings.Get(/datum/ZAS_Setting/airflow_delay)) //Fakkit
		return

	add_fingerprint(user)

	if(!requiresID())
		user = null

	if(allowed(user))
		open()
	else if(!operating)
		playsound(src.loc, 'sound/machines/denied.ogg', 50, 1)
		door_animate("deny")

	return

/obj/machinery/door/attack_ai(mob/user as mob)
	add_hiddenprint(user)
	attack_hand(user)
	return

/obj/machinery/door/attack_paw(mob/user as mob)
	attack_hand(user)
	return

/obj/machinery/door/attack_hand(mob/user as mob)
	if (prob(HEADBUTT_PROBABILITY) && density && ishuman(user))
		var/mob/living/carbon/human/H = user

		if (H.getBrainLoss() >= BRAINLOSS_FOR_HEADBUTT)
			// TODO: analyze the called proc
			playsound(get_turf(src), 'sound/effects/bang.ogg', 25, 1)

			if (!istype(H.head, /obj/item/clothing/head/helmet))
				visible_message("<span class='warning'>[user] headbutts the airlock.</span>")
				H.Stun(8)
				H.Weaken(5)
				var/datum/organ/external/O = H.get_organ(LIMB_HEAD)

				// TODO: analyze the called proc
				if(O.take_damage(10, 0))
					H.UpdateDamageIcon()
					O = null
			else
				// TODO: fix sentence
				visible_message("<span class='warning'>[user] headbutts the airlock. Good thing they're wearing a helmet.</span>")

			H = null
			return

		H = null

	add_fingerprint(user)
	attackby(null, user)
	return


/obj/machinery/door/attackby(obj/item/I as obj, mob/user as mob)
	if(..())
		return 1

	if (istype(I, /obj/item/device/detective_scanner))
		return

	// borgs can't attack doors open
	// because it conflicts with their AI-like interaction with them
	if (isrobot(user))
		return

	if (!requiresID())
		user = null

	if (allowed(user))
		if (!density)
			return close()
		else
			return open()

	playsound(src.loc, 'sound/machines/denied.ogg', 50, 1)
	if(density) //Why are we playing a denied animation on an OPEN DOOR
		door_animate("deny")

/obj/machinery/door/blob_act()
	if(prob(BLOB_PROBABILITY))
		qdel(src)

/obj/machinery/door/proc/door_animate(var/animation as text)
	switch (animation)
		if ("opening")
			flick("[prefix]door_opening", src)
		if ("closing")
			flick("[prefix]door_closing", src)

	sleep(animation_delay)
	return

/obj/machinery/door/update_icon()
	if(!density)
		icon_state = "[prefix]door_open"
	else
		icon_state = "[prefix]door_closed"

	sleep(animation_delay_2)
	return

/*
/obj/machinery/door/proc/open()
	if (!density || operating || jammed)
		return

	operating = 1

	door_animate("opening")

	if (!istype(type, /obj/machinery/door/firedoor))
		layer = 2.7
	else
		layer = 2.6

	density = 0
	update_icon()
	opacity = 0

	// TODO: analyze this proc
	update_nearby_tiles()

	operating = 0

	// TODO: re-logic later
	if (autoclose && normalspeed)
		spawn(150)
			autoclose()
	else if (autoclose && !normalspeed)
		spawn(5)
			autoclose()

	return
*/

/obj/machinery/door/proc/open()
	if(!density)		return 1
	if(operating > 0)	return
	if(!ticker)			return 0
	if(!operating)		operating = 1

	door_animate("opening")
	src.set_opacity(0)
	sleep(10)
	src.layer = base_layer
	src.density = 0
	explosion_resistance = 0
	update_icon()
	set_opacity(0)
	update_nearby_tiles()
	//update_freelook_sight()

	if(operating == 1)
		operating = 0

	return 1

/obj/machinery/door/proc/autoclose()
	var/obj/machinery/door/airlock/A = src
	if(!A.density && !A.operating && !A.locked && !A.welded && A.autoclose && !A.jammed)
		close()
	return

/obj/machinery/door/proc/close()
	if (density || operating || jammed)
		return
	operating = 1
	door_animate("closing")

	layer = base_layer + DOOR_CLOSED_MOD

	density = 1
	update_icon()

	if (!glass)
		src.set_opacity(1)
		// Copypasta!!!
		var/obj/effect/beam/B = locate() in loc
		if(B)
			qdel(B)

	// TODO: rework how fire works on doors
	var/obj/fire/F = locate() in loc
	if(F)
		qdel(F)

	update_nearby_tiles()
	operating = 0

/obj/machinery/door/New()
	. = ..()
	all_doors += src

	if(density)
		// above most items if closed
		layer = base_layer + DOOR_CLOSED_MOD

		explosion_resistance = initial(explosion_resistance)
	else
		// under all objects if opened. 2.7 due to tables being at 2.6
		layer = base_layer

		explosion_resistance = 0

	if(width > 1)
		if(dir in list(EAST, WEST))
			bound_width = width * world.icon_size
			bound_height = world.icon_size
		else
			bound_width = world.icon_size
			bound_height = width * world.icon_size

	update_nearby_tiles()

/obj/machinery/door/cultify()
	if(invisibility != INVISIBILITY_MAXIMUM)
		invisibility = INVISIBILITY_MAXIMUM
		density = 0
		anim(target = src, a_icon = 'icons/effects/effects.dmi', a_icon_state = "breakdoor", sleeptime = 10)
		qdel(src)

/obj/machinery/door/Destroy()
	update_nearby_tiles()
	all_doors -= src
	..()

/obj/machinery/door/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group) return 0
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return !opacity
	return !density

/obj/machinery/door/proc/CanAStarPass(var/obj/item/weapon/card/id/ID)
	return !density || check_access(ID)


/obj/machinery/door/emp_act(severity)
	if(prob(20/severity) && (istype(src,/obj/machinery/door/airlock) || istype(src,/obj/machinery/door/window)) )
		open(6)
	if(prob(40/severity))
		if(secondsElectrified == 0)
			secondsElectrified = -1
			spawn(300)
				secondsElectrified = 0
	..()


/obj/machinery/door/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if(prob(25))
				qdel(src)
		if(3.0)
			if(prob(80))
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(2, 1, src)
				s.start()
	return

/obj/machinery/door/proc/requiresID()
	return 1

/obj/machinery/door/proc/update_nearby_tiles(var/turf/T)
	if(!air_master)
		return 0

	if(!T)
		T = get_turf(src)
	update_heat_protection(T)
	air_master.mark_for_update(T)

	update_freelok_sight()
	return 1

/obj/machinery/door/forceMove(var/atom/A)
	var/turf/T = loc
	..()
	update_nearby_tiles(T)
	update_nearby_tiles()

/obj/machinery/door/proc/update_heat_protection(var/turf/simulated/source)
	if(istype(source))
		if(src.density && (src.opacity || src.heat_proof))
			source.thermal_conductivity = DOOR_HEAT_TRANSFER_COEFFICIENT
		else
			source.thermal_conductivity = initial(source.thermal_conductivity)

/obj/machinery/door/change_area(oldarea, newarea)
	..()
	name = replacetext(name,oldarea,newarea)

/obj/machinery/door/Move(new_loc, new_dir)
	update_nearby_tiles()
	. = ..()
	if(width > 1)
		if(dir in list(EAST, WEST))
			bound_width = width * world.icon_size
			bound_height = world.icon_size
		else
			bound_width = world.icon_size
			bound_height = width * world.icon_size

	update_nearby_tiles()

/obj/machinery/door/morgue
	icon = 'icons/obj/doors/morgue.dmi'
	animation_delay = 15
	penetration_dampening = 15
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

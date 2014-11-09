//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

#define BLOB_PROBABILITY 40
#define HEADBUTT_PROBABILITY 40
#define BRAINLOSS_FOR_HEADBUTT 60

/obj/machinery/door
	name = "door"
	desc = "It opens and closes."
	icon = 'icons/obj/doors/door.dmi'
	icon_state = "door_closed"
	anchored = 1
	opacity = 1
	density = 1
	layer = 2.7

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

	// cultification animation
	var/atom/movable/overlay/c_animation = null

/obj/machinery/door/Bumped(atom/AM)
	if (ismob(AM))
		var/mob/M = AM

		// can bump open one airlock per second
		// this is to prevent shock spam
		if(world.time - M.last_bumped <= 10)
			return

		M.last_bumped = world.time

		if(!M.restrained() && !M.small)
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
			else
				door_animate("deny")

		return

	return

/obj/machinery/door/proc/bump_open(mob/user as mob)
	// TODO: analyze this
	if(user.last_airflow > world.time - zas_settings.Get(/datum/ZAS_Setting/airflow_delay)) //Fakkit
		return

	add_fingerprint(user)

	if(!requiresID())
		user = null

	if(allowed(user) && !operating)
		open()
	else
		door_animate("deny")

	return

/obj/machinery/door/meteorhit(obj/M as obj)
	open()
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
				visible_message("\red [user] headbutts the airlock.")
				H.Stun(8)
				H.Weaken(5)
				var/datum/organ/external/O = H.get_organ("head")

				// TODO: analyze the called proc
				if(O.take_damage(10, 0))
					H.UpdateDamageIcon()
					O = null
			else
				// TODO: fix sentence
				visible_message("\red [user] headbutts the airlock. Good thing they're wearing a helmet.")

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
			close()
		else
			open()

		return

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
	icon_state = "door0"
	src.SetOpacity(0)
	sleep(10)
	src.layer = 2.7
	src.density = 0
	explosion_resistance = 0
	update_icon()
	SetOpacity(0)
	update_nearby_tiles()
	//update_freelook_sight()

	if(operating)
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

	layer = 3.0

	density = 1
	update_icon()

	if (!glass)
		src.SetOpacity(1)

	// TODO: rework how fire works on doors
	var/obj/fire/F = locate() in loc
	if(F)
		qdel(F)

	update_nearby_tiles()
	operating = 0

/obj/machinery/door/New()
	. = ..()

	if(density)
		// above most items if closed
		layer = 3.1

		explosion_resistance = initial(explosion_resistance)
	else
		// under all objects if opened. 2.7 due to tables being at 2.6
		layer = 2.7

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
	icon_state = "null"
	density = 0
	c_animation = new /atom/movable/overlay(src.loc)
	c_animation.name = "cultification"
	c_animation.density = 0
	c_animation.anchored = 1
	c_animation.icon = 'icons/effects/effects.dmi'
	c_animation.layer = 5
	c_animation.master = src.loc
	c_animation.icon_state = "breakdoor"
	flick("cultification",c_animation)
	spawn(10)
		del(c_animation)
		qdel(src)

/obj/machinery/door/Destroy()
	update_nearby_tiles()
	..()

/obj/machinery/door/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group) return 0
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return !opacity
	return !density

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

/obj/machinery/door/proc/update_nearby_tiles()
	if(!air_master)
		return 0

	for(var/turf in locs)
		update_heat_protection(turf)
		air_master.mark_for_update(turf)

	update_freelok_sight()
	return 1

/obj/machinery/door/proc/update_heat_protection(var/turf/simulated/source)
	if(istype(source))
		if(src.density && (src.opacity || src.heat_proof))
			source.thermal_conductivity = DOOR_HEAT_TRANSFER_COEFFICIENT
		else
			source.thermal_conductivity = initial(source.thermal_conductivity)

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
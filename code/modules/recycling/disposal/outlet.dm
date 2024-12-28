//how fast disposal machinery is ejecting things and how far it goes
/// The slowest setting for disposal eject speed
#define EJECT_SPEED_SLOW 1
#define EJECT_RANGE_SLOW 2
/// The default setting for disposal eject speed
#define EJECT_SPEED_MED 2
#define EJECT_RANGE_MED 4
/// The fast setting for disposal eject speed
#define EJECT_SPEED_FAST 4
#define EJECT_RANGE_FAST 6
/// The fastest, emag exclusive setting for disposal eject speed
#define EJECT_SPEED_YEET 6
#define EJECT_RANGE_YEET 10

// the disposal outlet machine
/obj/structure/disposaloutlet
	name = "disposal outlet"
	desc = "An outlet for the pneumatic disposal system."
	icon = 'icons/obj/pipes_n_cables/disposal.dmi'
	icon_state = "outlet"
	density = TRUE
	anchored = TRUE
	var/active = FALSE
	var/turf/target // this will be where the output objects are 'thrown' to.
	var/obj/structure/disposalpipe/trunk/trunk // the attached pipe trunk
	var/obj/structure/disposalconstruct/stored
	var/start_eject = 0
	var/eject_range = EJECT_RANGE_SLOW
	/// how fast we're spitting fir- atoms
	var/eject_speed = EJECT_SPEED_SLOW

/obj/structure/disposaloutlet/Initialize(mapload, obj/structure/disposalconstruct/make_from)
	. = ..()
	if(make_from)
		setDir(make_from.dir)
		make_from.forceMove(src)
		stored = make_from
	else
		stored = new /obj/structure/disposalconstruct(src, null , SOUTH , FALSE , src)

	target = get_ranged_target_turf(src, dir, 10)

	var/obj/structure/disposalpipe/trunk/found_trunk = locate() in loc
	if(found_trunk)
		found_trunk.set_linked(src) // link the pipe trunk to self
		trunk = found_trunk

/obj/structure/disposaloutlet/Destroy()
	if(trunk)
		// preemptively expel the contents from the trunk
		// in case the outlet is deleted before expel_holder could be called.
		var/obj/structure/disposalholder/holder = locate() in trunk
		if(holder)
			trunk.expel(holder)
		trunk.linked = null
		trunk = null
	QDEL_NULL(stored)
	return ..()

// expel the contents of the holder object, then delete it
// called when the holder exits the outlet
/obj/structure/disposaloutlet/proc/expel(obj/structure/disposalholder/H)
	H.active = FALSE
	flick("outlet-open", src)
	if((start_eject + 30) < world.time)
		start_eject = world.time
		playsound(src, 'sound/machines/warning-buzzer.ogg', 50, FALSE, FALSE)
		addtimer(CALLBACK(src, PROC_REF(expel_holder), H, TRUE), 2 SECONDS)
	else
		addtimer(CALLBACK(src, PROC_REF(expel_holder), H), 2 SECONDS)

/obj/structure/disposaloutlet/proc/expel_holder(obj/structure/disposalholder/H, playsound=FALSE)
	if(playsound)
		playsound(src, 'sound/machines/hiss.ogg', 50, FALSE, FALSE)

	if(QDELETED(H))
		return

	pipe_eject(H, dir, TRUE, target, eject_range, eject_speed)

	H.vent_gas(loc)
	qdel(H)

/obj/structure/disposaloutlet/welder_act(mob/living/user, obj/item/I)
	..()
	if(!I.tool_start_check(user, amount=1, heat_required = HIGH_TEMPERATURE_REQUIRED))
		return TRUE

	playsound(src, 'sound/items/tools/welder2.ogg', 100, TRUE)
	to_chat(user, span_notice("You start slicing the floorweld off [src]..."))
	if(I.use_tool(src, user, 20))
		to_chat(user, span_notice("You slice the floorweld off [src]."))
		stored.forceMove(loc)
		transfer_fingerprints_to(stored)
		stored = null
		qdel(src)
	return TRUE

/obj/structure/disposaloutlet/examine(mob/user)
	. = ..()
	switch(eject_speed)
		if(EJECT_SPEED_SLOW)
			. += span_info("An LED image of a turtle is displayed on the side of the outlet.")
		if(EJECT_SPEED_MED)
			. += span_info("An LED image of a bumblebee is displayed on the side of the outlet.")
		if(EJECT_SPEED_FAST)
			. += span_info("An LED image of a speeding bullet is displayed on the side of the outlet.")
		if(EJECT_SPEED_YEET)
			. += span_info("An LED image of a grawlix is displayed on the side of the outlet.")

/obj/structure/disposaloutlet/multitool_act(mob/living/user, obj/item/I)
	. = ..()
//if emagged it cant change the speed setting off max
	if(obj_flags & EMAGGED)
		to_chat(user, span_notice("The LED display flashes an error!"))
	else
		to_chat(user, span_notice("You adjust the ejection force on \the [src]."))
		switch(eject_speed)
			if(EJECT_SPEED_SLOW)
				eject_speed = EJECT_SPEED_MED
				eject_range = EJECT_RANGE_MED
			if(EJECT_SPEED_MED)
				eject_speed = EJECT_SPEED_FAST
				eject_range = EJECT_RANGE_FAST
			else
				eject_speed = EJECT_SPEED_SLOW
				eject_range = EJECT_RANGE_SLOW
	return TRUE

/obj/structure/disposaloutlet/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(obj_flags & EMAGGED)
		return
	balloon_alert(user, "ejection force maximized")
	obj_flags |= EMAGGED
	eject_speed = EJECT_SPEED_YEET
	eject_range = EJECT_RANGE_YEET
	return TRUE

/obj/structure/disposaloutlet/force_pushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	. = ..()
	if(!isnull(stored))
		stored.forceMove(loc)
		transfer_fingerprints_to(stored)
		stored = null
		visible_message(span_warning("[src] is ripped free from the floor!"))
		qdel(src)

/obj/structure/disposaloutlet/move_crushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	. = ..()
	if(!isnull(stored))
		stored.forceMove(loc)
		transfer_fingerprints_to(stored)
		stored = null
		visible_message(span_warning("[src] is ripped free from the floor!"))
		qdel(src)

#undef EJECT_SPEED_SLOW
#undef EJECT_SPEED_MED
#undef EJECT_SPEED_FAST
#undef EJECT_SPEED_YEET
#undef EJECT_RANGE_SLOW
#undef EJECT_RANGE_MED
#undef EJECT_RANGE_FAST
#undef EJECT_RANGE_YEET

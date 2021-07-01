// the disposal outlet machine
/obj/structure/disposaloutlet
	name = "disposal outlet"
	desc = "An outlet for the pneumatic disposal system."
	icon = 'icons/obj/atmospherics/pipes/disposal.dmi'
	icon_state = "outlet"
	density = TRUE
	anchored = TRUE
	flags_1 = RAD_PROTECT_CONTENTS_1 | RAD_NO_CONTAMINATE_1
	var/active = FALSE
	var/turf/target // this will be where the output objects are 'thrown' to.
	var/obj/structure/disposalpipe/trunk/trunk // the attached pipe trunk
	var/obj/structure/disposalconstruct/stored
	var/start_eject = 0
	var/eject_range = 2
	/// how fast we're spitting fir- atoms
	var/eject_speed = EJECT_SPEED_MED

/obj/structure/disposaloutlet/Initialize(mapload, obj/structure/disposalconstruct/make_from)
	. = ..()
	if(make_from)
		setDir(make_from.dir)
		make_from.forceMove(src)
		stored = make_from
	else
		stored = new /obj/structure/disposalconstruct(src, null , SOUTH , FALSE , src)

	target = get_ranged_target_turf(src, dir, 10)

	trunk = locate() in loc
	if(trunk)
		trunk.linked = src // link the pipe trunk to self

/obj/structure/disposaloutlet/Destroy()
	if(trunk)
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
		addtimer(CALLBACK(src, .proc/expel_holder, H, TRUE), 20)
	else
		addtimer(CALLBACK(src, .proc/expel_holder, H), 20)

/obj/structure/disposaloutlet/proc/expel_holder(obj/structure/disposalholder/H, playsound=FALSE)
	if(playsound)
		playsound(src, 'sound/machines/hiss.ogg', 50, FALSE, FALSE)

	if(!H)
		return

	pipe_eject(H, dir, TRUE, target, eject_range, throw_range)

	H.vent_gas(loc)
	qdel(H)

/obj/structure/disposaloutlet/welder_act(mob/living/user, obj/item/I)
	..()
	if(!I.tool_start_check(user, amount=0))
		return TRUE

	playsound(src, 'sound/items/welder2.ogg', 100, TRUE)
	to_chat(user, "<span class='notice'>You start slicing the floorweld off [src]...</span>")
	if(I.use_tool(src, user, 20))
		to_chat(user, "<span class='notice'>You slice the floorweld off [src].</span>")
		stored.forceMove(loc)
		transfer_fingerprints_to(stored)
		stored = null
		qdel(src)
	return TRUE

/obj/structure/disposaloutlet/examine(mob/user)
	. = ..()
	switch(eject_speed)
		if(EJECT_SPEED_SLOW)
			. += "<span class='info'>An LED image of a turtle is displayed on the side of the outlet.</span>"
		if(EJECT_SPEED_MED)
			. += "<span class='info'>An LED image of a bumblebee is displayed on the side of the outlet.</span>"
		if(EJECT_SPEED_FAST)
			. += "<span class='info'>An LED image of a speeding bullet is displayed on the side of the outlet.</span>"
		if(EJECT_SPEED_YEET)
			. += "<span class='info'>An LED image of a grawlix is displayed on the side of the outlet.</span>"

/obj/structure/disposaloutlet/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	to_chat(user, "<span class='notice'>You adjust the ejection force on \the [src].</span>")
	switch(eject_speed)
		if(EJECT_SPEED_SLOW)
			eject_speed = EJECT_SPEED_MED
		if(EJECT_SPEED_MED)
			eject_speed = EJECT_SPEED_FAST
		if(EJECT_SPEED_FAST)
			if(obj_flags & EMAGGED)
				eject_speed = EJECT_SPEED_YEET
			else
				eject_speed = EJECT_SPEED_SLOW
		if(EJECT_SPEED_YEET)
			eject_speed = EJECT_SPEED_SLOW
	return TRUE

/obj/structure/disposaloutlet/emag_act(mob/user, obj/item/card/emag/E)
	. = ..()
	if(obj_flags & EMAGGED)
		return
	to_chat(user, "<span class='notice'>You silently disable the sanity checking on \the [src]'s ejection force.</span>")
	obj_flags |= EMAGGED

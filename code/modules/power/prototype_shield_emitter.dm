/obj/machinery/power/proto_sh_emitter
	name = "Prototype Shield Emitter"
	desc = "This is a Prototype Shield Emitter that create in front of it a box made of shielding elements to protect the station from heat and pressure"
	icon = 'icons/obj/power.dmi'
	icon_state = "proto_sh_emitter"
	anchored = FALSE
	density = TRUE
	max_integrity = 350
	integrity_failure = 0.2
	circuit = /obj/item/circuitboard/machine/proto_sh_emitter
	///Store the powered shields placed in the world, used when turned off to removed them
	var/list/signs
	///Check if the machine is turned on or off
	var/is_on = FALSE
	///Check if the machine is locked
	var/locked = FALSE

/obj/machinery/power/proto_sh_emitter/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation, ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_VERBS, null, CALLBACK(src, .proc/can_be_rotated))

/obj/machinery/power/proto_sh_emitter/anchored
	anchored = TRUE

/obj/machinery/power/proto_sh_emitter/small
	name = "Small Prototype Shield Emitter"
	desc = "This is the less powerful version of the P.S.E. designed to be used in the incinerator"
	circuit = /obj/item/circuitboard/machine/proto_sh_emitter_small

/obj/machinery/power/proto_sh_emitter/small/anchored
	anchored = TRUE

/obj/machinery/power/proto_sh_emitter/Destroy()
	if(SSticker.IsRoundInProgress())
		var/turf/T = get_turf(src)
		message_admins("Prototype Shield Emitter deleted at [ADMIN_VERBOSEJMP(T)]")
		log_game("Prototype Shield Emitter deleted at [AREACOORD(T)]")
	for(var/H in signs)
		qdel(H)
	return ..()

/obj/machinery/power/proto_sh_emitter/update_icon_state()
	if(is_on == TRUE)
		icon_state = "proto_sh_emitter_on"
	else
		icon_state = "proto_sh_emitter"

/obj/machinery/power/proto_sh_emitter/proc/can_be_rotated(mob/user,rotation_type)
	if(anchored)
		to_chat(user, "<span class='warning'>It is fastened to the floor!</span>")
		return FALSE
	return TRUE

/obj/machinery/power/proto_sh_emitter/wrench_act(mob/living/user, obj/item/I)
	if(is_on == TRUE)
		to_chat(user, "<span class='warning'>You have to turn the [src] off first!</span>")
		return TRUE
	if(!anchored)
		anchored = TRUE
		to_chat(user, "<span class='warning'>You bolt the [src] to the floor!</span>")
	else
		anchored = FALSE
		to_chat(user, "<span class='warning'>You unbolt the [src] from the floor!</span>")
	return TRUE

/obj/machinery/power/proto_sh_emitter/attackby(obj/item/I, mob/user, params)
	if(I.GetID())
		if(allowed(user))
			if(is_on)
				locked = !locked
				to_chat(user, "<span class='notice'>You [src.locked ? "lock" : "unlock"] the controls.</span>")
			else
				to_chat(user, "<span class='warning'>The controls can only be locked when \the [src] is online!</span>")
		else
			to_chat(user, "<span class='danger'>Access denied.</span>")
		return

/obj/machinery/power/proto_sh_emitter/crowbar_act(mob/living/user, obj/item/I)
	default_deconstruction_crowbar(I)
	return TRUE

/obj/machinery/power/proto_sh_emitter/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	default_deconstruction_screwdriver(user, "proto_sh_emitter-open", "proto_sh_emitter", I)
	return TRUE

/obj/machinery/power/proto_sh_emitter/process()
	var/area/a = get_area(src)
	var/turf/Turf = get_turf(src)
	if(a.power_equip == FALSE && is_on == TRUE)
		is_on = FALSE
		update_icon_state()
		message_admins("[src] turned off at [ADMIN_VERBOSEJMP(Turf)]")
		log_game("[src] turned off at [AREACOORD(Turf)]")

/obj/machinery/power/proto_sh_emitter/interact(mob/user)
	var/turf/EmitterTurf = get_turf(src)
	var/list/outline = list()
	var/list/internal = list()
	var/area/a = get_area(src)
	add_fingerprint(user)
	if(!anchored)
		to_chat(user, "<span class='warning'>You need to anchor the [src] first!</span>")
		return
	if(a.power_equip == FALSE)
		to_chat(user, "<span class='warning'>There is no power in this area!!</span>")
		return
	if(locked)
		to_chat(user, "<span class='warning'>The controls are locked!</span>")
		return
	if(is_on == TRUE)
		to_chat(user, "<span class='warning'>You start to turn off the [src] and the generated shields!</span>")
		if(do_after(user, 3.5 SECONDS, target = src))
			to_chat(user, "<span class='warning'>You turn off the [src] and the generated shields!</span>")
			message_admins("Prototype Shield Emitter turned off at [ADMIN_VERBOSEJMP(EmitterTurf)] by [ADMIN_LOOKUPFLW(user)]")
			log_game("Prototype Shield Emitter turned off at [AREACOORD(EmitterTurf)] by [key_name(user)]")
			is_on = FALSE
			for(var/h in signs)
				qdel(h)
			update_icon_state()
			return
	. = TRUE
	switch(dir) //Check for map limits.
		if(NORTH)
			if(!locate(x - 2, y + 5, z) || !locate(x + 2, y + 5, z))
				. = FALSE
		if(SOUTH)
			if(!locate(x - 2, y - 5, z) || !locate(x + 2, y - 5, z))
				. = FALSE
		if(EAST)
			if(!locate(x + 5, y -2, z) || !locate(x + 5, y + 2, z))
				. = FALSE
		if(WEST)
			if(!locate(x - 5, y - 2, z) || !locate(x - 5, y + 2, z))
				. = FALSE
	if(!.)
		to_chat(user, "<span class='warning'>The motors whir and fail!</span>")
		return
	to_chat(user, "<span class='warning'>You start to turn on the [src] and the generated shields!</span>")
	if(do_after(user, 1.5 SECONDS, target = src))
		to_chat(user, "<span class='warning'>You turn on the [src] and the generated shields!</span>")
		message_admins("Prototype Shield Emitter turned on at [ADMIN_VERBOSEJMP(EmitterTurf)] by [ADMIN_LOOKUPFLW(user)]")
		log_game("Prototype Shield Emitter turned on at [AREACOORD(EmitterTurf)] by [key_name(user)]")
		is_on = TRUE
		update_icon_state()
		switch(dir) //this part check the direction of the machine and create the block in front of it
			if(NORTH)
				internal = block(locate(src.x - 1, src.y + 2, src.z), locate(src.x + 1, src.y + 4, src.z))
				outline = block(locate(src.x - 2, src.y + 1, src.z), locate(src.x + 2, src.y + 5, src.z)) - internal
			if(SOUTH)
				internal = block(locate(src.x - 1, src.y - 2, src.z), locate(src.x + 1, src.y - 4, src.z))
				outline = block(locate(src.x - 2, src.y - 1, src.z), locate(src.x + 2, src.y - 5, src.z)) - internal
			if(EAST)
				internal = block(locate(src.x +2, src.y -1, src.z), locate(src.x +4, src.y +1, src.z))
				outline = block(locate(src.x +1, src.y -2, src.z), locate(src.x +5, src.y +2, src.z)) - internal
			if(WEST)
				internal = block(locate(src.x -2, src.y -1, src.z), locate(src.x -4, src.y +1, src.z))
				outline = block(locate(src.x -1, src.y -2, src.z), locate(src.x -5, src.y +2, src.z)) - internal
		for(var/turf in outline)
			new /obj/machinery/holosign/barrier/power_shield/wall(turf, src)
		for(var/turf in internal)
			new /obj/machinery/holosign/barrier/power_shield/floor(turf, src)

/obj/machinery/power/proto_sh_emitter/small/interact(mob/user)
	var/turf/EmitterTurf = get_turf(src)
	var/list/outline = list()
	var/list/internal = list()
	var/area/a = get_area(src)
	add_fingerprint(user)
	if(!anchored)
		to_chat(user, "<span class='warning'>You need to anchor the [src] first!</span>")
		return
	if(a.power_equip == FALSE)
		to_chat(user, "<span class='warning'>There is no power in this area!!</span>")
		return
	if(locked)
		to_chat(user, "<span class='warning'>The controls are locked!</span>")
		return
	if(is_on == TRUE)
		to_chat(user, "<span class='warning'>You start to turn off the [src] and the generated shields!</span>")
		if(do_after(user, 3.5 SECONDS, target = src))
			to_chat(user, "<span class='warning'>You turn off the [src] and the generated shields!</span>")
			message_admins("Small Prototype Shield Emitter turned off at [ADMIN_VERBOSEJMP(EmitterTurf)] by [ADMIN_LOOKUPFLW(user)]")
			log_game("Small Prototype Shield Emitter turned off at [AREACOORD(EmitterTurf)] by [key_name(user)]")
			is_on = FALSE
			for(var/h in signs)
				qdel(h)
			update_icon_state()
			return
	. = TRUE
	switch(dir) //Check for map limits.
		if(NORTH)
			if(!locate(x - 1, y + 4, z) || !locate(x + 3, y + 4, z))
				. = FALSE
		if(SOUTH)
			if(!locate(x - 3, y - 4, z) || !locate(x + 1, y - 4, z))
				. = FALSE
		if(EAST)
			if(!locate(x + 4, y -3, z) || !locate(x + 4, y + 1, z))
				. = FALSE
		if(WEST)
			if(!locate(x - 4, y - 1, z) || !locate(x - 4, y + 3, z))
				. = FALSE
	if(!.)
		to_chat(user, "<span class='warning'>The motors whir and fail!</span>")
		return
	to_chat(user, "<span class='warning'>You start to turn on the [src] and the generated shields!</span>")
	if(do_after(user, 1.5 SECONDS, target = src))
		to_chat(user, "<span class='warning'>You turn on the [src] and the generated shields!</span>")
		message_admins("Small Prototype Shield Emitter turned on at [ADMIN_VERBOSEJMP(EmitterTurf)] by [ADMIN_LOOKUPFLW(user)]")
		log_game("Small Prototype Shield Emitter turned on at [AREACOORD(EmitterTurf)] by [key_name(user)]")
		is_on = TRUE
		update_icon_state()
		switch(dir) //this part check the direction of the machine and create the block in front of it
			if(NORTH)
				internal = block(locate(src.x, src.y + 2, src.z), locate(src.x + 2, src.y + 3, src.z))
				outline = block(locate(src.x - 1, src.y + 1, src.z), locate(src.x + 3, src.y + 4, src.z)) - internal
			if(SOUTH)
				internal = block(locate(src.x - 2, src.y - 2, src.z), locate(src.x, src.y - 3, src.z))
				outline = block(locate(src.x - 3, src.y - 1, src.z), locate(src.x + 1, src.y - 4, src.z)) - internal
			if(EAST)
				internal = block(locate(src.x +2, src.y -2, src.z), locate(src.x +3, src.y, src.z))
				outline = block(locate(src.x +1, src.y -3, src.z), locate(src.x +4, src.y +1, src.z)) - internal
			if(WEST)
				internal = block(locate(src.x -2, src.y, src.z), locate(src.x -3, src.y +2, src.z))
				outline = block(locate(src.x -1, src.y -1, src.z), locate(src.x -4, src.y +3, src.z)) - internal
		for(var/turf in outline)
			new /obj/machinery/holosign/barrier/power_shield/wall(turf, src)
		for(var/turf in internal)
			new /obj/machinery/holosign/barrier/power_shield/floor(turf, src)

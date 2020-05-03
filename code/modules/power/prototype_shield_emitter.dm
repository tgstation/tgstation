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
	///Stores the outline of the room to generate
	var/list/outline
	///Stores the internal turfs of the room to generate
	var/list/internal
	///Used to check if the machine is placed inside the borders of the map
	var/borders = TRUE

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
		remove_barrier(user)
		return
	check_map_borders(2,5,2,5)
	if(!borders)
		to_chat(user, "<span class='warning'>The motors whir and fail!</span>")
		return
	build_barrier(1,2,1,4,2,1,2,5,user)

/obj/machinery/power/proto_sh_emitter/small/interact(mob/user)
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
		remove_barrier(user)
		return
	check_map_borders(1,4,3,4)
	if(!borders)
		to_chat(user, "<span class='warning'>The motors whir and fail!</span>")
		return
	build_barrier(0,2,2,3,1,1,3,4,user)

///Build the barriers
/obj/machinery/power/proto_sh_emitter/proc/build_barrier(A,B,C,D,E,F,G,H,user)
	var/turf/EmitterTurf = get_turf(src)
	to_chat(user, "<span class='warning'>You start to turn on the [src] and the generated shields!</span>")
	if(do_after(user, 1.5 SECONDS, target = src))
		to_chat(user, "<span class='warning'>You turn on the [src] and the generated shields!</span>")
		message_admins("[src] turned on at [ADMIN_VERBOSEJMP(EmitterTurf)] by [ADMIN_LOOKUPFLW(user)]")
		log_game("[src] turned on at [AREACOORD(EmitterTurf)] by [key_name(user)]")
		is_on = TRUE
		update_icon_state()
		switch(dir) //this part check the direction of the machine and create the block in front of it
			if(NORTH)
				LAZYADD(internal, block(locate(x - A, y + B, z), locate(x + C, y + D, z)))
				LAZYADD(outline, block(locate(x - E, y + F, z), locate(x + G, y + H, z)) - internal)
			if(SOUTH)
				LAZYADD(internal, block(locate(x - C, y - B, z), locate(x + A, y - D, z)))
				LAZYADD(outline, block(locate(x - G, y - F, z), locate(x + E, y - H, z)) - internal)
			if(EAST)
				LAZYADD(internal, block(locate(x + B, y - C, z), locate(x + D, y + A, z)))
				LAZYADD(outline, block(locate(x + F, y - G, z), locate(x + H, y + E, z)) - internal)
			if(WEST)
				LAZYADD(internal, block(locate(x - B, y - A, z), locate(x - D, y + C, z)))
				LAZYADD(outline, block(locate(x - F, y - E, z), locate(x - H, y + G, z)) - internal)
		for(var/turf in outline)
			new /obj/machinery/holosign/barrier/power_shield/wall(turf, src)
			LAZYREMOVE(outline, turf)
		for(var/turf in internal)
			new /obj/machinery/holosign/barrier/power_shield/floor(turf, src)
			LAZYREMOVE(internal, turf)

///Remove the barriers
/obj/machinery/power/proto_sh_emitter/proc/remove_barrier(user)
	var/turf/EmitterTurf = get_turf(src)
	to_chat(user, "<span class='warning'>You start to turn off the [src] and the generated shields!</span>")
	if(do_after(user, 3.5 SECONDS, target = src))
		to_chat(user, "<span class='warning'>You turn off the [src] and the generated shields!</span>")
		message_admins("[src] turned off at [ADMIN_VERBOSEJMP(EmitterTurf)] by [ADMIN_LOOKUPFLW(user)]")
		log_game("[src] turned off at [AREACOORD(EmitterTurf)] by [key_name(user)]")
		is_on = FALSE
		for(var/h in signs)
			qdel(h)
		update_icon_state()

///Check if the machine is generating the barriers inside the map borders
/obj/machinery/power/proto_sh_emitter/proc/check_map_borders(A,B,C,D)
	borders = TRUE
	switch(dir) //Check for map limits.
		if(NORTH)
			if(!locate(x - A, y + B, z) || !locate(x + C, y + D, z))
				borders = FALSE
		if(SOUTH)
			if(!locate(x - C, y - B, z) || !locate(x + A, y - D, z))
				borders = FALSE
		if(EAST)
			if(!locate(x + B, y -C, z) || !locate(x + D, y + A, z))
				borders = FALSE
		if(WEST)
			if(!locate(x - B, y - A, z) || !locate(x - D, y + C, z))
				borders = FALSE

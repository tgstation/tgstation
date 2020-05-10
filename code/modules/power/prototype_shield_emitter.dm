/obj/machinery/power/proto_sh_emitter
	name = "Prototype Shield Emitter"
	desc = "This is a Prototype Shield Emitter that create in front of it a box made of shielding elements to protect the station from heat and pressure"
	icon = 'icons/obj/power.dmi'
	icon_state = "proto_sh_emitter"
	anchored = FALSE
	density = TRUE
	max_integrity = 350
	integrity_failure = 0.2
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	circuit = /obj/item/circuitboard/machine/proto_sh_emitter
	///Store the powered shields placed in the world, used when turned off to removed them
	var/list/signs
	///Check if the machine is turned on or off
	var/is_on = FALSE
	///Check if the machine is locked
	var/locked = FALSE
	///Used to check if the machine is placed inside the borders of the map
	var/borders = TRUE
	///Check if the machine is the normal version or the small version
	var/normal = TRUE
	///Used to check the area power
	var/apc_power = TRUE

/obj/machinery/power/proto_sh_emitter/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation, ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_VERBS, null, CALLBACK(src, .proc/can_be_rotated))

/obj/machinery/power/proto_sh_emitter/anchored
	anchored = TRUE

/obj/machinery/power/proto_sh_emitter/small
	name = "Small Prototype Shield Emitter"
	desc = "This is the less powerful version of the P.S.E. designed to be used in the incinerator"
	circuit = /obj/item/circuitboard/machine/proto_sh_emitter_small
	normal = FALSE

/obj/machinery/power/proto_sh_emitter/small/anchored
	anchored = TRUE

/obj/machinery/power/proto_sh_emitter/Destroy()
	if(SSticker.IsRoundInProgress())
		var/turf/T = get_turf(src)
		message_admins("Prototype Shield Emitter deleted at [ADMIN_VERBOSEJMP(T)]")
		log_game("Prototype Shield Emitter deleted at [AREACOORD(T)]")
	QDEL_LIST(signs)
	return ..()

/obj/machinery/power/proto_sh_emitter/update_icon_state()
	if(is_on)
		icon_state = "proto_sh_emitter_on"
	else
		icon_state = "proto_sh_emitter"

/obj/machinery/power/proto_sh_emitter/proc/can_be_rotated(mob/user,rotation_type)
	if(anchored)
		to_chat(user, "<span class='warning'>It is fastened to the floor!</span>")
		return FALSE
	return TRUE

/obj/machinery/power/proto_sh_emitter/wrench_act(mob/living/user, obj/item/I)
	if(is_on)
		to_chat(user, "<span class='warning'>You have to turn the [src] off first!</span>")
		return TRUE
	anchored = !anchored
	if(anchored)
		to_chat(user, "<span class='warning'>You bolt the [src] to the floor!</span>")
	else
		to_chat(user, "<span class='warning'>You unbolt the [src] from the floor!</span>")
	return TRUE

/obj/machinery/power/proto_sh_emitter/attackby(obj/item/I, mob/user, params)
	if(I.GetID())
		if(allowed(user))
			if(is_on)
				locked = !locked
				to_chat(user, "<span class='notice'>You [locked ? "lock" : "unlock"] the controls.</span>")
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
	if(powered())
		apc_power = TRUE
		return
	if(!powered() && apc_power == TRUE)
		apc_power = FALSE
		var/turf/Turf = get_turf(src)
		is_on = FALSE
		QDEL_LIST(signs)
		update_icon_state()
		message_admins("[src] turned off at [ADMIN_VERBOSEJMP(Turf)]")
		log_game("[src] turned off at [AREACOORD(Turf)]")

/obj/machinery/power/proto_sh_emitter/interact(mob/user)
	add_fingerprint(user)
	if(!anchored)
		to_chat(user, "<span class='warning'>You need to anchor the [src] first!</span>")
		return
	if(!apc_power)
		to_chat(user, "<span class='warning'>There is no power in this area!!</span>")
		return
	if(locked)
		to_chat(user, "<span class='warning'>The controls are locked!</span>")
		return
	if(is_on)
		remove_barrier(user)
		return
	check_map_borders(2,5,2,5)
	if(!borders)
		to_chat(user, "<span class='warning'>The motors whir and fail!</span>")
		return
	if(normal)
		build_barrier(1,2,1,4,2,1,2,5,user)
	else
		build_barrier(0,2,2,3,1,1,3,4,user)

/** The vars you'll see in the proc() are referred to a mob looking north; NEx NEy refers to the North East corner x and y,
*all the other vars works in a similar way (N = North, S = South, E = East, W = West x = x axis, y = y axis, i = internal, o = outline). This way of naming the vars
*won't have much sense for the other directions, so always refer to the north direction when making changes as all other are already properly setup
*This proc builds the barriers
**/
/obj/machinery/power/proto_sh_emitter/proc/build_barrier(SWxi,SWyi,NExi,NEyi,SWxo,SWyo,NExo,NEyo,mob/user)
	///Stores the outline of the room to generate
	var/list/outline
	///Stores the internal turfs of the room to generate
	var/list/internal
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
				LAZYADD(internal, block(locate(x - SWxi, y + SWyi, z), locate(x + NExi, y + NEyi, z)))
				LAZYADD(outline, block(locate(x - SWxo, y + SWyo, z), locate(x + NExo, y + NEyo, z)) - internal)
			if(SOUTH)
				LAZYADD(internal, block(locate(x - NExi, y - SWyi, z), locate(x + SWxi, y - NEyi, z)))
				LAZYADD(outline, block(locate(x - NExo, y - SWyo, z), locate(x + SWxo, y - NEyo, z)) - internal)
			if(EAST)
				LAZYADD(internal, block(locate(x + SWyi, y - NExi, z), locate(x + NEyi, y + SWxi, z)))
				LAZYADD(outline, block(locate(x + SWyo, y - NExo, z), locate(x + NEyo, y + SWxo, z)) - internal)
			if(WEST)
				LAZYADD(internal, block(locate(x - SWyi, y - SWxi, z), locate(x - NEyi, y + NExi, z)))
				LAZYADD(outline, block(locate(x - SWyo, y - SWxo, z), locate(x - NEyo, y + NExo, z)) - internal)
		for(var/turf in outline)
			new /obj/machinery/holosign/barrier/power_shield/wall(turf, src)
			LAZYREMOVE(outline, turf)
		for(var/turf in internal)
			new /obj/machinery/holosign/barrier/power_shield/floor(turf, src)
			LAZYREMOVE(internal, turf)

///This proc removes the barriers
/obj/machinery/power/proto_sh_emitter/proc/remove_barrier(mob/user)
	var/turf/EmitterTurf = get_turf(src)
	to_chat(user, "<span class='warning'>You start to turn off the [src] and the generated shields!</span>")
	if(do_after(user, 3.5 SECONDS, target = src))
		to_chat(user, "<span class='warning'>You turn off the [src] and the generated shields!</span>")
		message_admins("[src] turned off at [ADMIN_VERBOSEJMP(EmitterTurf)] by [ADMIN_LOOKUPFLW(user)]")
		log_game("[src] turned off at [AREACOORD(EmitterTurf)] by [key_name(user)]")
		is_on = FALSE
		QDEL_LIST(signs)
		update_icon_state()
/** The vars you'll see in the proc() are referred to a mob looking north and they define a CORNER; NEx NEy refers to the North East CORNER x and y coordinates,
*all the other vars works in a similar way (N = North, S = South, E = East, W = West x = x axis, y = y axis). This way of naming the vars
*won't have much sense for the other directions, so always refer to the north direction when making changes as all other are already properly setup
*This proc check if the machine is generating the barriers inside the map borders
**/
/obj/machinery/power/proto_sh_emitter/proc/check_map_borders(NWx,NWy,NEx,NEy)
	borders = TRUE
	switch(dir) //Check for map limits.
		if(NORTH)
			if(!locate(x - NWx, y + NWy, z) || !locate(x + NEx, y + NEy, z))
				borders = FALSE
		if(SOUTH)
			if(!locate(x - NEx, y - NWy, z) || !locate(x + NWx, y - NEy, z))
				borders = FALSE
		if(EAST)
			if(!locate(x + NWy, y -NEx, z) || !locate(x + NEy, y + NWx, z))
				borders = FALSE
		if(WEST)
			if(!locate(x - NWy, y - NWx, z) || !locate(x - NEy, y + NEx, z))
				borders = FALSE

#define ENGINE_UNWRENCHED 0
#define ENGINE_WRENCHED 1
#define ENGINE_WELDED 2
#define ENGINE_WELDTIME 200

/obj/structure/shuttle
	name = "shuttle"
	icon = 'icons/turf/shuttle.dmi'
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	obj_integrity = 500
	max_integrity = 500
	armor = list(melee = 100, bullet = 10, laser = 10, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 70) //default + ignores melee

/obj/structure/shuttle/engine
	name = "engine"
	density = TRUE
	anchored = TRUE
	var/engine_power = 1
	var/state = ENGINE_WELDED //welding shmelding

//Ugh this is a lot of copypasta from emitters, welding need some boilerplate reduction
/obj/structure/shuttle/engine/can_be_unfasten_wrench(mob/user, silent)
	if(state == ENGINE_WELDED)
		if(!silent)
			to_chat(user, "<span class='warning'>[src] is welded to the floor!</span>")
		return FAILED_UNFASTEN
	return ..()

/obj/structure/shuttle/engine/default_unfasten_wrench(mob/user, obj/item/weapon/wrench/W, time = 20)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		if(anchored)
			state = ENGINE_WRENCHED
		else
			state = ENGINE_UNWRENCHED

/obj/structure/shuttle/engine/attackby(obj/item/I, mob/user, params)
	add_fingerprint(user)
	if(default_unfasten_wrench(user, I))
		return
	else if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = I
		switch(state)
			if(ENGINE_UNWRENCHED)
				to_chat(user, "<span class='warning'>The [src.name] needs to be wrenched to the floor!</span>")
			if(EM_SECURED)
				if(WT.remove_fuel(0,user))
					playsound(loc, WT.usesound, 50, 1)
					user.visible_message("[user.name] starts to weld the [name] to the floor.", \
						"<span class='notice'>You start to weld \the [src] to the floor...</span>", \
						"<span class='italics'>You hear welding.</span>")
					if(do_after(user,ENGINE_WELDTIME*WT.toolspeed, target = src) && WT.isOn())
						state = ENGINE_WELDED
						to_chat(user, "<span class='notice'>You weld \the [src] to the floor.</span>")
						alter_engine_power(engine_power)
			if(EM_WELDED)
				if(WT.remove_fuel(0,user))
					playsound(loc, WT.usesound, 50, 1)
					user.visible_message("[user.name] starts to cut the [name] free from the floor.", \
						"<span class='notice'>You start to cut \the [src] free from the floor...</span>", \
						"<span class='italics'>You hear welding.</span>")
					if(do_after(user,ENGINE_WELDTIME*WT.toolspeed, target = src) && WT.isOn())
						state = ENGINE_WRENCHED
						to_chat(user, "<span class='notice'>You cut \the [src] free from the floor.</span>")
						alter_engine_power(-engine_power)
		return
	else
		return ..()

/obj/structure/shuttle/engine/Destroy()
	if(state == ENGINE_WELDED)
		alter_engine_power(-engine_power)
	. = ..()

//Propagates the change to the shuttle.
/obj/structure/shuttle/engine/proc/alter_engine_power(mod)
	if(mod == 0)
		return
	if(SSshuttle.is_in_shuttle_bounds(src))
		var/obj/docking_port/mobile/M = SSshuttle.get_containing_shuttle(src)
		if(M)
			M.alter_engines(mod)

/obj/structure/shuttle/engine/heater
	name = "heater"
	icon_state = "heater"
	engine_power = 0 // todo make these into 2x1 parts

/obj/structure/shuttle/engine/platform
	name = "platform"
	icon_state = "platform"
	engine_power = 0

/obj/structure/shuttle/engine/propulsion
	name = "propulsion engine"
	icon_state = "propulsion"
	opacity = 1

/obj/structure/shuttle/engine/propulsion/left
	name = "left propulsion engine"
	icon_state = "propulsion_l"

/obj/structure/shuttle/engine/propulsion/right
	name = "right propulsion engine"
	icon_state = "propulsion_r"

/obj/structure/shuttle/engine/propulsion/burst
	name = "burst engine"

/obj/structure/shuttle/engine/propulsion/burst/cargo
	state = ENGINE_UNWRENCHED
	anchored = FALSE

/obj/structure/shuttle/engine/propulsion/burst/left
	name = "left burst engine"
	icon_state = "burst_l"

/obj/structure/shuttle/engine/propulsion/burst/right
	name = "right burst engine"
	icon_state = "burst_r"

/obj/structure/shuttle/engine/router
	name = "router"
	icon_state = "router"

/obj/structure/shuttle/engine/large
	name = "engine"
	opacity = 1
	icon = 'icons/obj/2x2.dmi'
	icon_state = "large_engine"
	bound_width = 64
	bound_height = 64
	appearance_flags = 0

/obj/structure/shuttle/engine/huge
	name = "engine"
	opacity = 1
	icon = 'icons/obj/3x3.dmi'
	icon_state = "huge_engine"
	bound_width = 96
	bound_height = 96
	appearance_flags = 0
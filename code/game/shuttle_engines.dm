/obj/structure/shuttle
	name = "shuttle"
	desc = "Part of a shuttle."
	icon = 'icons/turf/shuttle.dmi'
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/structure/shuttle/engine
	name = "engine"
	density = 1
	anchored = 1
	var/active = FALSE //Are we running?
	var/thrust = ENGINE_THRUST_OFF //Just how fast are we going?
	var/heat = 0 //How hot are we in Kelvin? See the engines file in __DEFINES for thresholds.
	var/heat_coefficient = 0 //At what rate do we gain heat? Set this to 0 for non-thruster machines.

/obj/structure/shuttle/engine/New()
	..()
	START_PROCESSING(SSprocessing, src)

/obj/structure/shuttle/engine/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/structure/shuttle/engine/process()
	if(active)
		if(broken)
			active = FALSE
			return
		adjust_heat(25)
		handle_heat()
	else
		adjust_heat(-1)

/obj/structure/shuttle/engine/examine(mob/user)
	..()
	user << "It's [active ? "on" : "off"]."
	switch(heat)
		if(ENGINE_TEMPERATURE_STABLE to ENGINE_TEMPERATURE_WARM)
			user << "<span class='warning'>It's giving off heat waves.</span>"
		if(ENGINE_TEMPERATURE_WARM to ENGINE_TEMPERATURE_MELTING)
			user << "<span class='boldwarning'>It's melting and glowing white-hot!</span>"

/obj/structure/shuttle/engine/proc/adjust_heat(heat_change)
	heat_change *= heat_coefficient
	heat = max(0, heat_change * thrust)

/obj/structure/shuttle/engine/proc/handle_heat()
	switch(heat)
		if(0 to ENGINE_TEMPERATURE_STABLE)
			color = rgb(255, 255, 255)
			playsound(src, 'sound/machines/engine_loop_normal.ogg', 50, 0)
		if(ENGINE_TEMPERATURE_STABLE to ENGINE_TEMPERATURE_WARM)
			color = rgb(255, 185, 185)
			playsound(src, 'sound/machines/engine_loop_warm.ogg', 50, 0)
		if(ENGINE_TEMPERATURE_WARM to ENGINE_TEMPERATURE_MELTING)
			color = rgb(255, 50, 50)
			playsound(src, 'sound/machines/engine_loop_melting.ogg', 50, 0)
		if(ENGINE_TEMPERATURE_EXPLODE to INFINITY)
			shake_the_room()

/obj/structure/shuttle/engine/proc/shake_the_room()
	visible_message("<span class='boldwarning'>[src] explodes!</span>")
	playsound(src, 'sound/machines/engine_explosion.ogg', 75, 1)
	explosion(src, 1, 3, 5, 7)
	qdel(src)

/obj/structure/shuttle/engine/can_be_unfasten_wrench(mob/living/user)
	if(heat >= ENGINE_TEMPERATURE_WARM)
		user << "<span class='boldwarning'>[src] sears your hand through your wrench!</span>"
		user.emote("scream")
		user.drop_item()
		user.adjustFireLoss(5)
		return 0
	return 1

/obj/structure/shuttle/engine/freon_gas_act()
	adjust_heat(-100) //Freon is very good at cooling us down!

/obj/structure/shuttle/engine/heater
	name = "heater"
	desc = "Provides heat and energy to thrusters."
	icon_state = "heater"
	heat_coefficient = 1

/obj/structure/shuttle/engine/platform
	name = "platform"
	icon_state = "platform"

/obj/structure/shuttle/engine/propulsion
	name = "propulsion"
	desc = "A heavy-duty engine used for faster-than-light travel. Don't stand on the business end."
	icon_state = "propulsion"
	opacity = 1
	heat_coefficient = 1

/obj/structure/shuttle/engine/propulsion/burst
	name = "burst"
	desc = "An even heavier-duty engine used for warp travel. Known for their tendency to vaporize anything behind it."
	heat_coefficient = 1.5

/obj/structure/shuttle/engine/propulsion/burst/left
	name = "left"
	icon_state = "burst_l"

/obj/structure/shuttle/engine/propulsion/burst/right
	name = "right"
	icon_state = "burst_r"

/obj/structure/shuttle/engine/router
	name = "router"
	desc = "A set of thick, heat-resistant tubes used to route heat and energy."
	icon_state = "router"

/obj/structure/shuttle/engine/large
	name = "engine"
	opacity = 1
	icon = 'icons/obj/2x2.dmi'
	icon_state = "large_engine"
	bound_width = 64
	bound_height = 64
	appearance_flags = 0

obj/structure/shuttle/engine/huge
	name = "engine"
	opacity = 1
	icon = 'icons/obj/3x3.dmi'
	icon_state = "huge_engine"
	bound_width = 96
	bound_height = 96
	appearance_flags = 0
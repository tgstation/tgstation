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
			return

/obj/structure/shuttle/engine/proc/shake_the_room()
	visible_message("<span class='boldwarning'>[src] explodes!</span>")
	playsound(src, 'sound/machines/engine_explosion.ogg', 75, 1)
	explosion(src, 1, 3, 5, 7)
	qdel(src)

/obj/structure/shuttle/engine/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/weapon/wrench))
		if(heat > ENGINE_TEMPERATURE_MELTING)
			user << "<span class='warning'>[src] sears your hand as you try to unfasten it!</span>" //Hot enough to go through gloves, of course. It's over 1000 degrees warm.
			user.drop_item()
			user.emote("scream")
			return
		user.visible_message("<span class='notice'>[user] starts unfastening [src]...</span>", "<span class='notice'>You start unfastening [src]...</span>")
		playsound(src, 'sound/items/Ratchet.ogg', 50, 0)
		if(!do_after(user, 50, src) || !anchored)
			return
		user.visible_message("<span class='notice'>[user] unfastens [src] from the ground!</span>", "<span class='notice'>You undo [src]'s bolts.</span>")
		anchored = FALSE
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 0)
		return
	..()

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

/obj/machinery/igniter
	name = "igniter"
	desc = "It's useful for igniting plasma."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "igniter0"
	plane = FLOOR_PLANE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4
	max_integrity = 300
	armor = list("melee" = 50, "bullet" = 30, "laser" = 70, "energy" = 50, "bomb" = 20, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 70)
	resistance_flags = FIRE_PROOF
	var/id = null
	var/on = FALSE

/obj/machinery/igniter/incinerator_toxmix
	id = INCINERATOR_TOXMIX_IGNITER

/obj/machinery/igniter/incinerator_atmos
	id = INCINERATOR_ATMOS_IGNITER

/obj/machinery/igniter/incinerator_syndicatelava
	id = INCINERATOR_SYNDICATELAVA_IGNITER

/obj/machinery/igniter/on
	on = TRUE
	icon_state = "igniter1"

/obj/machinery/igniter/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	add_fingerprint(user)

	use_power(50)
	on = !( on )
	icon_state = "igniter[on]"

/obj/machinery/igniter/process()	//ugh why is this even in process()?
	if (src.on && !(stat & NOPOWER) )
		var/turf/location = src.loc
		if (isturf(location))
			location.hotspot_expose(700,10,1)
	return 1

/obj/machinery/igniter/Initialize()
	. = ..()
	icon_state = "igniter[on]"

/obj/machinery/igniter/power_change()
	if(!( stat & NOPOWER) )
		icon_state = "igniter[src.on]"
	else
		icon_state = "igniter0"

// Wall mounted remote-control igniter.

/obj/machinery/sparker
	name = "mounted igniter"
	desc = "A wall-mounted ignition device."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "migniter"
	resistance_flags = FIRE_PROOF
	var/id = null
	var/disable = 0
	var/last_spark = 0
	var/base_state = "migniter"
	var/datum/effect_system/spark_spread/spark_system

/obj/machinery/sparker/toxmix
	id = INCINERATOR_TOXMIX_IGNITER

/obj/machinery/sparker/Initialize()
	. = ..()
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(2, 1, src)
	spark_system.attach(src)

/obj/machinery/sparker/Destroy()
	QDEL_NULL(spark_system)
	return ..()

/obj/machinery/sparker/power_change()
	if ( powered() && disable == 0 )
		stat &= ~NOPOWER
		icon_state = "[base_state]"
//		src.sd_SetLuminosity(2)
	else
		stat |= ~NOPOWER
		icon_state = "[base_state]-p"
//		src.sd_SetLuminosity(0)

/obj/machinery/sparker/attackby(obj/item/W, mob/user, params)
	if (W.tool_behaviour == TOOL_SCREWDRIVER)
		add_fingerprint(user)
		src.disable = !src.disable
		if (src.disable)
			user.visible_message("[user] has disabled \the [src]!", "<span class='notice'>You disable the connection to \the [src].</span>")
			icon_state = "[base_state]-d"
		if (!src.disable)
			user.visible_message("[user] has reconnected \the [src]!", "<span class='notice'>You fix the connection to \the [src].</span>")
			if(src.powered())
				icon_state = "[base_state]"
			else
				icon_state = "[base_state]-p"
	else
		return ..()

/obj/machinery/sparker/attack_ai()
	if (anchored)
		return src.ignite()
	else
		return

/obj/machinery/sparker/proc/ignite()
	if (!(powered()))
		return

	if ((src.disable) || (src.last_spark && world.time < src.last_spark + 50))
		return


	flick("[base_state]-spark", src)
	spark_system.start()
	last_spark = world.time
	use_power(1000)
	var/turf/location = src.loc
	if (isturf(location))
		location.hotspot_expose(1000,2500,1)
	return 1

/obj/machinery/sparker/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(!(stat & (BROKEN|NOPOWER)))
		ignite()

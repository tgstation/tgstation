/obj/machinery/igniter
	name = "igniter"
	desc = "It's useful for igniting plasma."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "igniter0"
	base_icon_state = "igniter"
	plane = FLOOR_PLANE
	max_integrity = 300
	armor_type = /datum/armor/machinery_igniter
	resistance_flags = FIRE_PROOF
	var/id = null
	var/on = FALSE

/obj/machinery/igniter/incinerator_ordmix
	id = INCINERATOR_ORDMIX_IGNITER

/obj/machinery/igniter/incinerator_atmos
	id = INCINERATOR_ATMOS_IGNITER

/obj/machinery/igniter/incinerator_syndicatelava
	id = INCINERATOR_SYNDICATELAVA_IGNITER

/obj/machinery/igniter/on
	on = TRUE
	icon_state = "igniter1"

/datum/armor/machinery_igniter
	melee = 50
	bullet = 30
	laser = 70
	energy = 50
	bomb = 20
	fire = 100
	acid = 70

/obj/machinery/igniter/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	add_fingerprint(user)

	use_power(active_power_usage)
	on = !( on )
	update_appearance()

/obj/machinery/igniter/process() //ugh why is this even in process()?
	if (on && !(machine_stat & NOPOWER) )
		var/turf/location = loc
		if (isturf(location))
			location.hotspot_expose(1000,500,1)
	return 1

/obj/machinery/igniter/Initialize(mapload)
	. = ..()
	icon_state = "igniter[on]"

/obj/machinery/igniter/update_icon_state()
	icon_state = "[base_icon_state][(machine_stat & NOPOWER) ? 0 : on]"
	return ..()

/obj/machinery/igniter/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	id = "[port.shuttle_id]_[id]"

// Wall mounted remote-control igniter.

/obj/machinery/sparker
	name = "mounted igniter"
	desc = "A wall-mounted ignition device."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "migniter"
	base_icon_state = "migniter"
	resistance_flags = FIRE_PROOF
	var/id = null
	var/disable = 0
	var/last_spark = 0
	var/datum/effect_system/spark_spread/spark_system

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/sparker, 26)

/obj/machinery/sparker/ordmix
	id = INCINERATOR_ORDMIX_IGNITER

/obj/machinery/sparker/Initialize(mapload)
	. = ..()
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(2, 1, src)
	spark_system.attach(src)

/obj/machinery/sparker/Destroy()
	QDEL_NULL(spark_system)
	return ..()

/obj/machinery/sparker/update_icon_state()
	if(disable)
		icon_state = "[base_icon_state]-d"
		return ..()
	icon_state = "[base_icon_state][powered() ? null : "-p"]"
	return ..()

/obj/machinery/sparker/powered()
	if(disable)
		return FALSE
	return ..()

/obj/machinery/sparker/screwdriver_act(mob/living/user, obj/item/tool)
	add_fingerprint(user)
	tool.play_tool_sound(src, 50)
	disable = !disable
	if (disable)
		user.visible_message(span_notice("[user] disables \the [src]!"), span_notice("You disable the connection to \the [src]."))
	if (!disable)
		user.visible_message(span_notice("[user] reconnects \the [src]!"), span_notice("You fix the connection to \the [src]."))
	update_appearance()
	return TRUE

/obj/machinery/sparker/attack_ai()
	if (anchored)
		return ignite()
	else
		return

/obj/machinery/sparker/proc/ignite()
	if (!(powered()))
		return

	if ((disable) || (last_spark && world.time < last_spark + 50))
		return


	flick("[initial(icon_state)]-spark", src)
	spark_system.start()
	last_spark = world.time
	use_power(active_power_usage)
	var/turf/location = loc
	if (isturf(location))
		location.hotspot_expose(1000,2500,1)
	return 1

/obj/machinery/sparker/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(!(machine_stat & (BROKEN|NOPOWER)))
		ignite()

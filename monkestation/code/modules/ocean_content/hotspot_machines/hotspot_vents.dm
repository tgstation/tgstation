/obj/machinery/power/vent
	name = "steam capturing unit"
	desc = "A piece of machinery that converts magmatic activity to electricity"

	icon = 'goon/icons/obj/large/32x48.dmi'
	icon_state = "hydrovent_1"
	base_icon_state = "hydrovent"

	density = TRUE
	anchored = TRUE

	///the amount of generation we have made in our lifespan
	var/total_generation = 0
	///the amount of electricty we generated before
	var/last_generation = 0

	///are we setup
	var/setup = FALSE

/obj/machinery/power/vent/Initialize(mapload)
	. = ..()
	if(istype(src.loc, /turf/open/floor/plating/ocean))
		var/turf/open/floor/plating/ocean/location = src.loc
		location.captured = TRUE
		update_state(src.loc)

/obj/machinery/power/vent/proc/update_state()
	if(!isturf(loc))
		return
	var/datum/hotspot/found_hotspot = SShotspots.retrieve_hotspot(src.loc)
	if(!found_hotspot)
		return
	found_hotspot.calculate_vent_count(found_hotspot.center.return_turf())

/obj/machinery/power/vent/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!setup)
		if(!do_after(user, 2 SECONDS, src))
			return TOOL_ACT_TOOLTYPE_SUCCESS
		if(!connect_to_network())
			to_chat(user, "You fail to turn on the [src] as it lacks a connection to the powergrid.")
			return TOOL_ACT_TOOLTYPE_SUCCESS
		to_chat(user, "You pry the [src] up turning it on.")
		setup = TRUE
		update_appearance()
		return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/power/vent/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!do_after(user, 5 SECONDS, src))
		return TOOL_ACT_TOOLTYPE_SUCCESS
	to_chat(user, "You dissassemble the [src].")
	disassemble()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/power/vent/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(istype(W, /obj/item/stack/cable_coil))
		var/turf/turf = get_turf(src)
		turf.attackby(W)

/obj/machinery/power/vent/examine(mob/user)
	. = ..()
	. += "Current Output: [display_power(last_generation)]"
	. += "Lifetime Output: [display_power(total_generation)]"

/obj/machinery/power/vent/update_icon_state()
	. = ..()
	icon_state = "hydrovent_[setup]"

/obj/machinery/power/vent/process()
	if(!setup)
		return
	if(!isturf(src.loc))
		return

	var/generation = 200 * SShotspots.return_heat(src.loc)
	if(generation <= 0)
		return
	add_avail(generation)
	last_generation = generation
	total_generation += generation

/obj/machinery/power/vent/proc/disassemble()
	disconnect_from_network()
	setup = FALSE
	var/turf/open/floor/plating/ocean/turf = get_turf(src)
	turf.captured = FALSE
	STOP_PROCESSING(SSmachines, src)
	var/obj/item/vent_package/new_package = new(turf)
	new_package.stored_total = total_generation
	qdel(src)

/obj/item/vent_package
	name = "unbuilt steam capturing unit"
	desc = "A portable form of the steam capturing unit."

	icon = 'goon/icons/obj/sealab_power.dmi'
	icon_state = "hydrovent_unbuilt"

	///the cached amount of total generation so we can move em around and brag about power
	var/stored_total = 0

/obj/item/vent_package/proc/deploy(turf/open/floor/plating/ocean/location)
	var/obj/machinery/power/vent/new_vent = new(location)
	new_vent.total_generation = stored_total
	qdel(src)

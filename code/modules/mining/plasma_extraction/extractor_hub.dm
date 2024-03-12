/**
 * Base plasma extraction machine
 */
/obj/structure/plasma_extraction_hub
	name = "plasma extraction hub"
	desc = "The hub to a connection of pipes. If there aren't any, then get building!"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "ore_redemption"
	anchored = TRUE
	density = TRUE

/**
 * Base plasma extraction machine part
 * All parts that don't have a pipe, use this.
 */
/obj/structure/plasma_extraction_hub/part
	var/obj/structure/plasma_extraction_hub/part/pipe/main_machine

/obj/structure/plasma_extraction_hub/part/proc/on_update_icon(obj/machinery/gravity_generator/source, updates, updated)
	SIGNAL_HANDLER
	return update_appearance(updates)

/**
 * Plasma extraction machine pipe
 * There's 3 of these on each plasma extraction machine, one of which is the owner of the rest.
 */
/obj/structure/plasma_extraction_hub/part/pipe
	name = "starting pipe location"

/obj/structure/plasma_extraction_hub/part/pipe/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/pipe_laying)

/obj/structure/plasma_extraction_hub/part/pipe/east
	dir = EAST

/obj/structure/plasma_extraction_hub/part/pipe/west
	dir = WEST

/**
 * Main plasma extraction machine
 * This 'Owns' all the rest, while also acting like a pipe part in its own right.
 */
/obj/structure/plasma_extraction_hub/part/pipe/main
	///List of all parts connected to the extraction hub.
	var/list/obj/structure/plasma_extraction_hub/hub_parts = list()

/obj/structure/plasma_extraction_hub/part/pipe/main/Initialize(mapload)
	. = ..()
	//the only one that calls setup, as the creator
	setup_parts()

///Copied over from Gravity Generator, this sets up the parts of the plasma extraction hub, and its
///3 pipe starting points.
/obj/structure/plasma_extraction_hub/part/pipe/main/proc/setup_parts()
	var/turf/our_turf = get_turf(src)
	// 9x9 block obtained from the bottom middle of the block
	var/list/spawn_turfs = CORNER_BLOCK_OFFSET(our_turf, 3, 3, -1, 0)
	var/count = 10
	for(var/turf/T in spawn_turfs)
		count--
		if(T == our_turf) // Skip our turf.
			continue
		var/obj/structure/plasma_extraction_hub/part/new_part
		switch(count)
			//east
			if(4)
				new_part = new /obj/structure/plasma_extraction_hub/part/pipe/east(T)
			//west
			if(6)
				new_part = new /obj/structure/plasma_extraction_hub/part/pipe/west(T)
			else
				new_part = new/obj/structure/plasma_extraction_hub/part(T)
		hub_parts += new_part
		new_part.main_machine = src
		new_part.update_appearance()
		new_part.RegisterSignal(src, COMSIG_ATOM_UPDATED_ICON, TYPE_PROC_REF(/obj/structure/plasma_extraction_hub/part, on_update_icon))

/obj/structure/plasma_extraction_hub/part/pipe/main/Destroy()
	. = ..()
	QDEL_LIST(hub_parts)

/obj/structure/plasma_extraction_hub/part/pipe/main/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	to_chat(user, "Interacted with [src]")

/**********************Unloading unit**************************/


/obj/machinery/mineral/unloading_machine
	name = "unloading machine"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "unloader"
	density = TRUE
	input_dir = WEST
	output_dir = EAST
	needs_item_input = TRUE
	processing_flags = START_PROCESSING_MANUALLY

/obj/machinery/mineral/unloading_machine/pickup_item(datum/source, atom/movable/target, atom/oldLoc)
	if(QDELETED(target))
		return
	if(istype(target, /obj/structure/ore_box))
		var/obj/structure/ore_box/box = target
		for(var/obj/item/stack/ore/O in box)
			unload_mineral(O)
	else if(istype(target, /obj/item/stack/ore))
		var/obj/item/stack/ore/O = target
		unload_mineral(O)

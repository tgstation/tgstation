/**********************Unloading unit**************************/


/obj/machinery/mineral/unloading_machine
	name = "unloading machine"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "unloader"
	density = 1
	anchored = 1.0
	input_dir = WEST
	output_dir = EAST

/obj/machinery/mineral/unloading_machine/process()
	var/turf/T = get_step(src,input_dir)
	if(T)
		var/limit
		for(var/obj/structure/ore_box/B in T)
			for (var/obj/item/weapon/ore/O in B)
				B.contents -= O
				unload_mineral(O)
				limit++
				if (limit>=10)
					return
		for(var/obj/item/I in T)
			unload_mineral(I)
			limit++
			if (limit>=10)
				return
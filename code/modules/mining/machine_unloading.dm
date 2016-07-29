<<<<<<< HEAD
/**********************Unloading unit**************************/


/obj/machinery/mineral/unloading_machine
	name = "unloading machine"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "unloader"
	density = 1
	anchored = 1
	input_dir = WEST
	output_dir = EAST
	speed_process = 1

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
				CHECK_TICK
			CHECK_TICK
		for(var/obj/item/I in T)
			unload_mineral(I)
			limit++
			if (limit>=10)
				return
			CHECK_TICK
=======
/**********************Unloading unit**************************/


/obj/machinery/mineral/unloading_machine
	name = "unloading machine"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "unloader"
	density = 1
	anchored = 1.0
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null


/obj/machinery/mineral/unloading_machine/New()
	..()
	spawn( 5 )
		for (var/dir in cardinal)
			src.input = locate(/obj/machinery/mineral/input, get_step(src, dir))
			if(src.input) break
		for (var/dir in cardinal)
			src.output = locate(/obj/machinery/mineral/output, get_step(src, dir))
			if(src.output) break
		return
	return

/obj/machinery/mineral/unloading_machine/process()
	if (src.output && src.input)
		if (locate(/obj/structure/ore_box, input.loc))
			var/obj/structure/ore_box/BOX = locate(/obj/structure/ore_box, input.loc)
			var/p = 0
			for(var/ore_id in BOX.materials.storage)
				var/datum/material/mat = BOX.materials.getMaterial(ore_id)
				var/n=BOX.materials.storage[ore_id]
				if(n<=0 || !mat.oretype) continue
				for(var/i=0;i<n;i++)
					new mat.oretype(get_turf(output))
					BOX.materials.storage[ore_id]--
					p++
					if (p>=100)
						return
		if (locate(/obj/item, input.loc))
			var/obj/item/O
			var/i
			for (i = 0; i<100; i++)
				O = locate(/obj/item, input.loc)
				if (O)
					O.loc = src.output.loc
				else
					return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

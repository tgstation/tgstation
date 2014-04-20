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
				var/n=mat.stored
				if(n<=0 || !mat.oretype) continue
				for(var/i=0;i<n;i++)
					new mat.oretype(get_turf(output))
					mat.stored-=1
					p++
					if (p>=10)
						return
		if (locate(/obj/item, input.loc))
			var/obj/item/O
			var/i
			for (i = 0; i<10; i++)
				O = locate(/obj/item, input.loc)
				if (O)
					O.loc = src.output.loc
				else
					return
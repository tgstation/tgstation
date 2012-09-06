/**********************Unloading unit**************************/


/obj/machinery/mineral/unloading_machine
	name = "unloading machine"
	icon = 'mining_machines.dmi'
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
			BOX.update()
			if (BOX.amt_diamond > 0)
				var/obj/item/weapon/ore/diamond/G = new /obj/item/weapon/ore/diamond
				G.amount = BOX.amt_diamond
				G.loc = output.loc
				BOX.amt_diamond = 0
			if (BOX.amt_glass > 0)
				var/obj/item/weapon/ore/glass/G = new /obj/item/weapon/ore/glass
				G.amount = BOX.amt_glass
				G.loc = output.loc
				BOX.amt_glass = 0
			if (BOX.amt_plasma > 0)
				var/obj/item/weapon/ore/plasma/G = new /obj/item/weapon/ore/plasma
				G.amount = BOX.amt_plasma
				G.loc = output.loc
				BOX.amt_plasma = 0
			if (BOX.amt_iron > 0)
				var/obj/item/weapon/ore/iron/G = new /obj/item/weapon/ore/iron
				G.amount = BOX.amt_iron
				G.loc = output.loc
				BOX.amt_iron = 0
			if (BOX.amt_silver > 0)
				var/obj/item/weapon/ore/silver/G = new /obj/item/weapon/ore/silver
				G.amount = BOX.amt_silver
				G.loc = output.loc
				BOX.amt_silver = 0
			if (BOX.amt_gold > 0)
				var/obj/item/weapon/ore/gold/G = new /obj/item/weapon/ore/gold
				G.amount = BOX.amt_gold
				G.loc = output.loc
				BOX.amt_gold = 0
			if (BOX.amt_uranium > 0)
				var/obj/item/weapon/ore/uranium/G = new /obj/item/weapon/ore/uranium
				G.amount = BOX.amt_uranium
				G.loc = output.loc
				BOX.amt_uranium = 0
			if (BOX.amt_clown > 0)
				var/obj/item/weapon/ore/clown/G = new /obj/item/weapon/ore/clown
				G.amount = BOX.amt_clown
				G.loc = output.loc
				BOX.amt_clown = 0

			var/i = 0
			for (var/obj/item/weapon/ore/O in BOX.contents)
				BOX.contents -= O
				O.loc = output.loc
				i++
				if (i>=10)
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
	return
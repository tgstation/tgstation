/obj/machinery/mineral/sorting_machine
	name = "sorting machine"
	desc = "Sorts the objects of choice."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "stacker"
	density = 1
	anchored = 1.0
	input_dir = NORTH
	output_dir = SOUTH
	var/obj/item/sorted_object
	var/sort_dir = 1
	fast_process = 1
	rcd_deconstruct = 1

/obj/machinery/mineral/sorting_machine/attackby(obj/item/W, mob/user, params)
	..()
	if(istype(W, /obj/item/device/multitool))
		switch(sort_dir)
			if(1)
				input_dir = SOUTH
				output_dir = NORTH
				sort_dir = 2
				user << "[src] now inputs from the south and outputs to the north."
			if(2)
				input_dir = EAST
				output_dir = WEST
				sort_dir = 3
				user << "[src] now inputs from the east and outputs to the west."
			if(3)
				input_dir = WEST
				output_dir = EAST
				sort_dir = 4
				user << "[src] now inputs from the west and outputs to the east."
			if(4)
				input_dir = NORTH
				output_dir = SOUTH
				sort_dir = 1
				user << "[src] now inputs from the north and outputs to the south."
		return
	else if(istype(W, /obj/item))
		var/obj/item/I = W
		user << "[src] will now sort out [I]."
		sorted_object = I
		return

/obj/machinery/mineral/sorting_machine/process()
	if(!sorted_object)
		return
	var/turf/T = get_step(src, input_dir)
	if(T)
		for(var/obj/item/S in T)
			if(istype(S, sorted_object.type))
				unload_mineral(S)

/obj/machinery/mineral/sorting_machine/examine(mob/user)
	..()
	switch(input_dir)
		if(NORTH)
			user << "The input screen reads 'NORTH'."
		if(SOUTH)
			user << "The input screen reads 'SOUTH'."
		if(EAST)
			user << "The input screen reads 'EAST'."
		if(WEST)
			user << "The input screen reads 'WEST'."
	switch(output_dir)
		if(NORTH)
			user << "The output screen reads 'NORTH'."
		if(SOUTH)
			user << "The output screen reads 'SOUTH'."
		if(EAST)
			user << "The output screen reads 'EAST'."
		if(WEST)
			user << "The output screen reads 'WEST'."
	if(sorted_object)
		user << "The machine is sorting out [sorted_object.name]."
/obj/machinery/mineral/crafting_machine
	name = "crafting machine"
	desc = "Crafts the object of choice."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "unloader"
	density = 1
	anchored = 1.0
	input_dir = NORTH
	output_dir = SOUTH
	var/obj/item/crafted_object
	var/sort_dir = 1
	fast_process = 1
	rcd_deconstruct = 1
	var/datum/material_container/materials
/obj/machinery/mineral/crafting_machine/New()
	..()
	materials = new /datum/material_container(src, list(MAT_METAL=1, MAT_GLASS=1, MAT_SILVER=1, MAT_GOLD=1, MAT_DIAMOND=1, MAT_URANIUM=1, MAT_PLASMA=1, MAT_BANANIUM=1),200000)

/obj/machinery/mineral/crafting_machine/attackby(obj/item/W, mob/user, params)
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
		if(!I.materials.len || !I.materials)
			user << "You cannot produce this object as it is not made out of any materials!"
			return
		user << "[src] will now craft [I]. Examine the machine to see the required materials."
		crafted_object = new I.type(src)
		return

/obj/machinery/mineral/crafting_machine/process()
	if(!crafted_object)
		return
	var/turf/T = get_step(src, input_dir)
	if(T)
		for(var/obj/item/S in T)
			materials.insert_item(S)
			qdel(S)
	if(crafted_object)
		if(materials.use_amount(crafted_object.materials))
			var/obj/item/craft = new crafted_object.type()
			unload_mineral(craft)

/obj/machinery/mineral/crafting_machine/examine(mob/user)
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
	if(crafted_object)
		user << "The machine is crafting [crafted_object.name]."
		user << "It requires the following per production:"
		if(crafted_object.materials[MAT_METAL])
			user << " - [crafted_object.materials[MAT_METAL]]u of Metal"
		if(crafted_object.materials[MAT_GLASS])
			user << " - [crafted_object.materials[MAT_GLASS]]u of Glass"
		if(crafted_object.materials[MAT_SILVER])
			user << " - [crafted_object.materials[MAT_SILVER]]u of Silver"
		if(crafted_object.materials[MAT_GOLD])
			user << " - [crafted_object.materials[MAT_GOLD]]u of Gold"
		if(crafted_object.materials[MAT_URANIUM])
			user << " - [crafted_object.materials[MAT_URANIUM]]u of Uranium"
		if(crafted_object.materials[MAT_DIAMOND])
			user << " - [crafted_object.materials[MAT_DIAMOND]]u of Diamond"
		if(crafted_object.materials[MAT_PLASMA])
			user << " - [crafted_object.materials[MAT_PLASMA]]u of Plasma"
		if(crafted_object.materials[MAT_BANANIUM])
			user << " - [crafted_object.materials[MAT_BANANIUM]]u of Bananium"

	user << "The machine has the following resources:"
	if(materials.amount(MAT_METAL))
		user << " - [materials.amount(MAT_METAL)]u of Metal"
	if(materials.amount(MAT_GLASS))
		user << " - [materials.amount(MAT_GLASS)]u of Glass"
	if(materials.amount(MAT_SILVER))
		user << " - [materials.amount(MAT_SILVER)]u of Silver"
	if(materials.amount(MAT_GOLD))
		user << " - [materials.amount(MAT_GOLD)]u of Gold"
	if(materials.amount(MAT_URANIUM))
		user << " - [materials.amount(MAT_URANIUM)]u of Uranium"
	if(materials.amount(MAT_DIAMOND))
		user << " - [materials.amount(MAT_DIAMOND)]u of Diamond"
	if(materials.amount(MAT_PLASMA))
		user << " - [materials.amount(MAT_PLASMA)]u of Plasma"
	if(materials.amount(MAT_BANANIUM))
		user << " - [materials.amount(MAT_BANANIUM)]u of Bananium"

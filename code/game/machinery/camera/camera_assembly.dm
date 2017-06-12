/obj/item/wallframe/camera
	name = "camera assembly"
	desc = "The basic construction for Nanotrasen-Always-Watching-You cameras."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "cameracase"
	materials = list(MAT_METAL=400, MAT_GLASS=250)
	result_path = /obj/structure/camera_assembly


/obj/structure/camera_assembly
	name = "camera assembly"
	desc = "The basic construction for Nanotrasen-Always-Watching-You cameras."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "camera1"
	obj_integrity = 150
	max_integrity = 150
	//	Motion, EMP-Proof, X-Ray
	var/list/obj/item/possible_upgrades = list(/obj/item/device/assembly/prox_sensor, /obj/item/stack/sheet/mineral/plasma, /obj/item/device/analyzer)
	var/list/upgrades = list()
	var/state = 1

	/*
			1 = Wrenched in place
			2 = Welded in place
			3 = Wires attached to it (you can now attach/dettach upgrades)
			4 = Screwdriver panel closed and is fully built (you cannot attach upgrades)
	*/

/obj/structure/camera_assembly/New(loc, ndir, building)
	..()
	if(building)
		setDir(ndir)

/obj/structure/camera_assembly/Destroy()
	for(var/I in upgrades)
		qdel(I)
	upgrades.Cut()
	return ..()

/obj/structure/camera_assembly/attackby(obj/item/W, mob/living/user, params)
	switch(state)
		if(1)
			// State 1
			if(istype(W, /obj/item/weapon/weldingtool))
				if(weld(W, user))
					to_chat(user, "<span class='notice'>You weld the assembly securely into place.</span>")
					anchored = 1
					state = 2
				return

			else if(istype(W, /obj/item/weapon/wrench))
				playsound(src.loc, W.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You unattach the assembly from its place.</span>")
				new /obj/item/wallframe/camera(get_turf(src))
				qdel(src)
				return

		if(2)
			// State 2
			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = W
				if(C.use(2))
					to_chat(user, "<span class='notice'>You add wires to the assembly.</span>")
					state = 3
				else
					to_chat(user, "<span class='warning'>You need two lengths of cable to wire a camera!</span>")
					return
				return

			else if(istype(W, /obj/item/weapon/weldingtool))

				if(weld(W, user))
					to_chat(user, "<span class='notice'>You unweld the assembly from its place.</span>")
					state = 1
					anchored = 1
				return


		if(3)
			// State 3
			if(istype(W, /obj/item/weapon/screwdriver))
				playsound(src.loc, W.usesound, 50, 1)

				var/input = stripped_input(user, "Which networks would you like to connect this camera to? Seperate networks with a comma. No Spaces!\nFor example: SS13,Security,Secret ", "Set Network", "SS13")
				if(!input)
					to_chat(user, "<span class='warning'>No input found, please hang up and try your call again!</span>")
					return

				var/list/tempnetwork = splittext(input, ",")
				if(tempnetwork.len < 1)
					to_chat(user, "<span class='warning'>No network found, please hang up and try your call again!</span>")
					return

				state = 4
				var/obj/machinery/camera/C = new(src.loc)
				src.loc = C
				C.assembly = src
				C.setDir(src.dir)

				C.network = tempnetwork
				var/area/A = get_area(src)
				C.c_tag = "[A.name] ([rand(1, 999)])"


			else if(istype(W, /obj/item/weapon/wirecutters))
				new/obj/item/stack/cable_coil(get_turf(src), 2)
				playsound(src.loc, W.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You cut the wires from the circuits.</span>")
				state = 2
				return

	// Upgrades!
	if(is_type_in_list(W, possible_upgrades) && !is_type_in_list(W, upgrades)) // Is a possible upgrade and isn't in the camera already.
		if(!user.drop_item(W))
			return
		to_chat(user, "<span class='notice'>You attach \the [W] into the assembly inner circuits.</span>")
		upgrades += W
		W.forceMove(src)
		return

	// Taking out upgrades
	else if(istype(W, /obj/item/weapon/crowbar) && upgrades.len)
		var/obj/U = locate(/obj) in upgrades
		if(U)
			to_chat(user, "<span class='notice'>You unattach an upgrade from the assembly.</span>")
			playsound(src.loc, W.usesound, 50, 1)
			U.loc = get_turf(src)
			upgrades -= U
		return

	return ..()

/obj/structure/camera_assembly/proc/weld(obj/item/weapon/weldingtool/WT, mob/living/user)
	if(!WT.remove_fuel(0, user))
		return 0
	to_chat(user, "<span class='notice'>You start to weld \the [src]...</span>")
	playsound(src.loc, WT.usesound, 50, 1)
	if(do_after(user, 20*WT.toolspeed, target = src))
		if(WT.isOn())
			playsound(loc, 'sound/items/welder2.ogg', 50, 1)
			return 1
	return 0

/obj/structure/camera_assembly/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc)
	qdel(src)

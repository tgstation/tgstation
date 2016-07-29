<<<<<<< HEAD
/obj/item/wallframe/camera
	name = "camera assembly"
	desc = "The basic construction for Nanotrasen-Always-Watching-You cameras."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "cameracase"
	materials = list(MAT_METAL=400, MAT_GLASS=250)
	result_path = /obj/machinery/camera_assembly


/obj/machinery/camera_assembly
	name = "camera assembly"
	desc = "The basic construction for Nanotrasen-Always-Watching-You cameras."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "camera1"
	//	Motion, EMP-Proof, X-Ray
	var/list/obj/item/possible_upgrades = list(/obj/item/device/assembly/prox_sensor, /obj/item/stack/sheet/mineral/plasma, /obj/item/device/analyzer)
	var/list/upgrades = list()
	var/state = 1
	var/busy = 0
	/*
			1 = Wrenched in place
			2 = Welded in place
			3 = Wires attached to it (you can now attach/dettach upgrades)
			4 = Screwdriver panel closed and is fully built (you cannot attach upgrades)
	*/

/obj/machinery/camera_assembly/New(loc, ndir, building)
	..()
	if(building)
		setDir(ndir)

/obj/machinery/camera_assembly/attackby(obj/item/W, mob/living/user, params)
	switch(state)
		if(1)
			// State 1
			if(istype(W, /obj/item/weapon/weldingtool))
				if(weld(W, user))
					user << "<span class='notice'>You weld the assembly securely into place.</span>"
					anchored = 1
					state = 2
				return

			else if(istype(W, /obj/item/weapon/wrench))
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				user << "<span class='notice'>You unattach the assembly from its place.</span>"
				new /obj/item/wallframe/camera(get_turf(src))
				qdel(src)
				return

		if(2)
			// State 2
			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = W
				if(C.use(2))
					user << "<span class='notice'>You add wires to the assembly.</span>"
					state = 3
				else
					user << "<span class='warning'>You need two lengths of cable to wire a camera!</span>"
					return
				return

			else if(istype(W, /obj/item/weapon/weldingtool))

				if(weld(W, user))
					user << "<span class='notice'>You unweld the assembly from its place.</span>"
					state = 1
					anchored = 1
				return


		if(3)
			// State 3
			if(istype(W, /obj/item/weapon/screwdriver))
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)

				var/input = stripped_input(usr, "Which networks would you like to connect this camera to? Seperate networks with a comma. No Spaces!\nFor example: SS13,Security,Secret ", "Set Network", "SS13")
				if(!input)
					usr << "<span class='warning'>No input found, please hang up and try your call again!</span>"
					return

				var/list/tempnetwork = splittext(input, ",")
				if(tempnetwork.len < 1)
					usr << "<span class='warning'>No network found, please hang up and try your call again!</span>"
					return

				state = 4
				var/obj/machinery/camera/C = new(src.loc)
				src.loc = C
				C.assembly = src
				C.setDir(src.dir)

				C.network = tempnetwork
				var/area/A = get_area_master(src)
				C.c_tag = "[A.name] ([rand(1, 999)])"


			else if(istype(W, /obj/item/weapon/wirecutters))
				new/obj/item/stack/cable_coil(get_turf(src), 2)
				playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
				user << "<span class='notice'>You cut the wires from the circuits.</span>"
				state = 2
				return

	// Upgrades!
	if(is_type_in_list(W, possible_upgrades) && !is_type_in_list(W, upgrades)) // Is a possible upgrade and isn't in the camera already.
		if(!user.drop_item(W))
			return
		user << "<span class='notice'>You attach \the [W] into the assembly inner circuits.</span>"
		upgrades += W
		W.forceMove(src)
		return

	// Taking out upgrades
	else if(istype(W, /obj/item/weapon/crowbar) && upgrades.len)
		var/obj/U = locate(/obj) in upgrades
		if(U)
			user << "<span class='notice'>You unattach an upgrade from the assembly.</span>"
			playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
			U.loc = get_turf(src)
			upgrades -= U
		return

	return ..()

/obj/machinery/camera_assembly/proc/weld(obj/item/weapon/weldingtool/WT, mob/living/user)
	if(busy)
		return 0
	if(!WT.remove_fuel(0, user))
		return 0

	user << "<span class='notice'>You start to weld \the [src]...</span>"
	playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
	busy = 1
	if(do_after(user, 20, target = src))
		busy = 0
		if(!WT.isOn())
			return 0
		return 1
	busy = 0
=======
/obj/item/weapon/camera_assembly
	name = "camera assembly"
	desc = "The basic construction for Nanotrasen-Always-Watching-You cameras."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "cameracase"
	w_class = W_CLASS_SMALL
	anchored = 0

	starting_materials = list(MAT_IRON = 700, MAT_GLASS = 300)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_STEEL

	//	Motion, EMP-Proof, X-Ray, Microphone
	var/list/obj/item/possible_upgrades = list(
		/obj/item/device/assembly/prox_sensor,
		/obj/item/stack/sheet/mineral/plasma,
		/obj/item/weapon/reagent_containers/food/snacks/grown/carrot,
		/obj/item/device/assembly/voice,
		)

	var/list/upgrades = list()
	var/state = 0
	var/busy = 0
	/*
				0 = Nothing done to it
				1 = Wrenched in place
				2 = Welded in place
				3 = Wires attached to it (you can now attach/dettach upgrades)
				4 = Screwdriver panel closed and is fully built (you cannot attach upgrades)
	*/

/obj/item/weapon/camera_assembly/attackby(obj/item/W as obj, mob/living/user as mob)

	switch(state)

		if(0)
			// State 0
			if(iswrench(W) && isturf(src.loc))
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
				to_chat(user, "You wrench the assembly into place.")
				anchored = 1
				state = 1
				update_icon()
				auto_turn()
				return

		if(1)
			// State 1
			if(iswelder(W))
				if(weld(W, user))
					to_chat(user, "You weld the assembly securely into place.")
					anchored = 1
					state = 2
				return

			else if(iswrench(W))
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
				to_chat(user, "You unattach the assembly from it's place.")
				anchored = 0
				update_icon()
				state = 0
				return

		if(2)
			// State 2
			if(iscoil(W))
				var/obj/item/stack/cable_coil/C = W
				if(C.use(2))
					to_chat(user, "You add wires to the assembly.")
					state = 3
				return

			else if(iswelder(W))

				if(weld(W, user))
					to_chat(user, "You unweld the assembly from it's place.")
					state = 1
					anchored = 1
				return


		if(3)
			// State 3
			if(isscrewdriver(W))
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)

				var/input = strip_html(input(usr, "Which networks would you like to connect this camera to? seperate networks with a comma. No Spaces!\nFor example: SS13,Security,Secret ", "Set Network", "SS13"))
				if(!input)
					to_chat(usr, "No input found, please hang up and try your call again.")
					return

				var/list/tempnetwork = splittext(input, ",")
				if(tempnetwork.len < 1)
					to_chat(usr, "No network found, please hang up and try your call again.")
					return

				state = 4
				var/obj/machinery/camera/C = new(src.loc)
				src.loc = C
				C.assembly = src

				C.auto_turn()

				C.network = tempnetwork

				C.c_tag = "[get_area_name(src)] ([rand(1, 999)]"

				for(var/i = 5; i >= 0; i -= 1)
					var/direct = input(user, "Direction?", "Assembling Camera", null) in list("LEAVE IT", "NORTH", "EAST", "SOUTH", "WEST" )
					if(direct != "LEAVE IT")
						C.dir = text2dir(direct)
					if(i != 0)
						var/confirm = alert(user, "Is this what you want? Chances Remaining: [i]", "Confirmation", "Yes", "No")
						if(confirm == "Yes")
							break
				return

			else if(iswirecutter(W))

				new/obj/item/stack/cable_coil(get_turf(src), 2)
				playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 50, 1)
				to_chat(user, "You cut the wires from the circuits.")
				state = 2
				return

	// Upgrades!
	if(is_type_in_list(W, possible_upgrades)) // Is a possible upgrade
		if(is_type_in_list(W, upgrades))
			to_chat(user, "The assembly already has \a [W] inside!")
			return
		if (istype(W, /obj/item/stack))
			var/obj/item/stack/sheet/mineral/plasma/s = W
			s.use(1)
			upgrades += new /obj/item/stack/sheet/mineral/plasma
		else
			if(!user.drop_item(W, src)) return
			upgrades += W
		to_chat(user, "You attach the [W] into the assembly inner circuits.")
		return

	// Taking out upgrades
	else if(iscrowbar(W) && upgrades.len)
		var/obj/U = locate(/obj) in upgrades
		if(U)
			to_chat(user, "You unattach \the [U] from the assembly.")
			playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
			U.loc = get_turf(src)
			upgrades -= U
		return

	..()

/obj/item/weapon/camera_assembly/update_icon()
	if(anchored)
		icon_state = "camera1"
	else
		icon_state = "cameracase"

/obj/item/weapon/camera_assembly/attack_hand(mob/user as mob)
	if(!anchored)
		..()

/obj/item/weapon/camera_assembly/proc/weld(var/obj/item/weapon/weldingtool/WT, var/mob/user)


	if(busy)
		return 0
	if(!WT.isOn())
		return 0

	to_chat(user, "<span class='notice'>You start to weld the [src]...</span>")
	playsound(get_turf(src), 'sound/items/Welder.ogg', 50, 1)
	WT.eyecheck(user)
	busy = 1
	if(do_after(user, src, 20))
		busy = 0
		if(!WT.isOn())
			return 0
		return 1
	busy = 0
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	return 0
/obj/item/wallframe/camera
	name = "camera assembly"
	desc = "The basic construction for Nanotrasen-Always-Watching-You cameras."
	icon = 'icons/obj/machines/camera.dmi'
	icon_state = "cameracase"
	materials = list(MAT_METAL=400, MAT_GLASS=250)
	result_path = /obj/structure/camera_assembly


/obj/structure/camera_assembly
	name = "camera assembly"
	desc = "The basic construction for Nanotrasen-Always-Watching-You cameras."
	icon = 'icons/obj/machines/camera.dmi'
	icon_state = "camera1"
	max_integrity = 150
	//	Motion, EMP-Proof, X-ray
	var/static/list/possible_upgrades = typecacheof(list(/obj/item/assembly/prox_sensor, /obj/item/stack/sheet/mineral/plasma, /obj/item/analyzer))
	var/list/upgrades
	var/state = 1

	/*
			1 = Wrenched in place
			2 = Welded in place
			3 = Wires attached to it (you can now attach/dettach upgrades)
			4 = Screwdriver panel closed and is fully built (you cannot attach upgrades)
	*/

/obj/structure/camera_assembly/Initialize(mapload, ndir, building)
	. = ..()
	if(building)
		setDir(ndir)
	upgrades = list()

/obj/structure/camera_assembly/Destroy()
	QDEL_LIST(upgrades)
	return ..()

/obj/structure/camera_assembly/attackby(obj/item/W, mob/living/user, params)
	switch(state)
		if(1)
			// State 1
			if(istype(W, /obj/item/weldingtool))
				if(weld(W, user))
					to_chat(user, "<span class='notice'>You weld the assembly securely into place.</span>")
					setAnchored(TRUE)
					state = 2
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

			else if(istype(W, /obj/item/weldingtool))

				if(weld(W, user))
					to_chat(user, "<span class='notice'>You unweld the assembly from its place.</span>")
					state = 1
					setAnchored(TRUE)
				return

	// Upgrades!
	if(is_type_in_typecache(W, possible_upgrades) && !is_type_in_list(W, upgrades)) // Is a possible upgrade and isn't in the camera already.
		if(!user.transferItemToLoc(W, src))
			return
		to_chat(user, "<span class='notice'>You attach \the [W] into the assembly inner circuits.</span>")
		upgrades += W
		return

	return ..()

/obj/structure/camera_assembly/crowbar_act(mob/user, obj/item/tool)
	if(!upgrades.len)
		return FALSE
	var/obj/U = locate(/obj) in upgrades
	if(U)
		to_chat(user, "<span class='notice'>You detach an upgrade from the assembly.</span>")
		tool.play_tool_sound(src)
		U.forceMove(drop_location())
		upgrades -= U
	return TRUE

/obj/structure/camera_assembly/screwdriver_act(mob/user, obj/item/tool)
	. = ..()
	if(.)
		return TRUE
	if(state != 3)
		return FALSE

	tool.play_tool_sound(src)
	var/input = stripped_input(user, "Which networks would you like to connect this camera to? Separate networks with a comma. No Spaces!\nFor example: SS13,Security,Secret ", "Set Network", "SS13")
	if(!input)
		to_chat(user, "<span class='warning'>No input found, please hang up and try your call again!</span>")
		return
	var/list/tempnetwork = splittext(input, ",")
	if(tempnetwork.len < 1)
		to_chat(user, "<span class='warning'>No network found, please hang up and try your call again!</span>")
		return
	for(var/i in tempnetwork)
		tempnetwork -= i
		tempnetwork += lowertext(i)
	state = 4
	var/obj/machinery/camera/C = new(loc, src)
	forceMove(C)
	C.setDir(src.dir)

	C.network = tempnetwork
	var/area/A = get_area(src)
	C.c_tag = "[A.name] ([rand(1, 999)])"
	return TRUE

/obj/structure/camera_assembly/wirecutter_act(mob/user, obj/item/I)
	if(state != 3)
		return FALSE

	new /obj/item/stack/cable_coil(drop_location(), 2)
	I.play_tool_sound(src)
	to_chat(user, "<span class='notice'>You cut the wires from the circuits.</span>")
	state = 2
	return TRUE

/obj/structure/camera_assembly/wrench_act(mob/user, obj/item/I)
	if(state != 1)
		return FALSE
	I.play_tool_sound(src)
	to_chat(user, "<span class='notice'>You detach the assembly from its place.</span>")
	new /obj/item/wallframe/camera(drop_location())
	qdel(src)
	return TRUE

/obj/structure/camera_assembly/proc/weld(obj/item/weldingtool/W, mob/living/user)
	if(!W.tool_start_check(user, amount=0))
		return FALSE
	to_chat(user, "<span class='notice'>You start to weld \the [src]...</span>")
	if(W.use_tool(src, user, 20, volume=50))
		return TRUE
	return FALSE

/obj/structure/camera_assembly/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/metal(loc)
	qdel(src)

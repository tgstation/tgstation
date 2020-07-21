/obj/structure/lattice
	name = "lattice"
	desc = "A lightweight support lattice. These hold our station together."
	icon = 'icons/obj/smooth_structures/lattice.dmi'
	icon_state = "lattice"
	density = FALSE
	anchored = TRUE
	armor = list("melee" = 50, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 50)
	max_integrity = 50
	layer = LATTICE_LAYER //under pipes
	plane = FLOOR_PLANE
	var/number_of_mats = 1
	var/build_material = /obj/item/stack/rods
	canSmoothWith = list(/obj/structure/lattice,
	/turf/open/floor,
	/turf/closed/wall,
	/obj/structure/falsewall)
	smooth = SMOOTH_MORE
	//	flags = CONDUCT_1
	obj_flags = CAN_BE_HIT | BLOCK_Z_OUT_DOWN

/obj/structure/lattice/examine(mob/user)
	. = ..()
	. += deconstruction_hints(user)

/obj/structure/lattice/proc/deconstruction_hints(mob/user)
	return "<span class='notice'>The rods look like they could be <b>cut</b>. There's space for more <i>rods</i> or a <i>tile</i>.</span>"

/obj/structure/lattice/Initialize(mapload)
	. = ..()
	for(var/obj/structure/lattice/LAT in loc)
		if(LAT == src)
			continue
		stack_trace("multiple lattices found in ([loc.x], [loc.y], [loc.z])")
		return INITIALIZE_HINT_QDEL

/obj/structure/lattice/blob_act(obj/structure/blob/B)
	return

/obj/structure/lattice/attackby(obj/item/C, mob/user, params)
	if(resistance_flags & INDESTRUCTIBLE)
		return
	if(C.tool_behaviour == TOOL_WIRECUTTER)
		to_chat(user, "<span class='notice'>Slicing [name] joints ...</span>")
		deconstruct()
	else
		var/turf/T = get_turf(src)
		return T.attackby(C, user) //hand this off to the turf instead (for building plating, catwalks, etc)

/obj/structure/lattice/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new build_material(get_turf(src), number_of_mats)
	qdel(src)

/obj/structure/lattice/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_FLOORWALL)
		return list("mode" = RCD_FLOORWALL, "delay" = 0, "cost" = 2)

/obj/structure/lattice/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	if(passed_mode == RCD_FLOORWALL)
		to_chat(user, "<span class='notice'>You build a floor.</span>")
		var/turf/T = src.loc
		if(isspaceturf(T))
			T.PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
			qdel(src)
			return TRUE
	return FALSE

/obj/structure/lattice/singularity_pull(S, current_size)
	if(current_size >= STAGE_FOUR)
		deconstruct()

/obj/structure/lattice/catwalk
	name = "catwalk"
	desc = "A catwalk for easier EVA maneuvering and cable placement."
	icon = 'icons/obj/smooth_structures/catwalk.dmi'
	icon_state = "catwalk"
	number_of_mats = 2
	smooth = SMOOTH_TRUE
	canSmoothWith = null
	obj_flags = CAN_BE_HIT | BLOCK_Z_OUT_DOWN | BLOCK_Z_IN_UP

/obj/structure/lattice/catwalk/deconstruction_hints(mob/user)
	return "<span class='notice'>The supporting rods look like they could be <b>cut</b>.</span>"

/obj/structure/lattice/catwalk/Move()
	var/turf/T = loc
	for(var/obj/structure/cable/C in T)
		C.deconstruct()
	..()

/obj/structure/lattice/catwalk/deconstruct()
	var/turf/T = loc
	for(var/obj/structure/cable/C in T)
		C.deconstruct()
	..()

/obj/structure/lattice/lava
	name = "heatproof support lattice"
	desc = "A specialized support beam for building across lava. Watch your step."
	icon = 'icons/obj/smooth_structures/catwalk.dmi'
	icon_state = "catwalk"
	number_of_mats = 1
	color = "#5286b9ff"
	smooth = SMOOTH_TRUE
	canSmoothWith = null
	obj_flags = CAN_BE_HIT | BLOCK_Z_OUT_DOWN | BLOCK_Z_IN_UP
	resistance_flags = FIRE_PROOF | LAVA_PROOF

/obj/structure/lattice/lava/deconstruction_hints(mob/user)
	return "<span class='notice'>The rods look like they could be <b>cut</b>, but the <i>heat treatment will shatter off</i>. There's space for a <i>tile</i>.</span>"

/obj/structure/lattice/lava/attackby(obj/item/C, mob/user, params)
	. = ..()
	if(istype(C, /obj/item/stack/tile/plasteel))
		var/obj/item/stack/tile/plasteel/P = C
		if(P.use(1))
			to_chat(user, "<span class='notice'>You construct a floor plating, as lava settles around the rods.</span>")
			playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
			new /turf/open/floor/plating(locate(x, y, z))
		else
			to_chat(user, "<span class='warning'>You need one floor tile to build atop [src].</span>")
		return


/obj/structure/lattice/lift
	name = "lift lattice"
	desc = "A lightweight support lattice. These hold lift platform together."
	icon = 'icons/obj/smooth_structures/catwalk.dmi'
	icon_state = "catwalk"
	density = FALSE
	anchored = TRUE
	armor = list("melee" = 50, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 50)
	max_integrity = 50
	layer = LATTICE_LAYER //under pipes
	plane = FLOOR_PLANE
	canSmoothWith = list(/obj/structure/lattice/lift)
	smooth = SMOOTH_MORE
	//	flags = CONDUCT_1
	obj_flags = CAN_BE_HIT | BLOCK_Z_OUT_DOWN
	
	var/list/lift_load = list() //things to move
	var/datum/lift_master/LM


/obj/structure/lattice/lift/Initialize(mapload)
	. = ..()

	RegisterSignal(src, COMSIG_MOVABLE_CROSSED, .proc/AddItemOnLift)
	RegisterSignal(src, COMSIG_MOVABLE_UNCROSSED, .proc/RemoveItemFromLift)

/obj/structure/lattice/lift/proc/RemoveItemFromLift(datum/source, atom/movable/AM)
	to_chat(world, "[src] RemoveItemFromLift([AM])")
	lift_load -= AM

	/*
	if(source != loc)
		to_chat(world, "[src] RemoveItemFromLift([AM])")
		lift_load -= AM
		//lift_load -= source
		//UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
	else
		to_chat(world, "[src] RemoveItemFromLift([AM]) but it on ")*/

/obj/structure/lattice/lift/proc/AddItemOnLift(datum/source, atom/movable/AM)
	to_chat(world, "[src] AddItemOnLift([AM])")
	//if(istype(AM))
	lift_load |= AM
	//RegisterSignal(AM, COMSIG_MOVABLE_MOVED, .proc/RemoveItemFromLift) //Listen for the pickup event, unregister on pick-up so we aren't moved
	//else
	//	WARNING("Try load wrong type on lift")

datum/lift_master
	var/list/lift_platforms = list()

datum/lift_master/New(obj/structure/lattice/lift/lift_platform)
	lift_platforms |= lift_platform
	Rebuild_lift_plaform(lift_platform)

datum/lift_master/proc/Rebuild_lift_plaform(obj/structure/lattice/lift/base_lift_platform)
	var/list/possible_expansions = list(base_lift_platform)
	while(possible_expansions.len)
		for(var/obj/structure/lattice/lift/borderline in possible_expansions)
			var/list/result = borderline.lift_platform_expansion(src)
			if(result && result.len)
				for(var/obj/structure/lattice/lift/LP in result)
					if(!lift_platforms.Find(LP))
						LP.LM = src
						lift_platforms += LP
						possible_expansions += LP
			possible_expansions -= borderline

datum/lift_master/proc/MoveLift(going_up, mob/user, var/turf/destination)
	for(var/x in lift_platforms)
		var/obj/structure/lattice/lift/lift_platform = x
		lift_platform.travel(going_up)

/obj/structure/lattice/lift/proc/lift_platform_expansion(datum/lift_master/LM)
	. = list()
	for(var/D in GLOB.cardinals)
		var/turf/T = get_step(src, D)
		. |= locate(/obj/structure/lattice/lift) in T 


//datum/lift_master/proc/travel(going_up, mob/user, is_ghost, var/turf/destination)
/obj/structure/lattice/lift/proc/travel(going_up)
//	if(!is_ghost)
//		show_fluff_message(going_up, user)
//		add_fingerprint(user)

	//var/turf/OldLoc=loc
	var/list/things2move = lift_load.Copy()
	
	var/turf/destination = get_step_multiz(src, going_up ? UP : DOWN )
	
	forceMove(destination)

	//for(var/mob/M in OldLoc.contents)//Kidnap everyone on top
	//	M.forceMove(loc)
	for(var/x in things2move)
		var/atom/movable/AM = x
		AM.forceMove(destination)
	//	if(!AM.forceMove(destination))
	//		RemoveItemFromLift(AM, AM.loc)	

/obj/structure/lattice/lift/proc/use(mob/user, is_ghost=FALSE)
	if(!LM)
		LM = new(src)
	if (!is_ghost && !in_range(src, user))
		return

	var/list/tool_list = list(
		"Up" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = NORTH),
		"Down" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = SOUTH)
		)

	var/turf/up_level = get_step_multiz(src, UP)
	var/turf/down_level = get_step_multiz(src, DOWN)

	if (up_level || down_level)
		var/result = show_radial_menu(user, src, tool_list, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
		if (!is_ghost && !in_range(src, user))
			return  // nice try
		switch(result)
			if("Up")
				if(up_level)
					//travel(TRUE, user, is_ghost, up_level)
					LM.MoveLift(TRUE, user, up_level)
					//travel(TRUE)
					use(user)
				else
					to_chat(user, "<span class='warning'>[src] doesn't seem to able move up!</span>")
					use(user)
			if("Down")
				if(down_level)
					//travel(FALSE, user, is_ghost, down_level)
					LM.MoveLift(FALSE, user, up_level)
					//travel(FALSE)
					use(user)
				else
					to_chat(user, "<span class='warning'>[src] doesn't seem to able move down!</span>")
					use(user)
			if("Cancel")
				return
	else
		to_chat(user, "<span class='warning'>[src] doesn't seem to able move anywhere!</span>")

	if(!is_ghost)
		add_fingerprint(user)

/obj/structure/lattice/lift/proc/check_menu(mob/user)
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/structure/lattice/lift/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	use(user)

/obj/structure/lattice/lift/attack_paw(mob/user)
	return use(user)

/obj/structure/lattice/lift/attackby(obj/item/W, mob/user, params)
	return use(user)

/obj/structure/lattice/lift/attack_robot(mob/living/silicon/robot/R)
	if(R.Adjacent(src))
		return use(R)

//ATTACK GHOST IGNORING PARENT RETURN VALUE
/obj/structure/lattice/lift/attack_ghost(mob/dead/observer/user)
	use(user, TRUE)
	return ..()

/obj/structure/lattice/lift/proc/show_fluff_message(going_up, mob/user)
	if(going_up)
		user.visible_message("<span class='notice'>[user] move lift up [src].</span>", "<span class='notice'>Lift move up [src].</span>")
	else
		user.visible_message("<span class='notice'>[user] move lift down [src].</span>", "<span class='notice'>Lift move down [src].</span>")

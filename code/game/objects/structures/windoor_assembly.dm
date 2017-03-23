/* Windoor (window door) assembly -Nodrak
 * Step 1: Create a windoor out of rglass
 * Step 2: Add r-glass to the assembly to make a secure windoor (Optional)
 * Step 3: Rotate or Flip the assembly to face and open the way you want
 * Step 4: Wrench the assembly in place
 * Step 5: Add cables to the assembly
 * Step 6: Set access for the door.
 * Step 7: Screwdriver the door to complete
 */


/obj/structure/windoor_assembly
	icon = 'icons/obj/doors/windoor.dmi'

	name = "windoor Assembly"
	icon_state = "l_windoor_assembly01"
	anchored = TRUE
	density = 0
	dir = NORTH

	var/ini_dir
	var/created_name = null

	//Vars to help with the icon's name
	var/facing = "l"	//Does the windoor open to the left or right?
	var/secure = 0		//Whether or not this creates a secure windoor
	CanAtmosPass = ATMOS_PASS_PROC

/obj/structure/windoor_assembly/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Alt-click to rotate it clockwise.</span>")

/obj/structure/windoor_assembly/Initialize(mapload, set_dir, obj/item/weapon/electronics/airlock/electronics)
	if(set_dir)
		dir = set_dir
	ini_dir = dir
	air_update_turf(1)
	if(!electronics)
		electronics = new
	SetItemToReachConstructionState(WINDOOR_ELECTRONICS, electronics)
	..()

/obj/structure/windoor_assembly/Construct(mob/user, ndir)
	..()
	ini_dir = ndir
	air_update_turf(1)

/obj/structure/windoor_assembly/Destroy()
	density = 0
	air_update_turf(1)
	return ..()

/obj/structure/windoor_assembly/Move()
	var/turf/T = loc
	..()
	setDir(ini_dir)
	move_update_air(T)

/obj/structure/windoor_assembly/update_icon()
	var/state
	switch(current_construction_state.id)
		if(WINDOOR_UNSECURED, WINDOOR_UNWIRED)
			state = "01"
		if(WINDOOR_WIRED, WINDOOR_ELECTRONICS)
			state = "02"
	icon_state = "[facing]_[secure ? "secure_" : ""]windoor_assembly[state]"

/obj/structure/windoor_assembly/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
		return !density
	if(istype(mover, /obj/structure/window))
		var/obj/structure/window/W = mover
		if(!valid_window_location(loc, W.ini_dir))
			return FALSE
	else if(istype(mover, /obj/structure/windoor_assembly))
		var/obj/structure/windoor_assembly/W = mover
		if(!valid_window_location(loc, W.ini_dir))
			return FALSE
	else if(istype(mover, /obj/machinery/door/window) && !valid_window_location(loc, mover.dir))
		return FALSE
	return 1

/obj/structure/windoor_assembly/CanAtmosPass(turf/T)
	if(get_dir(loc, T) == dir)
		return !density
	else
		return 1

/obj/structure/windoor_assembly/CheckExit(atom/movable/mover as mob|obj, turf/target)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1

CONSTRUCTION_BLUEPRINT(/obj/structure/windoor_assembly, FALSE, FALSE)
	. = newlist(
		/datum/construction_state/first{
			required_type_to_construct = /obj/item/stack/sheet/rglass
			required_amount_to_construct = 5
			on_floor = 1
		},
		/datum/construction_state{
			required_type_to_construct = /obj/item/weapon/wrench
			required_type_to_deconstruct = /obj/item/weapon/weldingtool
			construction_delay = 40
			deconstruction_delay = 40
			construction_message = "securing"
			deconstruction_message = "disassembling"
			anchored = 0
		},
		/datum/construction_state{
			required_type_to_construct = /obj/item/stack/cable_coil
			required_amount_to_construct = 1
			required_type_to_deconstruct = /obj/item/weapon/wrench
			construction_delay = 40
			deconstruction_delay = 40
			construction_message = "wiring up"
			deconstruction_message = "unsecuring"
			anchored = 1
		},
		/datum/construction_state{
			required_type_to_construct = /obj/item/weapon/electronics/airlock
			required_amount_to_construct = 1
			stash_construction_item = 1
			required_type_to_deconstruct = /obj/item/weapon/wirecutters
			construction_delay = 40
			deconstruction_delay = 40
			construction_message = "installing " + CONSTRUCTION_ITEM + " into"
			deconstruction_message = "cutting the wires from"
		},
		/datum/construction_state{
			required_type_to_construct = /obj/item/weapon/crowbar
			required_type_to_deconstruct = /obj/item/weapon/screwdriver
			construction_delay = 40
			deconstruction_delay = 40
			construction_message = "finishing"
			deconstruction_message = "remove the electronics from"
		},
		/datum/construction_state/last{
			transformation_type = CONSTRUCTION_TRANSFORMATION_TYPE_AT_RUNTIME
		}
	)

/obj/structure/windoor_assembly/OnConstructionTransform(mob/user, obj/created)
	var/obj/machinery/door/window/windoor
	if(secure)
		windoor = new /obj/machinery/door/window/brigdoor(get_turf(src))
		if(facing == "l")
			windoor.icon_state = "leftsecureopen"
			windoor.base_state = "leftsecure"
		else
			windoor.icon_state = "rightsecureopen"
			windoor.base_state = "rightsecure"
	else
		windoor = new /obj/machinery/door/window(get_turf(src))
		if(facing == "l")
			windoor.icon_state = "leftopen"
			windoor.base_state = "left"
		else
			windoor.icon_state = "rightopen"
			windoor.base_state = "right"
	windoor.setDir(dir)
	windoor.density = FALSE

	var/obj/item/weapon/electronics/airlock/electronics = SetItemToReachConstructionState(WINDOOR_ELECTRONICS, null)

	if(electronics.one_access)
		windoor.req_one_access = electronics.accesses
	else
		windoor.req_access = electronics.accesses
	windoor.electronics = electronics
	electronics.forceMove(windoor)
	if(created_name)
		windoor.name = created_name
	windoor.close()

	return windoor
		
/obj/structure/windoor_assembly/ConstructionChecks(state_started_id, action_type, obj/item/I, mob/user, first_check)
	. = ..()
	if(!.)
		return
	switch(action_type)
		if(CONSTRUCTING)
			if(state_started_id == WINDOOR_UNSECURED)	//Can only be securing
				for(var/obj/machinery/door/window/WD in loc)
					if(WD.dir == dir)
						to_chat(user, "<span class='warning'>There is already a windoor in that location!</span>")
						return FALSE
		if(CUSTOM_CONSTRUCTION)	//plasteel reinforcement
			var/obj/item/stack/sheet/plasteel/P = I
			if(secure)
				to_chat(user, "<span class='warning'>The [src] is already reinforced!</span>")
				return FALSE

			if(P.get_amount() < 2)
				to_chat(user, "<span class='warning'>You need more plasteel to do this!</span>")
				return FALSE

/obj/structure/windoor_assembly/OnDeconstruction(state_id, mob/user, obj/item/created, forced)
	..()
	if(!state_id && secure)
		transfer_fingerprints_to(new /obj/item/stack/rods(get_turf(src), 4))

/obj/structure/windoor_assembly/attackby(obj/item/W, mob/user, params)
	//I really should have spread this out across more states but thin little windoors are hard to sprite.
	add_fingerprint(user)
	var/obj/item/stack/sheet/plasteel/P = W
	if(istype(P, /obj/item/stack/sheet/plasteel) && current_construction_state.id == WINDOOR_UNSECURED)
		to_chat(user, "<span class='notice'>You start to reinforce \the [src] with plasteel...</span>")
		if(ConstructionDoAfter(user, P, 40))
			P.use(2)
			to_chat(user, "<span class='notice'>You reinforce the windoor.</span>")
			secure = TRUE
		return


	else if(istype(W, /obj/item/weapon/pen))
		var/t = stripped_input(user, "Enter the name for the door.", name, created_name,MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && loc != usr)
			return
		created_name = t
		return
	. = ..()
	update_icon()

//Rotates the windoor assembly clockwise
/obj/structure/windoor_assembly/verb/revrotate()
	set name = "Rotate Windoor Assembly"
	set category = "Object"
	set src in oview(1)
	if(usr.stat || !usr.canmove || usr.restrained())
		return
	if(anchored)
		to_chat(usr, "<span class='warning'>[src] cannot be rotated while it is fastened to the floor!</span>")
		return FALSE

	var/target_dir = turn(dir, 270)

	if(!valid_window_location(loc, target_dir))
		to_chat(usr, "<span class='warning'>[src] cannot be rotated in that direction!</span>")
		return FALSE

	setDir(target_dir)

	ini_dir = dir
	update_icon()
	return TRUE

/obj/structure/windoor_assembly/AltClick(mob/user)
	..()
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!in_range(src, user))
		return
	else
		revrotate()

//Flips the windoor assembly, determines whather the door opens to the left or the right
/obj/structure/windoor_assembly/verb/flip()
	set name = "Flip Windoor Assembly"
	set category = "Object"
	set src in oview(1)
	if(usr.stat || !usr.canmove || usr.restrained())
		return

	if(facing == "l")
		to_chat(usr, "<span class='notice'>The windoor will now slide to the right.</span>")
		facing = "r"
	else
		facing = "l"
		to_chat(usr, "<span class='notice'>The windoor will now slide to the left.</span>")

	update_icon()
	return

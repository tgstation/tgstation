/obj/machinery/door/window
	name = "interior door"
	desc = "A strong door."
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "left"
	layer = ABOVE_WINDOW_LAYER
	closingLayer = ABOVE_WINDOW_LAYER
	resistance_flags = ACID_PROOF
	var/base_state = "left"
	max_integrity = 150 //If you change this, consider changing ../door/window/brigdoor/ max_integrity at the bottom of this .dm file
	integrity_failure = 0
	armor = list(MELEE = 20, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 10, BIO = 100, FIRE = 70, ACID = 100)
	visible = FALSE
	flags_1 = ON_BORDER_1
	opacity = FALSE
	pass_flags_self = PASSGLASS
	can_atmos_pass = ATMOS_PASS_PROC
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON | INTERACT_MACHINE_REQUIRES_SILICON | INTERACT_MACHINE_OPEN
	network_id = NETWORK_DOOR_AIRLOCKS
	set_dir_on_move = FALSE
	var/obj/item/electronics/airlock/electronics = null
	var/reinf = 0
	var/shards = 2
	var/rods = 2
	var/cable = 1
	var/list/debris = list()

/obj/machinery/door/window/Initialize(mapload, set_dir)
	. = ..()
	flags_1 &= ~PREVENT_CLICK_UNDER_1
	if(set_dir)
		setDir(set_dir)
	if(LAZYLEN(req_access))
		icon_state = "[icon_state]"
		base_state = icon_state
	for(var/i in 1 to shards)
		debris += new /obj/item/shard(src)
	if(rods)
		debris += new /obj/item/stack/rods(src, rods)
	if(cable)
		debris += new /obj/item/stack/cable_coil(src, cable)

	RegisterSignal(src, COMSIG_COMPONENT_NTNET_RECEIVE, .proc/ntnet_receive)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = .proc/on_exit,
	)

	AddElement(/datum/element/connect_loc, loc_connections)
	AddElement(/datum/element/atmos_sensitive, mapload)

/obj/machinery/door/window/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/ntnet_interface)

/obj/machinery/door/window/Destroy()
	set_density(FALSE)
	QDEL_LIST(debris)
	if(atom_integrity == 0)
		playsound(src, "shatter", 70, TRUE)
	electronics = null
	var/turf/floor = get_turf(src)
	floor.air_update_turf(TRUE, FALSE)
	return ..()

/obj/machinery/door/window/update_icon_state()
	. = ..()
	icon_state = "[base_state][density ? null : "open"]"

/obj/machinery/door/window/proc/open_and_close()
	if(!open())
		return
	autoclose = TRUE
	if(check_access(null))
		sleep(50)
	else //secure doors close faster
		sleep(20)
	if(!density && autoclose) //did someone change state while we slept?
		close()

/obj/machinery/door/window/Bumped(atom/movable/AM)
	if(operating || !density)
		return
	if(!ismob(AM))
		if(ismecha(AM))
			var/obj/vehicle/sealed/mecha/mecha = AM
			for(var/O in mecha.occupants)
				var/mob/living/occupant = O
				if(allowed(occupant))
					open_and_close()
					return
			do_animate("deny")
		return
	if(!SSticker)
		return
	var/mob/M = AM
	if(HAS_TRAIT(M, TRAIT_HANDS_BLOCKED) || ((isdrone(M) || iscyborg(M)) && M.stat != CONSCIOUS))
		return
	bumpopen(M)

/obj/machinery/door/window/bumpopen(mob/user)
	if(operating || !density)
		return
	add_fingerprint(user)
	if(!requiresID())
		user = null

	if(allowed(user))
		open_and_close()
	else
		do_animate("deny")
	return

/obj/machinery/door/window/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return

	if(border_dir == dir)
		return FALSE

	if(istype(mover, /obj/structure/window))
		var/obj/structure/window/moved_window = mover
		return valid_window_location(loc, moved_window.dir, is_fulltile = moved_window.fulltile)

	if(istype(mover, /obj/structure/windoor_assembly) || istype(mover, /obj/machinery/door/window))
		return valid_window_location(loc, mover.dir, is_fulltile = FALSE)

	return TRUE

/obj/machinery/door/window/can_atmos_pass(turf/T, vertical = FALSE)
	if(get_dir(loc, T) == dir)
		return !density
	else
		return TRUE

//used in the AStar algorithm to determinate if the turf the door is on is passable
/obj/machinery/door/window/CanAStarPass(obj/item/card/id/ID, to_dir)
	return !density || (dir != to_dir) || (check_access(ID) && hasPower())

/obj/machinery/door/window/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER
	if(leaving.movement_type & PHASING)
		return

	if(leaving == src)
		return // Let's not block ourselves.

	if((pass_flags_self & leaving.pass_flags) || ((pass_flags_self & LETPASSTHROW) && leaving.throwing))
		return

	if(direction == dir && density)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/machinery/door/window/open(forced=FALSE)
	if (operating) //doors can still open when emag-disabled
		return 0
	if(!forced)
		if(!hasPower())
			return 0
	if(forced < 2)
		if(obj_flags & EMAGGED)
			return 0
	if(!operating) //in case of emag
		operating = TRUE
	do_animate("opening")
	playsound(src, 'sound/machines/windowdoor.ogg', 100, TRUE)
	icon_state ="[base_state]open"
	sleep(10)
	set_density(FALSE)
	air_update_turf(TRUE, FALSE)
	update_freelook_sight()

	if(operating == 1) //emag again
		operating = FALSE
	return 1

/obj/machinery/door/window/close(forced=FALSE)
	if (operating)
		return 0
	if(!forced)
		if(!hasPower())
			return 0
	if(forced < 2)
		if(obj_flags & EMAGGED)
			return 0
	operating = TRUE
	do_animate("closing")
	playsound(src, 'sound/machines/windowdoor.ogg', 100, TRUE)
	icon_state = base_state

	set_density(TRUE)
	air_update_turf(TRUE, TRUE)
	update_freelook_sight()
	sleep(10)

	operating = FALSE
	return 1

/obj/machinery/door/window/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/effects/glasshit.ogg', 90, TRUE)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 100, TRUE)


/obj/machinery/door/window/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1) && !disassembled)
		for(var/obj/fragment in debris)
			fragment.forceMove(get_turf(src))
			transfer_fingerprints_to(fragment)
			debris -= fragment
	qdel(src)

/obj/machinery/door/window/narsie_act()
	add_atom_colour("#7D1919", FIXED_COLOUR_PRIORITY)

/obj/machinery/door/window/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return (exposed_temperature > T0C + (reinf ? 1600 : 800))

/obj/machinery/door/window/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	take_damage(round(exposed_temperature / 200), BURN, 0, 0)


/obj/machinery/door/window/emag_act(mob/user)
	if(!operating && density && !(obj_flags & EMAGGED))
		obj_flags |= EMAGGED
		operating = TRUE
		flick("[base_state]spark", src)
		playsound(src, "sparks", 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		sleep(6)
		operating = FALSE
		desc += "<BR>[span_warning("Its access panel is smoking slightly.")]"
		open(2)

/obj/machinery/door/window/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(flags_1 & NODECONSTRUCT_1)
		return
	if(density || operating)
		to_chat(user, span_warning("You need to open the door to access the maintenance panel!"))
		return
	add_fingerprint(user)
	tool.play_tool_sound(src)
	panel_open = !panel_open
	to_chat(user, span_notice("You [panel_open ? "open" : "close"] the maintenance panel."))
	return TRUE

/obj/machinery/door/window/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	if(flags_1 & NODECONSTRUCT_1)
		return
	if(!panel_open || density || operating)
		return
	add_fingerprint(user)
	user.visible_message(span_notice("[user] removes the electronics from the [name]."), \
	span_notice("You start to remove electronics from the [name]..."))
	if(!tool.use_tool(src, user, 40, volume=50))
		return
	if(!panel_open || density || operating || !loc)
		return
	var/obj/structure/windoor_assembly/windoor_assembly = new /obj/structure/windoor_assembly(loc)
	switch(base_state)
		if("left")
			windoor_assembly.facing = "l"
		if("right")
			windoor_assembly.facing = "r"
		if("leftsecure")
			windoor_assembly.facing = "l"
			windoor_assembly.secure = TRUE
		if("rightsecure")
			windoor_assembly.facing = "r"
			windoor_assembly.secure = TRUE
	windoor_assembly.set_anchored(TRUE)
	windoor_assembly.state= "02"
	windoor_assembly.setDir(dir)
	windoor_assembly.update_appearance()
	windoor_assembly.created_name = name
	if(obj_flags & EMAGGED)
		to_chat(user, span_warning("You discard the damaged electronics."))
		qdel(src)
		return
	to_chat(user, span_notice("You remove the airlock electronics."))
	var/obj/item/electronics/airlock/dropped_electronics
	if(!electronics)
		dropped_electronics = new/obj/item/electronics/airlock(drop_location())
		if(req_one_access)
			dropped_electronics.one_access = 1
			dropped_electronics.accesses = req_one_access
		else
			dropped_electronics.accesses = req_access
	else
		dropped_electronics = electronics
		electronics = null
		dropped_electronics.forceMove(drop_location())
	qdel(src)
	return TRUE

/obj/machinery/door/window/interact(mob/user) //for sillycones
	try_to_activate_door(user)

/obj/machinery/door/window/try_to_activate_door(mob/user, access_bypass = FALSE)
	if (..())
		autoclose = FALSE

/obj/machinery/door/window/try_to_crowbar(obj/item/I, mob/user)
	if(!hasPower())
		if(density)
			open(2)
		else
			close(2)
	else
		to_chat(user, span_warning("The door's motors resist your efforts to force it!"))

/obj/machinery/door/window/do_animate(animation)
	switch(animation)
		if("opening")
			flick("[base_state]opening", src)
		if("closing")
			flick("[base_state]closing", src)
		if("deny")
			flick("[base_state]deny", src)

/obj/machinery/door/window/check_access_ntnet(datum/netdata/data)
	return !requiresID() || ..()

/obj/machinery/door/window/proc/ntnet_receive(datum/source, datum/netdata/data)
	SIGNAL_HANDLER

	// Check if the airlock is powered.
	if(!hasPower())
		return

	// Handle received packet.
	var/command = data.data["data"]
	var/command_value = data.data["data_secondary"]
	switch(command)
		if("open")
			if(command_value == "on" && !density)
				return

			if(command_value == "off" && density)
				return

			if(density)
				INVOKE_ASYNC(src, .proc/open)
			else
				INVOKE_ASYNC(src, .proc/close)
		if("touch")
			INVOKE_ASYNC(src, .proc/open_and_close)

/obj/machinery/door/window/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_DECONSTRUCT)
			return list("mode" = RCD_DECONSTRUCT, "delay" = 50, "cost" = 32)
	return FALSE

/obj/machinery/door/window/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_DECONSTRUCT)
			to_chat(user, span_notice("You deconstruct the windoor."))
			qdel(src)
			return TRUE
	return FALSE


/obj/machinery/door/window/brigdoor
	name = "secure door"
	icon_state = "leftsecure"
	base_state = "leftsecure"
	var/id = null
	max_integrity = 300 //Stronger doors for prison (regular window door health is 200)
	reinf = 1
	explosion_block = 1

/obj/machinery/door/window/brigdoor/security/cell
	name = "cell door"
	desc = "For keeping in criminal scum."
	req_access = list(ACCESS_BRIG)

/obj/machinery/door/window/brigdoor/security/holding
	name = "holding cell door"
	req_one_access = list(ACCESS_SEC_DOORS, ACCESS_LAWYER) //love for the lawyer

/obj/machinery/door/window/northleft
	dir = NORTH

/obj/machinery/door/window/eastleft
	dir = EAST

/obj/machinery/door/window/westleft
	dir = WEST

/obj/machinery/door/window/southleft
	dir = SOUTH

/obj/machinery/door/window/northright
	dir = NORTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/eastright
	dir = EAST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/westright
	dir = WEST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/southright
	dir = SOUTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/brigdoor/northleft
	dir = NORTH

/obj/machinery/door/window/brigdoor/eastleft
	dir = EAST

/obj/machinery/door/window/brigdoor/westleft
	dir = WEST

/obj/machinery/door/window/brigdoor/southleft
	dir = SOUTH

/obj/machinery/door/window/brigdoor/northright
	dir = NORTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/eastright
	dir = EAST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/westright
	dir = WEST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/southright
	dir = SOUTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/cell/northleft
	dir = NORTH

/obj/machinery/door/window/brigdoor/security/cell/eastleft
	dir = EAST

/obj/machinery/door/window/brigdoor/security/cell/westleft
	dir = WEST

/obj/machinery/door/window/brigdoor/security/cell/southleft
	dir = SOUTH

/obj/machinery/door/window/brigdoor/security/cell/northright
	dir = NORTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/cell/eastright
	dir = EAST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/cell/westright
	dir = WEST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/cell/southright
	dir = SOUTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/holding/northleft
	dir = NORTH

/obj/machinery/door/window/brigdoor/security/holding/eastleft
	dir = EAST

/obj/machinery/door/window/brigdoor/security/holding/westleft
	dir = WEST

/obj/machinery/door/window/brigdoor/security/holding/southleft
	dir = SOUTH

/obj/machinery/door/window/brigdoor/security/holding/northright
	dir = NORTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/holding/eastright
	dir = EAST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/holding/westright
	dir = WEST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/security/holding/southright
	dir = SOUTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

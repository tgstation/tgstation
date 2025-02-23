/// Maximum amount of items a conveyor can move at once.
#define MAX_CONVEYOR_ITEMS_MOVE 30
/// Conveyor is currently off.
#define CONVEYOR_OFF 0
/// Conveyor is currently configured to move items forward.
#define CONVEYOR_FORWARD 1
/// Conveyor is currently configured to move items backwards.
#define CONVEYOR_BACKWARDS -1
GLOBAL_LIST_EMPTY(conveyors_by_id)

/obj/machinery/conveyor
	icon = 'icons/obj/machines/recycling.dmi'
	icon_state = "conveyor_map"
	base_icon_state = "conveyor"
	name = "conveyor belt"
	desc = "A conveyor belt."
	layer = BELOW_OPEN_DOOR_LAYER
	processing_flags = NONE
	/// The current state of the switch.
	var/operating = CONVEYOR_OFF
	/// This is the default (forward) direction, set by the map dir.
	var/forwards
	/// The opposite of forwards. It's set in a special var for corner belts, which aren't using the opposite direction when in reverse.
	var/backwards
	/// The actual direction to move stuff in.
	var/movedir
	/// The time between movements of the conveyor belts, base 0.2 seconds
	var/speed = 0.2
	/// The control ID - must match at least one conveyor switch's ID to be useful.
	var/id = ""
	/// Inverts the direction the conveyor belt moves when true.
	var/inverted = FALSE
	/// Is the conveyor's belt flipped? Useful mostly for conveyor belt corners. It makes the belt point in the other direction, rather than just going in reverse.
	var/flipped = FALSE
	/// Are we currently conveying items?
	var/conveying = FALSE
	///Direction -> if we have a conveyor belt in that direction
	var/list/neighbors
	/// are we operating in wire power mode
	var/wire_mode = FALSE
	/// weakref to attached cable if wire mode
	var/datum/weakref/attached_wire_ref

/obj/machinery/conveyor/Initialize(mapload, new_dir, new_id)
	. = ..()
	AddElement(/datum/element/footstep_override, priority = STEP_SOUND_CONVEYOR_PRIORITY)
	AddElement(/datum/element/give_turf_traits, string_list(list(TRAIT_TURF_IGNORE_SLOWDOWN)))
	register_context()
	if(new_dir)
		setDir(new_dir)
	if(new_id)
		id = new_id
	neighbors = list()
	///Leaving onto conveyor detection won't work at this point, but that's alright since it's an optimization anyway
	///Should be fine without it
	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXITED = PROC_REF(conveyable_exit),
		COMSIG_ATOM_ENTERED = PROC_REF(conveyable_enter),
		COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON = PROC_REF(conveyable_enter)
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	update_move_direction()
	LAZYADD(GLOB.conveyors_by_id[id], src)
	if(wire_mode)
		update_cable()
		START_PROCESSING(SSmachines, src)

/obj/machinery/conveyor/examine(mob/user)
	. = ..()
	if(inverted)
		. += span_notice("It is currently set to go in reverse.")
	. += "\nLeft-click with a <b>wrench</b> to rotate."
	. += "Left-click with a <b>screwdriver</b> to invert its direction."
	. += "Right-click with a <b>screwdriver</b> to flip its belt around."
	. += "Left-click with a <b>multitool</b> to toggle whether this conveyor receives power via cable. Toggling connects and disconnects."
	. += "Using another <b>conveyor belt assembly</b> on this will place a <b>new conveyor belt<b> in the direction this one is pointing."

/obj/machinery/conveyor/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(istype(held_item, /obj/item/stack/conveyor))
		context[SCREENTIP_CONTEXT_LMB] = "Extend current conveyor belt"
		return CONTEXTUAL_SCREENTIP_SET
	if(held_item?.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "Rotate conveyor belt"
		return CONTEXTUAL_SCREENTIP_SET
	if(held_item?.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "Invert conveyor belt"
		context[SCREENTIP_CONTEXT_RMB] = "Flip conveyor belt"
		return CONTEXTUAL_SCREENTIP_SET
	if(held_item?.tool_behaviour == TOOL_MULTITOOL)
		context[SCREENTIP_CONTEXT_LMB] = "Toggle conveyor belt wire mode"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/conveyor/centcom_auto
	id = "round_end_belt"

/obj/machinery/conveyor/inverted //Directions inverted so you can use different corner pieces.
	icon_state = "conveyor_map_inverted"
	flipped = TRUE

/obj/machinery/conveyor/inverted/Initialize(mapload)
	. = ..()
	if(mapload && !(ISDIAGONALDIR(dir)))
		log_mapping("[src] at [AREACOORD(src)] spawned without using a diagonal dir. Please replace with a normal version.")


// Auto conveyor is always on unless unpowered.
/obj/machinery/conveyor/auto
	processing_flags = START_PROCESSING_ON_INIT

/obj/machinery/conveyor/auto/Initialize(mapload, newdir)
	. = ..()
	set_operating(TRUE)

/obj/machinery/conveyor/auto/update()
	. = ..()
	if(.)
		set_operating(TRUE)

/obj/machinery/conveyor/auto/inverted
	icon_state = "conveyor_map_inverted"
	flipped = TRUE

/obj/machinery/conveyor/post_machine_initialize()
	. = ..()
	build_neighbors()

/obj/machinery/conveyor/Destroy()
	set_operating(FALSE)
	LAZYREMOVE(GLOB.conveyors_by_id[id], src)
	attached_wire_ref = null
	return ..()

/obj/machinery/conveyor/vv_edit_var(var_name, var_value)
	if (var_name == NAMEOF(src, id))
		// if "id" is varedited, update our list membership
		LAZYREMOVE(GLOB.conveyors_by_id[id], src)
		. = ..()
		LAZYADD(GLOB.conveyors_by_id[id], src)
	else
		return ..()

/obj/machinery/conveyor/setDir(newdir)
	. = ..()
	update_move_direction()

/obj/machinery/conveyor/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(!.)
		return
	//Now that we've moved, rebuild our neighbors list
	neighbors = list()
	build_neighbors()

/obj/machinery/conveyor/proc/build_neighbors()
	//This is acceptable because conveyor belts only move sometimes. Otherwise would be n^2 insanity
	var/turf/our_turf = get_turf(src)
	for(var/direction in GLOB.cardinals)
		var/turf/new_turf = get_step(our_turf, direction)
		var/obj/machinery/conveyor/valid = locate(/obj/machinery/conveyor) in new_turf
		if(QDELETED(valid))
			continue
		neighbors["[direction]"] = TRUE
		valid.neighbors["[REVERSE_DIR(direction)]"] = TRUE
		RegisterSignal(valid, COMSIG_MOVABLE_MOVED, PROC_REF(nearby_belt_changed), override=TRUE)
		RegisterSignal(valid, COMSIG_QDELETING, PROC_REF(nearby_belt_changed), override=TRUE)
		valid.RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(nearby_belt_changed), override=TRUE)
		valid.RegisterSignal(src, COMSIG_QDELETING, PROC_REF(nearby_belt_changed), override=TRUE)

/obj/machinery/conveyor/proc/nearby_belt_changed(datum/source)
	SIGNAL_HANDLER
	neighbors = list()
	build_neighbors()

/**
 * Proc to handle updating the directions in which the conveyor belt is moving items.
 */
/obj/machinery/conveyor/proc/update_move_direction()
	switch(dir)
		if(NORTH)
			forwards = NORTH
			backwards = SOUTH
		if(SOUTH)
			forwards = SOUTH
			backwards = NORTH
		if(EAST)
			forwards = EAST
			backwards = WEST
		if(WEST)
			forwards = WEST
			backwards = EAST
		if(NORTHEAST)
			forwards = EAST
			backwards = SOUTH
		if(NORTHWEST)
			forwards = NORTH
			backwards = EAST
		if(SOUTHEAST)
			forwards = SOUTH
			backwards = WEST
		if(SOUTHWEST)
			forwards = WEST
			backwards = NORTH

	if(inverted)
		var/temp = forwards
		forwards = backwards
		backwards = temp
	// We need to do this this way to ensure good functionality on corner belts.
	// Basically, this allows the conveyor belts that used a flipped belt sprite to
	// still convey items in the direction of their arrows. It's different from inverted,
	// which makes them go backwards so they need to be ran separately, so a flipped conveyor
	// can also be reversed.
	if(flipped)
		var/temp = forwards
		forwards = backwards
		backwards = temp
	if(operating == CONVEYOR_FORWARD)
		movedir = forwards
	else
		movedir = backwards
	update()

/obj/machinery/conveyor/update_icon_state()
	icon_state = "[base_icon_state][inverted ? -operating : operating ][flipped ? "-flipped" : ""]"
	return ..()

/obj/machinery/conveyor/proc/set_operating(new_value)
	if(operating == new_value)
		return
	operating = new_value
	update_appearance()
	update_move_direction()
	//If we ever turn off, disable moveloops
	if(operating == CONVEYOR_OFF)
		for(var/atom/movable/movable in get_turf(src))
			stop_conveying(movable)

/obj/machinery/conveyor/proc/update()
	if(machine_stat & NOPOWER)
		set_operating(FALSE)
		return FALSE

	update_appearance()
	// If we're on, start conveying so moveloops on our tile can be refreshed if they stopped for some reason
	if(operating != CONVEYOR_OFF)
		for(var/atom/movable/movable in get_turf(src))
			start_conveying(movable)
	return TRUE

/obj/machinery/conveyor/proc/conveyable_enter(datum/source, atom/movable/convayable)
	SIGNAL_HANDLER
	if(convayable.loc != loc) // If we are not on the same turf (order of operations memes) go to hell
		return
	if(operating == CONVEYOR_OFF)
		GLOB.move_manager.stop_looping(convayable, SSconveyors)
		return
	start_conveying(convayable)

/obj/machinery/conveyor/proc/conveyable_exit(datum/source, atom/convayable, direction)
	SIGNAL_HANDLER
	var/has_conveyor = neighbors["[direction]"]
	if(convayable.z != z || !has_conveyor || !isturf(convayable.loc)) //If you've entered something on us, stop moving
		GLOB.move_manager.stop_looping(convayable, SSconveyors)

/obj/machinery/conveyor/proc/start_conveying(atom/movable/moving)
	if(QDELETED(moving))
		return
	var/datum/move_loop/move/moving_loop = GLOB.move_manager.processing_on(moving, SSconveyors)
	if(moving_loop)
		moving_loop.direction = movedir
		moving_loop.delay = speed * 1 SECONDS
		return

	var/static/list/unconveyables = typecacheof(list(/obj/effect, /mob/dead))
	if(!istype(moving) || is_type_in_typecache(moving, unconveyables) || moving == src)
		return
	moving.AddComponent(/datum/component/convey, movedir, speed * 1 SECONDS)

/obj/machinery/conveyor/proc/stop_conveying(atom/movable/thing)
	if(!ismovable(thing))
		return
	GLOB.move_manager.stop_looping(thing, SSconveyors)

// attack with item, place item on conveyor
/obj/machinery/conveyor/attackby(obj/item/attacking_item, mob/living/user, params)
	if(attacking_item.tool_behaviour == TOOL_CROWBAR)
		user.visible_message(span_notice("[user] struggles to pry up [src] with [attacking_item]."), \
		span_notice("You struggle to pry up [src] with [attacking_item]."))

		if(!attacking_item.use_tool(src, user, 4 SECONDS, volume = 40))
			return
		set_operating(FALSE)
		var/obj/item/stack/conveyor/belt_item = new /obj/item/stack/conveyor(loc, 1, TRUE, null, null, id)
		if(!QDELETED(belt_item)) //God I hate stacks
			transfer_fingerprints_to(belt_item)

		to_chat(user, span_notice("You remove [src]."))
		qdel(src)

	else if(attacking_item.tool_behaviour == TOOL_WRENCH)
		attacking_item.play_tool_sound(src)
		setDir(turn(dir, -45))
		to_chat(user, span_notice("You rotate [src]."))

	else if(attacking_item.tool_behaviour == TOOL_SCREWDRIVER)
		attacking_item.play_tool_sound(src)
		inverted = !inverted
		update_move_direction()
		to_chat(user, span_notice("You set [src]'s direction [inverted ? "backwards" : "back to default"]."))
	else if(attacking_item.tool_behaviour == TOOL_MULTITOOL)
		attacking_item.play_tool_sound(src)
		wire_mode = !wire_mode
		update_cable()
		power_change()
		if(wire_mode)
			START_PROCESSING(SSmachines, src)
		else
			STOP_PROCESSING(SSmachines, src)
		to_chat(user, span_notice("You set [src]'s wire mode [wire_mode ? "on" : "off"]."))
	else if(istype(attacking_item, /obj/item/stack/conveyor))
		// We should place a new conveyor belt machine on the output turf the conveyor is pointing to.
		var/turf/target_turf = get_step(get_turf(src), forwards)
		if(!target_turf)
			return ..()
		for(var/obj/machinery/conveyor/belt in target_turf)
			to_chat(user, span_warning("You cannot place a conveyor belt on top of another conveyor belt."))
			return ..()

		var/obj/item/stack/conveyor/belt_item = attacking_item
		belt_item.use(1)
		new /obj/machinery/conveyor(target_turf, forwards, id)

	else if(!user.combat_mode || (attacking_item.item_flags & NOBLUDGEON))
		user.transferItemToLoc(attacking_item, drop_location())
	else
		return ..()

/obj/machinery/conveyor/attackby_secondary(obj/item/attacking_item, mob/living/user, params)
	if(attacking_item.tool_behaviour == TOOL_SCREWDRIVER)
		attacking_item.play_tool_sound(src)
		flipped = !flipped
		update_move_direction()
		to_chat(user, span_notice("You flip [src]'s belt [flipped ? "around" : "back to normal"]."))

	else if(!user.combat_mode)
		user.transferItemToLoc(attacking_item, drop_location())

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN


// attack with hand, move pulled object onto conveyor
/obj/machinery/conveyor/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	user.Move_Pulled(src)

/obj/machinery/conveyor/powered(chan = power_channel, ignore_use_power = FALSE)
	if(!wire_mode)
		return ..()
	var/datum/powernet/powernet = get_powernet()
	if(!isnull(powernet))
		return clamp(powernet.avail-powernet.load, 0, powernet.avail) >= active_power_usage
	return ..()

/obj/machinery/conveyor/power_change()
	. = ..()
	update()

/obj/machinery/conveyor/process()
	if(!wire_mode)
		return PROCESS_KILL
	if(isnull(attached_wire_ref))
		update_cable()
		return
	var/datum/powernet/powernet = get_powernet()
	if(isnull(powernet))
		return
	if(powered())
		powernet.load += active_power_usage
	else
		power_change()


/obj/machinery/conveyor/proc/update_cable()
	if(!wire_mode)
		attached_wire_ref = null
		return
	var/turf/our_turf = get_turf(src)
	attached_wire_ref = WEAKREF(locate(/obj/structure/cable) in our_turf)
	if(attached_wire_ref)
		return power_change()

/obj/machinery/conveyor/proc/get_powernet()
	if(!wire_mode)
		return
	var/obj/structure/cable/cable = attached_wire_ref.resolve()
	if(isnull(cable))
		attached_wire_ref = null
		return
	return cable.powernet

// Conveyor switch
/obj/machinery/conveyor_switch
	name = "conveyor switch"
	desc = "A conveyor control switch."
	icon = 'icons/obj/machines/recycling.dmi'
	icon_state = "switch-off"
	base_icon_state = "switch"
	processing_flags = START_PROCESSING_MANUALLY

	/// The current state of the switch.
	var/position = CONVEYOR_OFF
	/// If the switch only operates the conveyor belts in a single direction.
	var/oneway = FALSE
	/// If the level points the opposite direction when it's turned on.
	var/invert_icon = FALSE
	/// The ID of the switch, must match conveyor IDs to control them.
	var/id = ""
	/// The set time between movements of the conveyor belts
	var/conveyor_speed = 0.2

/obj/machinery/conveyor_switch/Initialize(mapload, newid)
	. = ..()
	if (newid)
		id = newid

	update_appearance()
	LAZYADD(GLOB.conveyors_by_id[id], src)
	set_wires(new /datum/wires/conveyor(src))
	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/conveyor_switch,
	))
	register_context()

/obj/machinery/conveyor_switch/Destroy()
	LAZYREMOVE(GLOB.conveyors_by_id[id], src)
	return ..()

/obj/machinery/conveyor_switch/vv_edit_var(var_name, var_value)
	if (var_name == NAMEOF(src, id))
		// if "id" is varedited, update our list membership
		LAZYREMOVE(GLOB.conveyors_by_id[id], src)
		. = ..()
		LAZYADD(GLOB.conveyors_by_id[id], src)

	else
		return ..()

// update the icon depending on the position
/obj/machinery/conveyor_switch/update_icon_state()
	icon_state = "[base_icon_state]-off"
	if(position < CONVEYOR_OFF)
		icon_state = "[base_icon_state]-[invert_icon ? "fwd" : "rev"]"
	else if(position > CONVEYOR_OFF)
		icon_state = "[base_icon_state]-[invert_icon ? "rev" : "fwd"]"
	return ..()

/obj/machinery/conveyor_switch/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(!held_item)
		context[SCREENTIP_CONTEXT_LMB] = "Toggle forwards"
		if(!oneway)
			context[SCREENTIP_CONTEXT_RMB] = "Toggle backwards"
		return CONTEXTUAL_SCREENTIP_SET
	if(held_item.tool_behaviour == TOOL_MULTITOOL)
		context[SCREENTIP_CONTEXT_LMB] = "Set speed"
		context[SCREENTIP_CONTEXT_RMB] = "View wires"
		return CONTEXTUAL_SCREENTIP_SET
	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "Toggle oneway"
		return CONTEXTUAL_SCREENTIP_SET
	if(held_item.tool_behaviour == TOOL_CROWBAR)
		context[SCREENTIP_CONTEXT_LMB] = "Detach"
		return CONTEXTUAL_SCREENTIP_SET
	if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "Invert"
		return CONTEXTUAL_SCREENTIP_SET

/// Updates all conveyor belts that are linked to this switch, and tells them to start processing.
/obj/machinery/conveyor_switch/proc/update_linked_conveyors()
	for(var/obj/machinery/conveyor/belt in GLOB.conveyors_by_id[id])
		belt.set_operating(position)
		belt.speed = conveyor_speed
		CHECK_TICK

/// Finds any switches with same `id` as this one, and set their position and icon to match us.
/obj/machinery/conveyor_switch/proc/update_linked_switches()
	for(var/obj/machinery/conveyor_switch/belt_switch in GLOB.conveyors_by_id[id])
		belt_switch.invert_icon = invert_icon
		belt_switch.position = position
		belt_switch.conveyor_speed = conveyor_speed
		belt_switch.update_appearance()
		CHECK_TICK

/// Updates the switch's `position` and `last_pos` variable. Useful so that the switch can properly cycle between the forwards, backwards and neutral positions.
/obj/machinery/conveyor_switch/proc/update_position(direction)
	if(position == CONVEYOR_OFF)
		playsound(src, 'sound/machines/lever/lever_start.ogg', 40, TRUE)

		if(oneway)   //is it a oneway switch
			position = oneway
		else
			if(direction == CONVEYOR_FORWARD)
				position = CONVEYOR_FORWARD
			else
				position = CONVEYOR_BACKWARDS
	else
		playsound(src, 'sound/machines/lever/lever_stop.ogg', 40, TRUE)
		position = CONVEYOR_OFF

/obj/machinery/conveyor_switch/proc/on_user_activation(mob/user, direction)
	add_fingerprint(user)
	update_position(direction)
	update_appearance()
	update_linked_conveyors()
	update_linked_switches()

/// Called when a user clicks on this switch with an open hand.
/obj/machinery/conveyor_switch/attack_hand(mob/user, list/modifiers)
	. = ..()
	on_user_activation(user, CONVEYOR_FORWARD)

/obj/machinery/conveyor_switch/attack_hand_secondary(mob/user, list/modifiers)
	on_user_activation(user, CONVEYOR_BACKWARDS)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/conveyor_switch/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/conveyor_switch/attack_ai_secondary(mob/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)

/obj/machinery/conveyor_switch/attack_robot(mob/user)
	return attack_hand(user)

/obj/machinery/conveyor_switch/attack_robot_secondary(mob/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)

/obj/machinery/conveyor_switch/attackby(obj/item/attacking_item, mob/user, params)
	if(is_wire_tool(attacking_item))
		wires.interact(user)
		return TRUE

/obj/machinery/conveyor_switch/multitool_act(mob/living/user, obj/item/I)
	var/input_speed = tgui_input_number(user, "Set the speed of the conveyor belts in seconds", "Speed", conveyor_speed, 20, 0.2, round_value = FALSE)
	if(!input_speed || QDELETED(user) || QDELETED(src) || !usr.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	conveyor_speed = input_speed
	to_chat(user, span_notice("You change the time between moves to [input_speed] seconds."))
	update_linked_conveyors()
	return TRUE

/obj/machinery/conveyor_switch/crowbar_act(mob/user, obj/item/tool)
	tool.play_tool_sound(src, 50)
	var/obj/item/conveyor_switch_construct/switch_construct = new/obj/item/conveyor_switch_construct(src.loc)
	switch_construct.id = id
	transfer_fingerprints_to(switch_construct)
	to_chat(user, span_notice("You detach [src]."))
	qdel(src)
	return TRUE

/obj/machinery/conveyor_switch/screwdriver_act(mob/user, obj/item/tool)
	tool.play_tool_sound(src, 50)
	oneway = !oneway
	to_chat(user, span_notice("You set [src] to [oneway ? "one way" : "default"] configuration."))
	return TRUE

/obj/machinery/conveyor_switch/wrench_act(mob/user, obj/item/tool)
	tool.play_tool_sound(src, 50)
	invert_icon = !invert_icon
	update_appearance()
	to_chat(user, span_notice("You set [src] to [invert_icon ? "inverted": "normal"] position."))
	return TRUE

/obj/machinery/conveyor_switch/examine(mob/user)
	. = ..()
	. += span_notice("[src] is set to [oneway ? "one way" : "default"] configuration. It can be changed with a <b>screwdriver</b>.")
	. += span_notice("[src] is set to [invert_icon ? "inverted": "normal"] position. It can be rotated with a <b>wrench</b>.")
	. += span_notice("[src] is set to move [conveyor_speed] seconds per belt. It can be changed with a <b>multitool</b>.")

/obj/machinery/conveyor_switch/oneway
	icon_state = "conveyor_switch_oneway"
	desc = "A conveyor control switch. It appears to only go in one direction."
	oneway = TRUE

/obj/machinery/conveyor_switch/oneway/Initialize(mapload)
	. = ..()
	if((dir == NORTH) || (dir == WEST))
		invert_icon = TRUE

/obj/item/conveyor_switch_construct
	name = "conveyor switch assembly"
	desc = "A conveyor control switch assembly."
	icon = 'icons/obj/machines/recycling.dmi'
	icon_state = "switch-off"
	w_class = WEIGHT_CLASS_BULKY
	// ID of the switch-in-the-making, to link conveyor belts to it.
	var/id = ""

/obj/item/conveyor_switch_construct/Initialize(mapload)
	. = ..()
	id = "[rand()]" //this couldn't possibly go wrong

/obj/item/conveyor_switch_construct/attack_self(mob/user)
	for(var/obj/item/stack/conveyor/belt in view())
		belt.id = id
	to_chat(user, span_notice("You have linked all nearby conveyor belt assemblies to this switch."))

/obj/item/conveyor_switch_construct/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isfloorturf(interacting_with))
		return NONE

	var/found = FALSE
	for(var/obj/machinery/conveyor/belt in view())
		if(belt.id == src.id)
			found = TRUE
			break
	if(!found)
		to_chat(user, "[icon2html(src, user)]" + span_notice("The conveyor switch did not detect any linked conveyor belts in range."))
		return ITEM_INTERACT_BLOCKING
	var/obj/machinery/conveyor_switch/built_switch = new/obj/machinery/conveyor_switch(interacting_with, id)
	transfer_fingerprints_to(built_switch)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/item/stack/conveyor
	name = "conveyor belt assembly"
	desc = "A conveyor belt assembly."
	icon = 'icons/obj/machines/recycling.dmi'
	icon_state = "conveyor_construct"
	max_amount = 30
	singular_name = "conveyor belt"
	w_class = WEIGHT_CLASS_BULKY
	merge_type = /obj/item/stack/conveyor
	/// ID for linking a belt to one or more switches, all conveyors with the same ID will be controlled the same switch(es).
	var/id = ""

/obj/item/stack/conveyor/Initialize(mapload, new_amount, merge = TRUE, list/mat_override=null, mat_amt=1, _id)
	. = ..()
	id = _id

/obj/item/stack/conveyor/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isfloorturf(interacting_with))
		return NONE
	var/belt_dir = get_dir(interacting_with, user)
	if(interacting_with == user.loc)
		to_chat(user, span_warning("You cannot place a conveyor belt under yourself!"))
		return ITEM_INTERACT_BLOCKING
	var/obj/machinery/conveyor/belt = new/obj/machinery/conveyor(interacting_with, belt_dir, id)
	transfer_fingerprints_to(belt)
	use(1)
	return ITEM_INTERACT_SUCCESS

/obj/item/stack/conveyor/attackby(obj/item/item_used, mob/user, params)
	..()
	if(istype(item_used, /obj/item/conveyor_switch_construct))
		to_chat(user, span_notice("You link the switch to the conveyor belt assembly."))
		var/obj/item/conveyor_switch_construct/switch_construct = item_used
		id = switch_construct.id

/obj/item/stack/conveyor/update_weight()
	return FALSE

/obj/item/stack/conveyor/examine(mob/user)
	. = ..()
	. += span_notice("Use a conveyor switch assembly on this before placing to connect to a lever.")

/obj/item/stack/conveyor/use(used, transfer, check)
	. = ..()
	playsound(src, 'sound/items/weapons/genhit.ogg', 30, TRUE)

/obj/item/stack/conveyor/thirty
	amount = 30

/obj/item/paper/guides/conveyor
	name = "paper- 'Nano-it-up U-build series, #9: Build your very own conveyor belt, in SPACE'"
	default_raw_text = "<h1>Congratulations!</h1><p>You are now the proud owner of the best conveyor set available for \
		space mail order! We at Nano-it-up know you love to prepare your own structures without wasting time, \
		so we have devised a special streamlined assembly procedure that puts all other mail-order products to \
		shame!</p><p>Firstly, you need to link the conveyor switch assembly to each of the conveyor belt \
		assemblies. After doing so, you simply need to install the belt assemblies onto the floor, et voila, \
		belt built. Our special Nano-it-up smart switch will detected any linked assemblies as far as the eye \
		can see! This convenience, you can only have it when you Nano-it-up. Stay nano!</p>"

#undef MAX_CONVEYOR_ITEMS_MOVE

/obj/item/circuit_component/conveyor_switch
	display_name = "Conveyor Switch"
	desc = "Allows to control connected conveyor belts."

	/// Direction input ports.
	var/datum/port/input/stop
	var/datum/port/input/active
	var/datum/port/input/reverse
	/// The current direction of the conveyor attached to the component.
	var/datum/port/output/direction
	/// The switch this conveyor switch component is attached to.
	var/obj/machinery/conveyor_switch/attached_switch

/obj/item/circuit_component/conveyor_switch/populate_ports()
	active = add_input_port("Activate", PORT_TYPE_SIGNAL, trigger = PROC_REF(activate))
	stop = add_input_port("Stop", PORT_TYPE_SIGNAL, trigger = PROC_REF(stop))
	direction = add_output_port("Conveyor Direction", PORT_TYPE_NUMBER)

/obj/item/circuit_component/conveyor_switch/get_ui_notices()
	. = ..()
	. += create_ui_notice("Conveyor direction 0 means that it is stopped, 1 means that it is active and -1 means that it is working in reverse mode", "orange", "info")

/obj/item/circuit_component/conveyor_switch/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/conveyor_switch))
		attached_switch = shell
		if(!attached_switch.oneway)
			reverse = add_input_port("Reverse", PORT_TYPE_SIGNAL, trigger = PROC_REF(reverse))

/obj/item/circuit_component/conveyor_switch/unregister_usb_parent(atom/movable/shell)
	attached_switch = null
	return ..()

/obj/item/circuit_component/conveyor_switch/proc/on_switch_changed()
	attached_switch.update_appearance()
	attached_switch.update_linked_conveyors()
	attached_switch.update_linked_switches()
	direction.set_output(attached_switch.position)

/obj/item/circuit_component/conveyor_switch/proc/activate()
	SIGNAL_HANDLER
	attached_switch.position = CONVEYOR_FORWARD
	INVOKE_ASYNC(src, PROC_REF(on_switch_changed))

/obj/item/circuit_component/conveyor_switch/proc/stop()
	SIGNAL_HANDLER
	attached_switch.position = CONVEYOR_OFF
	INVOKE_ASYNC(src, PROC_REF(on_switch_changed))

/obj/item/circuit_component/conveyor_switch/proc/reverse()
	SIGNAL_HANDLER
	attached_switch.position = CONVEYOR_BACKWARDS
	INVOKE_ASYNC(src, PROC_REF(on_switch_changed))

#undef CONVEYOR_BACKWARDS
#undef CONVEYOR_OFF
#undef CONVEYOR_FORWARD

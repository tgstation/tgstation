/datum/component/plumbing
	dupe_mode = COMPONENT_DUPE_ALLOWED
	///Index with "1" = /datum/ductnet/theductpointingnorth etc. "1" being the num2text from NORTH define
	var/list/datum/ductnet/ducts = list()
	///shortcut to our parents' reagent holder
	var/datum/reagents/reagents
	///TRUE if we wanna add proper pipe overlays under our parent object. this is pretty good if i may so so myself
	var/use_overlays = TRUE
	///Whether our tile is covered and we should hide our ducts
	var/tile_covered = FALSE
	///directions in wich we act as a supplier
	var/supply_connects
	///direction in wich we act as a demander
	var/demand_connects
	///FALSE to pretty much just not exist in the plumbing world so we can be moved, TRUE to go plumbo mode
	var/active = FALSE
	///if TRUE connects will spin with the parent object visually and codually, so you can have it work in any direction. FALSE if you want it to be static
	var/turn_connects = TRUE
	///The layer on which we connect. Don't add multiple. If you want multiple layer connects for some reason you can just add multiple components with different layers
	var/ducting_layer = DUCT_LAYER_DEFAULT
	///In-case we don't want the main machine to get the reagents, but perhaps whoever is buckled to it
	var/recipient_reagents_holder
	///What color is our demand connect?
	var/demand_color = COLOR_RED
	///What color is our supply connect?
	var/supply_color = COLOR_BLUE
	///Extend the pipe to the edge for wall-mounted plumbed devices, like sinks and showers
	var/extend_pipe_to_edge = FALSE

///turn_connects is for wheter or not we spin with the object to change our pipes
/datum/component/plumbing/Initialize(start=TRUE, ducting_layer, turn_connects=TRUE, datum/reagents/custom_receiver, extend_pipe_to_edge = FALSE)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	if(ducting_layer)
		src.ducting_layer = ducting_layer

	var/atom/movable/parent_movable = parent
	if(!parent_movable.reagents && !custom_receiver)
		return COMPONENT_INCOMPATIBLE

	reagents = parent_movable.reagents
	src.turn_connects = turn_connects
	src.extend_pipe_to_edge = extend_pipe_to_edge

	set_recipient_reagents_holder(custom_receiver ? custom_receiver : parent_movable.reagents)

	if(start)
		//We're registering here because I need to check whether we start active or not, and this is just easier
		//Should be called after we finished. Done this way because other networks need to finish setting up aswell
		RegisterSignal(parent, COMSIG_COMPONENT_ADDED, PROC_REF(enable))

/datum/component/plumbing/RegisterWithParent()
	RegisterSignals(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING), PROC_REF(disable))
	RegisterSignals(parent, list(COMSIG_OBJ_DEFAULT_UNFASTEN_WRENCH), PROC_REF(toggle_active))
	RegisterSignal(parent, COMSIG_OBJ_HIDE, PROC_REF(hide))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(create_overlays)) //called by lateinit on startup
	RegisterSignal(parent, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_parent_dir_change)) //called when placed on a shuttle and it moves, and other edge cases
	RegisterSignal(parent, COMSIG_MOVABLE_CHANGE_DUCT_LAYER, PROC_REF(change_ducting_layer))

/datum/component/plumbing/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_OBJ_DEFAULT_UNFASTEN_WRENCH, COMSIG_OBJ_HIDE, \
	COMSIG_ATOM_UPDATE_OVERLAYS, COMSIG_ATOM_DIR_CHANGE, COMSIG_MOVABLE_CHANGE_DUCT_LAYER, COMSIG_COMPONENT_ADDED))
	REMOVE_TRAIT(parent, TRAIT_UNDERFLOOR, REF(src))

/datum/component/plumbing/Destroy()
	ducts = null
	reagents = null
	set_recipient_reagents_holder(null) //null is there so it's obvious we're setting this to nothing
	return ..()

/datum/component/plumbing/process()
	if(!demand_connects || !reagents)
		return PROCESS_KILL

	if(!reagents.holder_full())
		for(var/D in GLOB.cardinals)
			if(D & demand_connects)
				send_request(D)

///Can we be added to the ductnet?
/datum/component/plumbing/proc/can_add(datum/ductnet/ductnet, dir)
	if(!active)
		return
	if(!dir || !ductnet)
		return FALSE
	if(num2text(dir) in ducts)
		return FALSE

	return TRUE

///called from in process(). only calls process_request(), but can be overwritten for children with special behaviour
/datum/component/plumbing/proc/send_request(dir)
	process_request(dir = dir)

///check who can give us what we want, and how many each of them will give us
/datum/component/plumbing/proc/process_request(amount = MACHINE_REAGENT_TRANSFER, reagent, dir)
	//find the duct to take from
	var/datum/ductnet/net
	if(!ducts.Find(num2text(dir)))
		return FALSE
	net = ducts[num2text(dir)]

	//find all valid suppliers in the duct
	var/list/valid_suppliers = list()
	for(var/datum/component/plumbing/supplier as anything in net.suppliers)
		if(supplier.can_give(amount, reagent, net))
			valid_suppliers += supplier
	var/suppliersLeft = valid_suppliers.len
	if(!suppliersLeft)
		return FALSE

	//take an equal amount from each supplier
	var/currentRequest
	var/target_volume = reagents.total_volume + amount
	for(var/datum/component/plumbing/give as anything in valid_suppliers)
		currentRequest = (target_volume - reagents.total_volume) / suppliersLeft
		give.transfer_to(src, currentRequest, reagent, net)
		suppliersLeft--
	return TRUE

///returns TRUE when they can give the specified amount and reagent. called by process request
/datum/component/plumbing/proc/can_give(amount, reagent, datum/ductnet/net)
	if(amount <= 0)
		return

	if(reagent) //only asked for one type of reagent
		for(var/datum/reagent/contained_reagent as anything in reagents.reagent_list)
			if(contained_reagent.type == reagent)
				return TRUE
	else if(reagents.total_volume) //take whatever
		return TRUE

	return FALSE

///this is where the reagent is actually transferred and is thus the finish point of our process()
/datum/component/plumbing/proc/transfer_to(datum/component/plumbing/target, amount, reagent, datum/ductnet/net)
	if(!reagents || !target || !target.reagents)
		return FALSE

	reagents.trans_to(target.recipient_reagents_holder, amount, target_id = reagent)

///We create our luxurious piping overlays/underlays, to indicate where we do what. only called once if use_overlays = TRUE in Initialize()
/datum/component/plumbing/proc/create_overlays(atom/movable/parent_movable, list/overlays)
	SIGNAL_HANDLER

	if(tile_covered || !use_overlays)
		return

	//Copied from ducts handle_layer()
	var/offset

	switch(ducting_layer)
		if(FIRST_DUCT_LAYER)
			offset = -10
		if(SECOND_DUCT_LAYER)
			offset = -5
		if(THIRD_DUCT_LAYER)
			offset = 0
		if(FOURTH_DUCT_LAYER)
			offset = 5
		if(FIFTH_DUCT_LAYER)
			offset = 10

	var/duct_x = offset - parent_movable.pixel_x - parent_movable.pixel_w
	var/duct_y = offset - parent_movable.pixel_y - parent_movable.pixel_z
	var/duct_layer = PLUMBING_PIPE_VISIBILE_LAYER + ducting_layer * 0.0003
	var/extension_handled = FALSE

	for(var/direction in GLOB.cardinals)
		var/color
		if(direction & initial(demand_connects))
			color = demand_color
		else if(direction & initial(supply_connects))
			color = supply_color
		else
			continue

		var/direction_text = dir2text(direction)

		var/image/overlay
		if(turn_connects)
			overlay = image('icons/obj/pipes_n_cables/hydrochem/connects.dmi', "[direction_text]-[ducting_layer]", layer = duct_layer)
		else
			overlay = image('icons/obj/pipes_n_cables/hydrochem/connects.dmi', "[direction_text]-[ducting_layer]-s", layer = duct_layer)
			overlay.dir = direction

		overlay.color = color
		overlay.pixel_x = duct_x
		overlay.pixel_y = duct_y

		overlays += overlay

		// This is a little wiggley extension to make wallmounts like sinks and showers visually link to the pipe
		if(extend_pipe_to_edge && !extension_handled)
			var/image/edge_overlay = image('icons/obj/pipes_n_cables/hydrochem/connects.dmi', "edge-extension", layer = duct_layer)
			edge_overlay.dir = parent_movable.dir
			edge_overlay.color = color
			edge_overlay.pixel_x = -parent_movable.pixel_x - parent_movable.pixel_w
			edge_overlay.pixel_y = -parent_movable.pixel_y - parent_movable.pixel_z
			overlays += edge_overlay
			// only show extension for the first pipe. This means we'll only reflect that color.
			extension_handled = TRUE

///we stop acting like a plumbing thing and disconnect if we are, so we can safely be moved and stuff
/datum/component/plumbing/proc/disable()
	SIGNAL_HANDLER

	if(!active)
		return

	STOP_PROCESSING(SSplumbing, src)

	//remove_plumber() can remove all ducts at once if they all belong to the same pipenet
	//for e.g. in case of circular connections
	//so we check if we have ducts to remove after each iteration
	while(ducts.len)
		var/datum/ductnet/duct = ducts[ducts[1]] //for maps index 1 will return the 1st key
		duct.remove_plumber(src)

	active = FALSE

	for(var/direction in GLOB.cardinals)
		if(!(direction & (demand_connects | supply_connects)))
			continue
		for(var/obj/machinery/duct/duct in get_step(parent, direction))
			if(!(duct.duct_layer & ducting_layer))
				continue
			duct.remove_connects(REVERSE_DIR(direction))
			duct.neighbours.Remove(parent)
			duct.update_appearance()

///settle wherever we are, and start behaving like a piece of plumbing
/datum/component/plumbing/proc/enable(obj/object, datum/component/component)
	SIGNAL_HANDLER
	if(active || (component && component != src))
		UnregisterSignal(parent, list(COMSIG_COMPONENT_ADDED))
		return

	update_dir()
	active = TRUE

	var/atom/movable/parent_movable = parent
	// Destroy any ducts under us on the same layer.
	// Ducts also self-destruct if placed under a plumbing machine.
	// Machines disable when they get moved
	for(var/obj/machinery/duct/duct in parent_movable.loc)
		if(duct.anchored && (duct.duct_layer & ducting_layer))
			duct.disconnect_duct()

	if(demand_connects)
		START_PROCESSING(SSplumbing, src)

	for(var/direction in GLOB.cardinals)
		if(!(direction & (demand_connects | supply_connects)))
			continue
		for(var/atom/movable/found_atom in get_step(parent, direction))
			if(istype(found_atom, /obj/machinery/duct))
				var/obj/machinery/duct/duct = found_atom
				duct.attempt_connect()
				continue

			for(var/datum/component/plumbing/plumber as anything in found_atom.GetComponents(/datum/component/plumbing))
				if(plumber.ducting_layer & ducting_layer)
					direct_connect(plumber, direction)

/// Toggle our machinery on or off. This is called by a hook from default_unfasten_wrench with anchored as only param, so we dont have to copypaste this on every object that can move
/datum/component/plumbing/proc/toggle_active(obj/parent_obj, new_state)
	SIGNAL_HANDLER
	// Follow atmos's rule of exposing the connection if you unwrench it and only hiding again if tile is placed back down.
	if(tile_covered)
		tile_covered = FALSE
		parent_obj.update_appearance()

	if(new_state)
		enable()
	else
		disable()

/** We update our connects only when we settle down by taking our current and original direction to find our new connects
* If someone wants it to fucking spin while connected to something go actually knock yourself out
*/
/datum/component/plumbing/proc/update_dir()
	if(!turn_connects)
		return

	var/atom/movable/AM = parent
	var/new_demand_connects
	var/new_supply_connects
	var/new_dir = AM.dir
	var/angle = 180 - dir2angle(new_dir)

	if(new_dir == SOUTH)
		demand_connects = initial(demand_connects)
		supply_connects = initial(supply_connects)
	else
		for(var/direction in GLOB.cardinals)
			if(direction & initial(demand_connects))
				new_demand_connects += turn(direction, angle)
			if(direction & initial(supply_connects))
				new_supply_connects += turn(direction, angle)
		demand_connects = new_demand_connects
		supply_connects = new_supply_connects

///Give the direction of a pipe, and it'll return wich direction it originally was when it's object pointed SOUTH
/datum/component/plumbing/proc/get_original_direction(dir)
	var/atom/movable/parent_movable = parent
	return turn(dir, dir2angle(parent_movable.dir) - 180)

//special case in-case we want to connect directly with another machine without a duct
/datum/component/plumbing/proc/direct_connect(datum/component/plumbing/plumbing, dir)
	if(!plumbing.active)
		return
	var/opposite_dir = REVERSE_DIR(dir)
	if(plumbing.demand_connects & opposite_dir && supply_connects & dir || plumbing.supply_connects & opposite_dir && demand_connects & dir) //make sure we arent connecting two supplies or demands
		var/datum/ductnet/net = new()
		net.add_plumber(src, dir)
		net.add_plumber(plumbing, opposite_dir)

/datum/component/plumbing/proc/hide(atom/movable/parent_obj, underfloor_accessibility)
	SIGNAL_HANDLER

	// If machine is unanchored, keep connector visible.
	// This doesn't necessary map to `active`, so check parent.
	var/atom/movable/parent_movable = parent

	var/should_hide = !underfloor_accessibility

	if(should_hide)
		ADD_TRAIT(parent_obj, TRAIT_UNDERFLOOR, REF(src))
	else
		REMOVE_TRAIT(parent_obj, TRAIT_UNDERFLOOR, REF(src))

	if(parent_movable.anchored || !should_hide)
		tile_covered = should_hide
		parent_obj.update_appearance()

/datum/component/plumbing/proc/change_ducting_layer(obj/caller, obj/changer, new_layer = DUCT_LAYER_DEFAULT)
	SIGNAL_HANDLER
	ducting_layer = new_layer

	var/atom/movable/parent_movable = parent
	parent_movable.update_appearance()

	if(changer)
		playsound(changer, 'sound/items/ratchet.ogg', 10, TRUE) //sound

	//quickly disconnect and reconnect the network.
	if(active)
		disable()
		enable()

/datum/component/plumbing/proc/set_recipient_reagents_holder(datum/reagents/receiver)
	if(recipient_reagents_holder)
		UnregisterSignal(recipient_reagents_holder, COMSIG_QDELETING) //stop tracking whoever we were tracking
	if(receiver)
		RegisterSignal(receiver, COMSIG_QDELETING, PROC_REF(handle_reagent_del)) //on deletion call a wrapper proc that clears us, and maybe reagents too

	recipient_reagents_holder = receiver

/datum/component/plumbing/proc/handle_reagent_del(datum/source)
	SIGNAL_HANDLER
	if(source == reagents)
		reagents = null
	if(source == recipient_reagents_holder)
		set_recipient_reagents_holder(null)

/**
 * Called when the dir changes. Need to adjust positioning of pipes.
 */
/datum/component/plumbing/proc/on_parent_dir_change(atom/movable/parent_obj, old_dir, new_dir)
	SIGNAL_HANDLER

	if(old_dir == new_dir)
		return

	// Defer to later frame because pixel_* is actually updated after all callbacks
	addtimer(CALLBACK(parent_obj, TYPE_PROC_REF(/atom/, update_appearance)), 0.1 SECONDS)

///has one pipe input that only takes, example is manual output pipe
/datum/component/plumbing/simple_demand
	demand_connects = SOUTH

///has one pipe output that only supplies. example is liquid pump and manual input pipe
/datum/component/plumbing/simple_supply
	supply_connects = SOUTH

///input and output, like a holding tank
/datum/component/plumbing/tank
	demand_connects = WEST
	supply_connects = EAST

/datum/component/plumbing/manifold
	demand_connects = NORTH
	supply_connects = SOUTH

/datum/component/plumbing/manifold/change_ducting_layer(obj/caller, obj/changer, new_layer)
	return

#define READY 2
///Baby component for the buffer plumbing machine
/datum/component/plumbing/buffer
	demand_connects = WEST
	supply_connects = EAST

/datum/component/plumbing/buffer/Initialize(start=TRUE, _turn_connects=TRUE, _ducting_layer, datum/reagents/custom_receiver)
	if(!istype(parent, /obj/machinery/plumbing/buffer))
		return COMPONENT_INCOMPATIBLE

	return ..()

/datum/component/plumbing/buffer/can_give(amount, reagent, datum/ductnet/net)
	var/obj/machinery/plumbing/buffer/buffer = parent
	return (buffer.mode == READY) ? ..() : FALSE

#undef READY

///Lazily demand from any direction. Overlays won't look good, and the aquarium sprite occupies about the entire 32x32 area anyway.
/datum/component/plumbing/aquarium
	demand_connects = SOUTH|NORTH|EAST|WEST
	use_overlays = FALSE

/datum/component/plumbing
	dupe_mode = COMPONENT_DUPE_ALLOWED
	///Index with "1" = /datum/ductnet/theductpointingnorth etc. "1" being the num2text from NORTH define
	var/list/datum/ductnet/ducts
	///shortcut to our parents' reagent holder. The holder that sends reagents into the pipeline
	var/datum/reagents/reagents
	///Whether our tile is covered and we should hide our ducts
	var/tile_covered = FALSE
	///directions in wich we act as a supplier
	var/supply_connects = NONE
	///direction in wich we act as a demander
	var/demand_connects = NONE
	///The layer on which we connect. Don't add multiple. If you want multiple layer connects for some reason you can just add multiple components with different layers
	var/ducting_layer = DUCT_LAYER_DEFAULT
	///What color is our demand connect?
	var/demand_color = COLOR_RED
	///What color is our supply connect?
	var/supply_color = COLOR_BLUE
	/// How many distinct reagents can we accept at once
	/// Ex - if this was set to "3", our component would only request the first 3 reagents found, even if more are available
	var/distinct_reagent_cap = INFINITY

///turn_connects is for wheter or not we spin with the object to change our pipes
/datum/component/plumbing/Initialize(ducting_layer)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	var/atom/movable/parent_movable = parent
	if(!parent_movable.reagents)
		return COMPONENT_INCOMPATIBLE

	if(GLOB.plumbing_layer_names["[ducting_layer]"])
		src.ducting_layer = ducting_layer

	ducts = list()

	reagents = parent_movable.reagents

	if(parent_movable.anchored)
		enable()

/datum/component/plumbing/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(disable))
	RegisterSignal(parent, COMSIG_OBJ_DEFAULT_UNFASTEN_WRENCH, PROC_REF(toggle_active))
	RegisterSignal(parent, COMSIG_OBJ_HIDE, PROC_REF(hide))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(create_overlays)) //called by lateinit on startup
	RegisterSignal(parent, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_parent_dir_change)) //called when placed on a shuttle and it moves, and other edge cases
	RegisterSignal(parent, COMSIG_MOVABLE_CHANGE_DUCT_LAYER, PROC_REF(change_ducting_layer))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/plumbing/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_OBJ_DEFAULT_UNFASTEN_WRENCH,
		COMSIG_OBJ_HIDE,
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_ATOM_DIR_CHANGE,
		COMSIG_MOVABLE_CHANGE_DUCT_LAYER,
		COMSIG_ATOM_EXAMINE,
	))

/datum/component/plumbing/Destroy()
	disable()
	ducts.Cut()
	reagents = null
	return ..()

///Returns if the machine is active or not
/datum/component/plumbing/proc/active()
	var/atom/movable/parent_movable = parent
	return parent_movable.anchored

///Returns the reagent holder meant to receive the reagents. Can be different from the one that sends reagents to the network
/datum/component/plumbing/proc/recipient_reagents_holder()
	return reagents

///Give the direction of a pipe, and it'll return wich direction it originally was when its object pointed SOUTH
/datum/component/plumbing/proc/get_original_direction(dir)
	if(!dir)
		return 0
	var/atom/movable/parent_movable = parent
	return turn(dir, dir2angle(parent_movable.dir) - 180)

///settle wherever we are, and start behaving like a piece of plumbing
/datum/component/plumbing/proc/enable()
	var/atom/movable/parent_movable = parent

	//We update our connects only when we settle down by taking our current and original direction to find our new connects

	demand_connects = initial(demand_connects)
	supply_connects = initial(supply_connects)
	if(parent_movable.dir != SOUTH)
		var/angle = 180 - dir2angle(parent_movable.dir)
		var/new_demand_connects = NONE
		var/new_supply_connects = NONE
		for(var/direction in GLOB.cardinals)
			if(direction & demand_connects)
				new_demand_connects |= turn(direction, angle)
			if(direction & supply_connects)
				new_supply_connects |= turn(direction, angle)
		demand_connects = new_demand_connects
		supply_connects = new_supply_connects

	if(demand_connects)
		START_PROCESSING(SSplumbing, src)

	for(var/direction in GLOB.cardinals)
		if(!(direction & (demand_connects | supply_connects)))
			continue

		var/opposite_dir = REVERSE_DIR(direction)
		for(var/atom/movable/found_atom in get_step(parent, direction))
			var/obj/machinery/duct/duct = found_atom
			if(istype(duct))
				if(duct.neighbours && (duct.duct_layer & ducting_layer))
					duct.neighbours[parent] = opposite_dir
					duct.update_appearance(UPDATE_ICON_STATE)
					duct.net.add_plumber(src, direction)
				continue

			for(var/datum/component/plumbing/plumber as anything in found_atom.GetComponents(/datum/component/plumbing))
				if(plumber.active() && (plumber.ducting_layer & ducting_layer))
					if((plumber.demand_connects & opposite_dir) && (supply_connects & direction) || (plumber.supply_connects & opposite_dir) && (demand_connects & direction)) //make sure we arent connecting two supplies or demands
						var/datum/ductnet/net = new
						net.add_plumber(src, direction)
						net.add_plumber(plumber, opposite_dir)

/datum/component/plumbing/proc/disable()
	SIGNAL_HANDLER

	STOP_PROCESSING(SSplumbing, src)

	while(ducts.len)
		var/datum/ductnet/net = ducts[ducts[1]]

		//disconnect ourself from any ducts connected to us
		for(var/obj/machinery/duct/pipe as anything in net.ducts)
			if(pipe.neighbours[parent])
				pipe.neighbours -= parent
				pipe.update_appearance()

		//remove ourself from this network and delete it if emtpy
		if(net.remove_plumber(src))
			qdel(net)

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

/datum/component/plumbing/proc/hide(atom/movable/parent_obj, underfloor_accessibility)
	SIGNAL_HANDLER

	var/atom/movable/parent_movable = parent
	// If machine is unanchored, keep connector visible.
	// This doesn't necessary map to `active`, so check parent.
	var/should_hide = !underfloor_accessibility
	if(parent_movable.anchored || !should_hide)
		tile_covered = should_hide
		parent_obj.update_appearance()

/datum/component/plumbing/proc/create_overlays(atom/movable/parent_movable, list/overlays)
	SIGNAL_HANDLER

	if(tile_covered)
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

	for(var/direction in GLOB.cardinals)
		var/color
		if(direction & initial(demand_connects))
			color = demand_color
		else if(direction & initial(supply_connects))
			color = supply_color
		else
			continue

		var/image/overlay = image('icons/obj/pipes_n_cables/hydrochem/connects.dmi', "[dir2text(direction)]-[ducting_layer]", layer = duct_layer)
		overlay.color = color
		overlay.pixel_w = duct_x
		overlay.pixel_z = duct_y
		overlays += overlay

/datum/component/plumbing/proc/on_parent_dir_change(atom/movable/parent_obj, old_dir, new_dir)
	SIGNAL_HANDLER

	if(old_dir == new_dir)
		return

	// Defer to later frame because pixel_* is actually updated after all callbacks
	addtimer(CALLBACK(parent_obj, TYPE_PROC_REF(/atom/, update_appearance)), 0.1 SECONDS)

/datum/component/plumbing/proc/change_ducting_layer(obj/source, obj/changer, new_layer = DUCT_LAYER_DEFAULT)
	SIGNAL_HANDLER

	ducting_layer = new_layer
	var/atom/movable/parent_movable = parent
	parent_movable.update_appearance()

	if(changer)
		playsound(changer, 'sound/items/tools/ratchet.ogg', 10, TRUE) //sound

	//quickly disconnect and reconnect the network.
	if(active())
		disable()
		enable()

/datum/component/plumbing/process()
	if(!demand_connects)
		return PROCESS_KILL

	var/datum/reagents/receiver = recipient_reagents_holder()
	if(QDELETED(receiver))
		return PROCESS_KILL

	if(!receiver.holder_full())
		for(var/dir in GLOB.cardinals)
			if(dir & demand_connects)
				send_request(dir)

/datum/component/plumbing/proc/on_examine(atom/movable/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(distinct_reagent_cap != INFINITY)
		examine_list += span_notice("This plumbing component will only accept up to [distinct_reagent_cap] distinct reagents at once.")

///called from in process(). only calls process_request(), but can be overwritten for children with special behaviour
/datum/component/plumbing/proc/send_request(dir)
	var/amount_to_give = MACHINE_REAGENT_TRANSFER
	// infinite cap means we need to special handling, process_request will just grab as much as it wants.
	if(distinct_reagent_cap == INFINITY)
		process_request(amount_to_give, null, dir) // null for no specific reagent, we're not picky.
		return

	// we have a cap, so we need to figure out what reagents we want
	var/list/all_allowed_reagents = get_all_network_reagents(ducts["[dir]"])
	if(length(all_allowed_reagents) > distinct_reagent_cap)
		all_allowed_reagents.Cut(distinct_reagent_cap + 1)
	else if(!length(all_allowed_reagents))
		return

	// request an even amount of each allowed reagent
	var/amount_per_reagent = round(amount_to_give / length(all_allowed_reagents), CHEMICAL_VOLUME_ROUNDING)
	for(var/allowed_reagent in all_allowed_reagents)
		process_request(amount_per_reagent, allowed_reagent, dir)

/// Returns a list of all distinct reagent types available in the passed duct network.
/// The passed net can be null, it is handled.
/datum/component/plumbing/proc/get_all_network_reagents(datum/ductnet/net)
	var/list/distinct_reagents = list()
	for(var/datum/reagent/existing_regent as anything in reagents.reagent_list)
		distinct_reagents |= existing_regent.type
	for(var/datum/component/plumbing/supplier as anything in net?.suppliers)
		for(var/datum/reagent/chemical as anything in supplier.reagents.reagent_list)
			distinct_reagents |= chemical.type
	return distinct_reagents

///check who can give us what we want, and how many each of them will give us
/datum/component/plumbing/proc/process_request(amount = MACHINE_REAGENT_TRANSFER, reagent, dir, round_robin = TRUE)
	//find the duct to take from
	var/dirtext = num2text(dir)
	var/datum/ductnet/net = ducts[dirtext]
	if(QDELETED(net))
		if(net)
			ducts -= dirtext
		return FALSE

	//find all valid suppliers in the duct
	var/list/valid_suppliers = list()
	for(var/datum/component/plumbing/supplier as anything in net?.suppliers)
		if(supplier.can_give(amount, reagent, net))
			valid_suppliers += supplier
	var/suppliersLeft = length(valid_suppliers)
	if(!suppliersLeft)
		return FALSE

	//take an equal amount from each supplier
	var/currentRequest
	var/target_volume = reagents.total_volume + amount
	for(var/datum/component/plumbing/give as anything in valid_suppliers)
		currentRequest = (target_volume - reagents.total_volume) / suppliersLeft
		give.transfer_to(src, currentRequest, reagent, net, round_robin)
		suppliersLeft--
	return TRUE

///returns TRUE when they can give the specified amount and reagent. called by process request
/datum/component/plumbing/proc/can_give(amount, reagent, datum/ductnet/net)
	SHOULD_BE_PURE(TRUE)

	if(amount <= 0)
		return FALSE

	if(reagent) //only asked for one type of reagent
		return reagents.has_reagent(reagent)
	else if(reagents.total_volume) //take whatever
		return TRUE

	return FALSE

///this is where the reagent is actually transferred and is thus the finish point of our process()
/datum/component/plumbing/proc/transfer_to(datum/component/plumbing/target, amount, reagent, datum/ductnet/net, round_robin = TRUE)
	reagents.trans_to(target.recipient_reagents_holder(), amount, target_id = reagent, methods = round_robin ? LINEAR : NONE)

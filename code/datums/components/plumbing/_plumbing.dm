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

	on_parent_dir_change(parent_movable, NONE, parent_movable.dir)
	if(parent_movable.anchored)
		if(PERFORM_ALL_TESTS(maptest_log_mapping))
			var/datum/overlap = ducting_layer_check(parent_movable, ducting_layer)
			if(!isnull(overlap))
				var/message = GLOB.plumbing_layer_names["[ducting_layer]"]
				if(istype(overlap, /obj/machinery/duct))
					message = "plumbing duct on [message]"
				else
					message = "plumbing machine on [message]"
				log_mapping("Overlapping [message] detected at [AREACOORD(parent_movable)]")
				parent_movable.set_anchored(FALSE)
				return
		enable()

/datum/component/plumbing/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_WRENCH), PROC_REF(check_wrench))
	RegisterSignal(parent, COMSIG_MOVABLE_SET_ANCHORED, PROC_REF(toggle_active))
	RegisterSignal(parent, COMSIG_OBJ_HIDE, PROC_REF(hide))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(create_overlays))
	RegisterSignal(parent, COMSIG_ATOM_POST_DIR_CHANGE, PROC_REF(on_parent_dir_change))
	RegisterSignal(parent, COMSIG_MOVABLE_CHANGE_DUCT_LAYER, PROC_REF(change_ducting_layer))

/datum/component/plumbing/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_TOOL_ACT(TOOL_WRENCH),
		COMSIG_MOVABLE_SET_ANCHORED,
		COMSIG_OBJ_HIDE,
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_ATOM_POST_DIR_CHANGE,
		COMSIG_MOVABLE_CHANGE_DUCT_LAYER,
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

///settle wherever we are, and start behaving like a piece of plumbing
/datum/component/plumbing/proc/enable()
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
						net.pipeline.maximum_volume = DUCT_VOLUME
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
				pipe.update_appearance(UPDATE_ICON_STATE)

		//remove ourself from this network and delete it if emtpy
		if(net.remove_plumber(src))
			qdel(net)

/datum/component/plumbing/proc/check_wrench(obj/parent_obj, mob/user, tool, processing_recipes)
	SIGNAL_HANDLER

	if(!active())
		var/datum/overlap = ducting_layer_check(parent_obj)
		if(!isnull(overlap))
			parent_obj.balloon_alert(user, "overlapping [istype(overlap, /obj/machinery/duct) ? "duct" : "machine"] detected!")
			return ITEM_INTERACT_FAILURE

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

	demand_connects = initial(demand_connects)
	supply_connects = initial(supply_connects)
	if(new_dir != SOUTH)
		var/angle = 180 - dir2angle(new_dir)
		var/new_demand_connects = NONE
		var/new_supply_connects = NONE
		for(var/direction in GLOB.cardinals)
			if(direction & demand_connects)
				new_demand_connects |= turn(direction, angle)
			if(direction & supply_connects)
				new_supply_connects |= turn(direction, angle)
		demand_connects = new_demand_connects
		supply_connects = new_supply_connects

	if(length(ducts))
		disable()
		enable()

/datum/component/plumbing/proc/change_ducting_layer(obj/source, obj/changer, new_layer = DUCT_LAYER_DEFAULT)
	SIGNAL_HANDLER

	ducting_layer = new_layer
	source.update_appearance(UPDATE_OVERLAYS)

	if(changer)
		playsound(changer, 'sound/items/tools/ratchet.ogg', 10, TRUE) //sound

	if(length(ducts))
		disable()
		enable()

/datum/component/plumbing/process()
	var/obj/machinery/target = parent
	if(istype(target) && !target.is_operational)
		return
	var/work_done = FALSE

	var/datum/reagents/receiver = recipient_reagents_holder()
	for(var/dir in GLOB.cardinals)
		if(!receiver.holder_full() && (dir & demand_connects) && send_request(dir))
			work_done = TRUE

		if(reagents.total_volume && (dir & supply_connects) && supply_demand(dir))
			work_done = TRUE

	if(istype(target) && work_done)
		target.use_energy(target.active_power_usage * 0.15)

///Returns a ductnet based on the requested direction
/datum/component/plumbing/proc/net(dir)
	PRIVATE_PROC(TRUE)
	RETURN_TYPE(/datum/ductnet)

	var/dirtext = num2text(dir)
	var/datum/ductnet/net = ducts[dirtext]
	if(QDELETED(net))
		if(net)
			ducts -= dirtext
		net = null

	return net

///Request reagents from an specific direction. Override in child types
/datum/component/plumbing/proc/send_request(dir)
	return process_request(MACHINE_REAGENT_TRANSFER, dir = dir)

///Does the actual work of transferring reagents from the pipeline to this machines recipient holder
/datum/component/plumbing/proc/process_request(amount = MACHINE_REAGENT_TRANSFER, reagent, dir, round_robin = TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)

	var/datum/ductnet/net = net(dir)
	if(net)
		return net.pipeline.trans_to(recipient_reagents_holder(), amount, target_id = reagent, methods = round_robin ? LINEAR : NONE)

///Send reagents in an specific direction. Override in child types
/datum/component/plumbing/proc/supply_demand(dir)
	return process_demand(MACHINE_REAGENT_TRANSFER, dir = dir)

///Does the actual work of transferring reagents to the pipeline from this machines reagent holder
/datum/component/plumbing/proc/process_demand(amount = MACHINE_REAGENT_TRANSFER, reagent, dir, round_robin = TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)

	var/datum/ductnet/net = net(dir)
	if(net)
		net.pipeline.my_atom = parent

		for(var/obj/machinery/duct/pipe as anything in net.ducts)
			if(pipe.neighbours[parent] == dir)
				net.pipeline.my_atom = pipe
				break

		return reagents.trans_to(net.pipeline, amount, target_id = reagent, methods = round_robin ? LINEAR : NONE, no_react = TRUE)

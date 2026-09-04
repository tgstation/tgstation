/// Component that handles stationary node behavior for the Candela mining navigation network
/datum/component/candela_node
	/// Network we're connected to
	var/datum/mining_beacon_network/network = null
	/// List of beam visuals we're using for connections
	var/list/beam_visuals = list()
	/// X offset for our beam connection point
	var/connection_pixel_x = null
	/// Y offset for our beam connection point
	var/connection_pixel_y = null
	/// Is this node a valid network power source? If yes, what type?
	var/power_flags = NONE
	/// Can this node be teleported to using fultons?
	var/fulton_point = FALSE

/datum/component/candela_node/Initialize(datum/mining_beacon_network/new_network = null, datum/candela_item_handler/deployer = null, connection_pixel_x = null, connection_pixel_y = null, power_flags = NONE, fulton_point = FALSE)
	. = ..()
	if (!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.connection_pixel_x = connection_pixel_x
	src.connection_pixel_y = connection_pixel_y
	src.power_flags = power_flags
	src.fulton_point = fulton_point

	set_network(new_network)
	if (!QDELETED(deployer))
		deployer.set_network(network, src)

/datum/component/candela_node/Destroy(force)
	set_network(null, update = FALSE)
	return ..()

/datum/component/candela_node/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_item_interaction))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ATOM_MOD_MODULE_USED, PROC_REF(on_module_used))

/datum/component/candela_node/proc/on_examine(atom/movable/source, mob/viewer, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("[source.p_Theyre()] a \"Candela\" mining navigation node, capable of syncronizing various prospecting machinery and equipment, and repelling hostile fauna.")
	if (power_flags & CANDELA_NETWORK_BOOSTED)
		examine_list += span_notice("[source.p_They()] additionally act[source.p_s()] as an energy booster for the network, [power_flags & CANDELA_NETWORK_POWERED ? "keeping all connected beacons and equipment active and " : ""]increasing ore vent outputs.")
	else if (power_flags & CANDELA_NETWORK_POWERED)
		examine_list += span_notice("[source.p_They()] additionally act[source.p_s()] as a power source for the network, keeping all connected beacons and equipment active.")
	else
		examine_list += span_notice("The network is currently [(network.powered & CANDELA_NETWORK_POWERED) ? "fully operational[(network.powered & CANDELA_NETWORK_BOOSTED) ? " and overclocked" : ""]" : "missing a power source"].")

/datum/component/candela_node/proc/on_item_interaction(atom/movable/source, mob/living/user, obj/item/tool, list/modifiers)
	SIGNAL_HANDLER

	if (!istype(tool, /obj/item/stack/candela_beacon))
		return NONE

	var/obj/item/stack/candela_beacon/beacon = tool
	beacon.handler.set_network(network, src)
	beacon.balloon_alert(user, "network linked!")
	return ITEM_INTERACT_SUCCESS

/datum/component/candela_node/proc/on_module_used(atom/movable/source, obj/item/mod/module/module)
	SIGNAL_HANDLER

	if (!istype(module, /obj/item/mod/module/candela_spool))
		return NONE

	var/obj/item/mod/module/candela_spool/spool = module
	if (!spool.mod.wearer.Adjacent(parent))
		return NONE

	spool.handler.set_network(network, src)
	spool.mod.wearer.balloon_alert(spool.mod.wearer, "network linked!")
	return COMPONENT_INTERRUPT_MODULE_USE

/datum/component/candela_node/proc/set_network(datum/mining_beacon_network/new_network, merging = FALSE, update = TRUE, separating = FALSE)
	if (network == new_network)
		return

	. = network
	if (network && !separating && !merging)
		network.remove_node(src)
	network = new_network
	// Before add_node, as network can change from merging
	SEND_SIGNAL(parent, COMSIG_CANDELA_NODE_NETWORK_CHANGED, ., network)

	if (network)
		network.add_node(src, merging = merging)

	if (update)
		update_connections()

/// Refresh visual connections of our node
/// - keep_links: Forces a redraw of all beams rather than a full recalculation of all links
/datum/component/candela_node/proc/update_connections(keep_links = FALSE)
	if (!network)
		QDEL_LIST_ASSOC_VAL(beam_visuals)
		return

	var/list/draw_to = null
	var/our_index = network.linked_nodes.Find(src)
#ifdef TESTING
	var/atom/movable/as_atom = parent
	as_atom.maptext = MAPTEXT("[our_index] - [GLOB.mining_beacon_networks.Find(network)]")
#endif
	if (keep_links)
		draw_to = assoc_to_keys(beam_visuals)
		QDEL_LIST_ASSOC_VAL(beam_visuals)
	else
		var/list/linked_to = network.linked_nodes[src]
		draw_to = linked_to.Copy()
		var/turf/our_turf = get_turf(parent)
		for (var/datum/component/candela_node/link_node as anything in linked_to)
			var/turf/link_turf = get_turf(link_node.parent)
			var/link_index = network.linked_nodes.Find(link_node)
			// Don't render connections to shared nodes if there's another one that's closer to them than us (in case of equal distance, use index)
			for (var/datum/component/candela_node/shared_node as anything in (draw_to & link_node.beam_visuals))
				var/our_dist = get_dist_euclidean(get_turf(shared_node.parent), our_turf)
				var/link_dist = get_dist_euclidean(get_turf(shared_node.parent), link_turf)
				if (our_dist > link_dist || our_dist == link_dist && link_index < our_index)
					draw_to -= shared_node

	for (var/lost_node, old_beam in beam_visuals - draw_to)
		beam_visuals -= lost_node
		qdel(old_beam)

	var/atom/movable/movable_parent = parent
	for (var/datum/component/candela_node/new_node as anything in draw_to - beam_visuals)
		if (network.linked_nodes.Find(new_node) < our_index) // Older nodes draw connections to younger ones
			continue
		beam_visuals[new_node] = movable_parent.Beam(
			new_node.parent,
			"1-full",
			'icons/effects/beam.dmi',
			beam_color = LIGHT_COLOR_MINING,
			emissive = EMISSIVE_BLOOM,
			override_origin_pixel_x = connection_pixel_x,
			override_origin_pixel_y = connection_pixel_y,
			override_target_pixel_x = new_node.connection_pixel_x,
			override_target_pixel_y = new_node.connection_pixel_y,
			emissive_alpha = (network.powered & CANDELA_NETWORK_BOOSTED) ? 255 : 192,
			alpha = (network.powered & CANDELA_NETWORK_POWERED) ? 192 : 128
		)

// Costly, but should not be called often (if at all) as all nodes should be anchored
/datum/component/candela_node/proc/on_moved(atom/movable/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	var/list/located_nodes = list()
	var/list/atoms_to_nodes = list()

	for (var/datum/mining_beacon_network/network as anything in GLOB.mining_beacon_networks)
		for (var/datum/component/candela_node/node as anything in network.linked_nodes)
			atoms_to_nodes[node.parent] = node

	// We use can_see rather than view() because view() is not a raycast and can end up putting beams through walls, as it sees around corners in a weird fasion
	var/list/our_links = network.linked_nodes[src]
	for (var/datum/component/candela_node/other_node as anything in our_links)
		if (can_see(parent, other_node.parent, MINING_BEACON_MAX_REACH) || can_see(other_node.parent, parent, MINING_BEACON_MAX_REACH))
			located_nodes |= other_node

	if (length(located_nodes))
		// No nodes were cut, don't do anything
		if (length(our_links) == length(located_nodes))
			return
		// Otherwise, cut ourselves from the network and try to link back to refresh connections or find another one
		var/datum/mining_beacon_network/old_network = network
		set_network(null)
		set_network(old_network)
		return

	// Otherwise, go through all (nearby, can_see checks get_dist) nodes looking for matches
	var/min_dist = MINING_BEACON_MAX_REACH + 1
	var/datum/component/candela_node/secondary_node = null
	for (var/atom/movable/thing as anything in atoms_to_nodes)
		var/node_dist = get_dist_euclidean(thing, parent)
		if (node_dist >= min_dist)
			continue

		if (!can_see(parent, thing, MINING_BEACON_MAX_REACH) && !can_see(thing, parent, MINING_BEACON_MAX_REACH))
			continue

		min_dist = node_dist
		secondary_node = atoms_to_nodes[thing]

	set_network(null)
	if (secondary_node)
		set_network(secondary_node.network)

/// List of all mining beacon networks for easy connection lookups
GLOBAL_LIST_EMPTY(mining_beacon_networks)

/// Candela beacon network datum
/datum/mining_beacon_network
	/// List of all beacon nodes within our network (node -> its connections)
	var/list/datum/component/candela_node/linked_nodes = list()
	/// List of beacon items tracking our network
	var/list/datum/candela_item_handler/linked_beacon_items = list()
	/// List of mobs currently attached to the network via handler items for centralized movement tracking (mob -> all handlers on them)
	var/list/mob/living/linked_mobs = list()
	/// What types of power providers we have in the network
	var/powered = NONE

/datum/mining_beacon_network/New()
	. = ..()
	GLOB.mining_beacon_networks += src

/datum/mining_beacon_network/Destroy(force)
	linked_nodes.Cut()
	for (var/datum/candela_item_handler/handler as anything in linked_beacon_items)
		handler.locate_closest_network()
	linked_beacon_items.Cut()
	linked_mobs.Cut()
	GLOB.mining_beacon_networks -= src
	return ..()

/// Refresh our power state, returns previous power state
/datum/mining_beacon_network/proc/update_power()
	. = powered
	var/new_state = NONE
	for (var/datum/component/candela_node/power_node as anything in linked_nodes)
		new_state |= power_node.power_flags

	set_powered_state(new_state)

/datum/mining_beacon_network/proc/add_node(datum/component/candela_node/new_node, merging = FALSE)
	if (linked_nodes[new_node])
		return

	linked_nodes[new_node] = list()
	if (!(new_node.power_flags & powered))
		set_powered_state(powered | new_node.power_flags)

	if (merging)
		return

	var/list/all_nodes = list()
	var/list/atoms_to_nodes = list()
	for (var/datum/mining_beacon_network/network as anything in GLOB.mining_beacon_networks)
		for (var/datum/component/candela_node/node as anything in network.linked_nodes)
			all_nodes[node] = network
			atoms_to_nodes[node.parent] = node

	var/list/merged_networks = list()
	var/list/need_updates = list(new_node)
	for (var/atom/movable/thing in view(MINING_BEACON_MAX_REACH, new_node.parent))
		var/datum/component/candela_node/actual_node = atoms_to_nodes[thing]
		if (!actual_node || actual_node == new_node)
			continue

		// Need a can_see check to avoid beams going through walls
		if (!can_see(thing, new_node.parent, MINING_BEACON_MAX_REACH) && !can_see(new_node.parent, thing, MINING_BEACON_MAX_REACH))
			continue

		if (linked_nodes[actual_node])
			linked_nodes[new_node] |= actual_node
			linked_nodes[actual_node] |= new_node
			need_updates |= actual_node
			continue

		if (!all_nodes[actual_node])
			continue

		var/datum/mining_beacon_network/network = all_nodes[actual_node]
		linked_nodes[new_node] |= actual_node
		network.linked_nodes[actual_node] |= new_node
		need_updates |= actual_node

		merged_networks |= network

	if (!length(merged_networks))
		for (var/datum/component/candela_node/update_node as anything in need_updates)
			update_node.update_connections()
		return

	// Merge ourselves into the closest network, then merge all other located networks into it as well
	// Significantly reduces churn when placing new beacons
	var/datum/mining_beacon_network/first_net = merged_networks[1]
	first_net.merge_network(src)

	for (var/datum/mining_beacon_network/network as anything in merged_networks - first_net)
		first_net.merge_network(network)

	for (var/datum/component/candela_node/update_node as anything in need_updates)
		update_node.update_connections()

/datum/mining_beacon_network/proc/merge_network(datum/mining_beacon_network/to_merge)
	for (var/datum/component/candela_node/node as anything in to_merge.linked_nodes)
		node.set_network(src, merging = TRUE, update = FALSE)

	for (var/datum/candela_item_handler/beacon as anything in to_merge.linked_beacon_items)
		beacon.set_network(src, merging = TRUE)

	for (var/node, connections in to_merge.linked_nodes)
		if (linked_nodes[node])
			linked_nodes[node] |= connections
		else
			linked_nodes[node] = connections

	linked_beacon_items |= to_merge.linked_beacon_items

	for (var/datum/component/candela_node/node as anything in to_merge.linked_nodes)
		node.update_connections()

	qdel(to_merge)

/datum/mining_beacon_network/proc/remove_node(datum/component/candela_node/node)
	if (!linked_nodes[node])
		return

	if (length(linked_nodes) == 1)
		qdel(src)
		return

	var/list/connections = linked_nodes[node]
	if (length(connections) == 1) // End node, no need to run separation calculations
		var/datum/component/candela_node/other_node = connections[1]
		linked_nodes[other_node] -= node
		linked_nodes -= node
		other_node.update_connections()
		// If this node was potentially powering us, check if we lost any power sources
		if (node.power_flags & powered)
			update_power()
		return

	linked_nodes -= node
	for (var/datum/component/candela_node/other_node as anything in connections)
		// Network cut?
		if (linked_nodes[other_node])
			linked_nodes[other_node] -= node

	// If the network wasn't separated, just update connected nodes
	// Otherwise, check_network_separation will handle updates for us
	if (!check_network_separation(connections))
		for (var/datum/component/candela_node/other_node as anything in connections)
			other_node.update_connections()

	// We might've lost more than one node from this
	if (powered)
		update_power()

/datum/mining_beacon_network/proc/set_powered_state(new_power_state)
	if (powered == new_power_state)
		return
	. = powered
	powered = new_power_state
	for (var/datum/component/candela_node/node as anything in linked_nodes)
		node.update_connections(keep_links = TRUE)
	SEND_SIGNAL(src, COMSIG_CANDELA_NETWORK_POWER_CHANGED, ., powered)

/// Try to reassemble the network in case of possible separation
/// Node that caused separation should already be removed from linked_nodes
/// Returns FALSE if the network was not split, TRUE if it was
/// - connections - List of all connections of the node that caused the separation.
/datum/mining_beacon_network/proc/check_network_separation(list/connections)
	var/list/new_networks = list()
	var/list/polled_nodes = list()
	for (var/datum/component/candela_node/primary_node as anything in connections)
		// We've reached this node from another primary one, ignore
		if (primary_node in polled_nodes)
			continue

		var/list/node_pool = list(primary_node)
		var/index = 1
		// Breadth-first parse all nodes connected from our primary node to see which ones it can connect to
		while (index <= length(node_pool))
			var/datum/component/candela_node/link_node = node_pool[index]
			node_pool |= linked_nodes[link_node]
			index += 1

		var/list/new_net = list()
		for (var/datum/component/candela_node/new_net_node as anything in node_pool)
			new_net[new_net_node] = linked_nodes[new_net_node]

		new_networks += list(new_net)
		polled_nodes |= node_pool

	// No separation occured, ignore
	if (length(new_networks) <= 1)
		return FALSE

	linked_nodes = new_networks[1]
	var/list/all_nodes = linked_nodes.Copy()
	for (var/i in 2 to length(new_networks))
		var/list/other_net = new_networks[i]
		var/datum/mining_beacon_network/new_net = new()
		new_net.linked_nodes = other_net
		all_nodes |= other_net
		for (var/datum/component/candela_node/other_node as anything in other_net)
			// Doesn't actually run add_node code as we already "added" the nodes above, so we don't do pointless merging checks
			other_node.set_network(new_net, update = FALSE, separating = TRUE)
		new_net.update_power()

	update_power()

	// Force a full connection recalculation on all nodes in the network
	for (var/datum/component/candela_node/node as anything in all_nodes)
		node.update_connections()

	for (var/datum/candela_item_handler/beacon as anything in linked_beacon_items)
		beacon.locate_closest_network()
	return TRUE

/datum/mining_beacon_network/proc/link_mob(datum/candela_item_handler/handler, mob/living/new_user)
	if (!linked_mobs[new_user])
		linked_mobs[new_user] = list()
		RegisterSignal(new_user, COMSIG_MOB_CLIENT_MOVED, PROC_REF(on_user_moved))
	linked_mobs[new_user] |= handler

/datum/mining_beacon_network/proc/unlink_mob(datum/candela_item_handler/handler, mob/living/user)
	linked_mobs[user] -= handler
	if (length(linked_mobs[user]))
		return
	linked_mobs -= user
	UnregisterSignal(user, COMSIG_MOB_CLIENT_MOVED)

/// A mob linked to the network moved, check if they still can connect to us and if not, check if any handlers object and then cut the connection
/datum/mining_beacon_network/proc/on_user_moved(mob/living/source, direction, old_dir, atom/old_loc)
	SIGNAL_HANDLER

	var/turf/new_loc = source.loc
	var/list/all_handlers = linked_mobs[source]
	// Check if this was a valid step with no teleportation involved
	if (!isturf(new_loc) || !isturf(old_loc) || get_step(old_loc, direction) != new_loc)
		for (var/datum/candela_item_handler/handler as anything in all_handlers)
			handler.set_network(null)
		return

	var/datum/component/candela_node/current_closest = null
	var/datum/candela_item_handler/master = all_handlers[1]
	var/datum/component/candela_node/closest_node = master.closest_node
	if (closest_node && (can_see(source, closest_node.parent, MINING_BEACON_MAX_REACH) || can_see(closest_node.parent, source, MINING_BEACON_MAX_REACH)))
		current_closest = closest_node

	for (var/datum/component/candela_node/network_node as anything in linked_nodes)
		if (network_node == closest_node || get_dist_euclidean(get_turf(network_node.parent), new_loc) > MINING_BEACON_MAX_REACH)
			continue

		if (current_closest && get_dist_euclidean(new_loc, get_turf(network_node.parent)) >= get_dist_euclidean(new_loc, get_turf(current_closest.parent)))
			continue

		// Need a can_see rather than viewers() to avoid beams going through walls
		if (can_see(source, network_node.parent, MINING_BEACON_MAX_REACH) || can_see(network_node.parent, source, MINING_BEACON_MAX_REACH))
			current_closest = network_node

	if (current_closest)
		if (current_closest == closest_node)
			return
		for (var/datum/candela_item_handler/handler as anything in all_handlers)
			handler.set_closest_node(current_closest)
		return

	var/interrupt = FALSE
	for (var/datum/candela_item_handler/handler as anything in all_handlers)
		if (handler.on_network_cut_callback?.Invoke(old_loc, old_dir, interrupt))
			interrupt = TRUE

	if (interrupt)
		return

	for (var/datum/candela_item_handler/handler as anything in all_handlers)
		handler.set_network(null)
	source.balloon_alert(source, "connection lost!")

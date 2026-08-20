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

/datum/component/candela_node/Initialize(datum/mining_beacon_network/new_network = null, obj/item/stack/candela_beacon/beacon_stack = null, connection_pixel_x = null, connection_pixel_y = null, power_flags = NONE)
	. = ..()
	if (!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.connection_pixel_x = connection_pixel_x
	src.connection_pixel_y = connection_pixel_y
	src.power_flags = power_flags

	set_network(new_network)
	if (beacon_stack)
		beacon_stack.set_network(network)
		beacon_stack.set_closest_node(src)

/datum/component/candela_node/Destroy(force)
	set_network(null)
	return ..()

/datum/component/candela_node/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_item_interaction))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/candela_node/proc/on_examine(atom/movable/source, mob/viewer, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("[source.p_Theyre()] a \"Candela\" mining navigation node, capable of syncronizing various prospecting machinery and equipment, and repelling hostile fauna.")
	if (power_flags & CANDELA_NETWORK_BOOSTED)
		examine_list += span_notice("[source.p_They()] additionally act[source.p_s()] as an energy booster for the network, [power_flags & CANDELA_NETWORK_POWERED ? "keeping all connected beacons and equipment active and " : ""]increasing ore vent outputs.")
	else if (power_flags & CANDELA_NETWORK_POWERED)
		examine_list += span_notice("[source.p_They()] additionally act[source.p_s()] as a power source for the network, keeping all connected beacons and equipment active.")
	else
		examine_list += span_notice("The network is currently [(network.powered & CANDELA_NETWORK_POWERED) ? "fully operational" : "missing a power source"].")

/datum/component/candela_node/proc/on_item_interaction(atom/movable/source, mob/living/user, obj/item/tool, list/modifiers)
	SIGNAL_HANDLER

	if (!istype(tool, /obj/item/stack/candela_beacon))
		return NONE

	var/obj/item/stack/candela_beacon/beacon = tool
	beacon.set_network(network)
	beacon.set_closest_node(src)
	beacon.balloon_alert(user, "network linked!")
	return ITEM_INTERACT_SUCCESS

/datum/component/candela_node/proc/set_network(datum/mining_beacon_network/new_network, merging = FALSE, destroying = FALSE)
	if (network == new_network)
		return

	. = network
	if (network)
		network.remove_node(src)
	network = new_network
	// Before add_node, as network can change from merging
	SEND_SIGNAL(parent, COMSIG_CANDELA_NODE_NETWORK_CHANGED, ., network)

	if (network)
		network.add_node(src, merging = merging)

	if (!destroying)
		update_connections()

/datum/component/candela_node/proc/update_connections(keep_links = FALSE)
	if (!network)
		QDEL_LIST_ASSOC_VAL(beam_visuals)
		return

	var/list/draw_to = null
	var/our_index = network.linked_nodes.Find(src)
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
			emissive_alpha = 192,
			alpha = (network.powered & CANDELA_NETWORK_POWERED) ? 192 : 128
		)

// Costly, but should not be called often (if at all) as all nodes should be anchored
/datum/component/candela_node/proc/on_moved(atom/movable/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	var/list/located_nodes = list()
	var/list/atoms_to_nodes = list()
	var/datum/component/candela_node/secondary_node = null

	for (var/datum/mining_beacon_network/network as anything in GLOB.mining_beacon_networks)
		for (var/datum/component/candela_node/node as anything in network.linked_nodes)
			atoms_to_nodes[node.parent] = node

	for (var/atom/movable/thing in view(MINING_BEACON_MAX_REACH, parent))
		if (thing in network.linked_nodes[src])
			located_nodes += thing
		else if (!secondary_node)
			secondary_node = atoms_to_nodes[thing]

	// No nodes were cut, don't do anything
	if (length(network.linked_nodes[src]) == length(located_nodes))
		return

	// Otherwise, cut ourselves from the network and try to link back to refresh connections or find another one
	var/datum/mining_beacon_network/old_network = network
	set_network(null)
	if (length(located_nodes))
		set_network(old_network)
	else if (secondary_node)
		set_network(secondary_node.network)

/// List of all mining beacon networks for easy connection lookups
GLOBAL_LIST_EMPTY(mining_beacon_networks)

/// Candela beacon network datum
/datum/mining_beacon_network
	/// List of all beacon nodes within our network -> their connections
	var/list/datum/component/candela_node/linked_nodes = list()
	/// List of beacon items tracking our network
	var/list/obj/item/stack/candela_beacon/linked_beacon_items = list()
	/// What types of power providers we have in the network
	var/powered = NONE

/datum/mining_beacon_network/New()
	. = ..()
	GLOB.mining_beacon_networks += src

/datum/mining_beacon_network/Destroy(force)
	linked_nodes.Cut()
	linked_beacon_items.Cut()
	GLOB.mining_beacon_networks -= src
	return ..()

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
	var/list/need_updates = list()
	for (var/atom/movable/thing in view(MINING_BEACON_MAX_REACH, new_node.parent))
		var/datum/component/candela_node/actual_node = atoms_to_nodes[thing]
		if (!actual_node || actual_node == new_node)
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

	for (var/datum/component/candela_node/update_node as anything in need_updates)
		update_node.update_connections()

	if (!length(merged_networks))
		return

	// Merge ourselves into the closest network, then merge all other located networks into it as well
	// Significantly reduces churn when placing new beacons
	var/datum/mining_beacon_network/first_net = merged_networks[1]
	first_net.merge_network(src)

	for (var/datum/mining_beacon_network/network as anything in merged_networks - first_net)
		first_net.merge_network(network)

/datum/mining_beacon_network/proc/merge_network(datum/mining_beacon_network/to_merge)
	for (var/datum/component/candela_node/node as anything in to_merge.linked_nodes + to_merge.linked_beacon_items)
		node.set_network(src, merging = TRUE)

	for (var/node, connections in to_merge.linked_nodes)
		if (linked_nodes[node])
			linked_nodes[node] |= connections
		else
			linked_nodes[node] = connections

	linked_beacon_items |= to_merge.linked_beacon_items
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

		if (!(node.power_flags & powered) || !powered)
			return

		var/new_state = NONE
		for (var/datum/component/candela_node/power_node as anything in linked_nodes)
			new_state |= power_node.power_flags

		set_powered_state(new_state)
		return

	for (var/datum/component/candela_node/other_node as anything in connections)
		linked_nodes[other_node] -= node
		other_node.update_connections()

	linked_nodes -= node
	check_network_separation(connections)

	if (!powered)
		return

	var/new_state = NONE
	for (var/datum/component/candela_node/power_node as anything in linked_nodes)
		new_state |= power_node.power_flags

	set_powered_state(new_state)

/datum/mining_beacon_network/proc/set_powered_state(new_power_state)
	if (powered == new_power_state)
		return
	. = powered
	powered = new_power_state
	for (var/datum/component/candela_node/node as anything in linked_nodes)
		node.update_connections(keep_links = TRUE)
	SEND_SIGNAL(src, COMSIG_CANDELA_NETWORK_POWER_CHANGED, ., powered)

/// Try to reassemble the network in case of possible separation
/// - connections - List of all connections of the node that caused the separation
/datum/mining_beacon_network/proc/check_network_separation(list/connections)
	var/list/new_networks = list()
	var/list/polling_nodes = connections.Copy()
	var/index = 1
	while (index <= length(polling_nodes))
		var/datum/component/candela_node/to_poll = polling_nodes[index]
		polling_nodes |= linked_nodes[to_poll]
		index += 1
		var/list/connected_to = list()
		for (var/i in 1 to length(new_networks))
			var/list/new_net = new_networks[i]
			if (new_net[to_poll])
				connected_to += i

		if (!length(connected_to))
			var/list/new_net = list()
			new_net[to_poll] = TRUE
			new_networks += list(new_net)
			continue

		var/list/first_net = new_networks[connected_to[1]]
		first_net[to_poll] = TRUE
		if (length(connected_to) == 1)
			continue

		var/list/new_nets = new_networks.Copy()
		for (var/i in 2 to length(connected_to))
			var/list/merged_net = new_networks[connected_to[i]]
			first_net |= merged_net
			new_nets -= merged_net

		new_networks = new_nets

	// If we contain any nodes that somehow weren't polled, cut them into a separate cluster
	var/list/missing_nodes = polling_nodes - linked_nodes
	if (length(missing_nodes))
		var/list/new_net = list()
		for (var/missed_node in missing_nodes)
			new_net[missed_node] = TRUE
		new_networks += list(new_net)

	// If all nodes manage to form a singular network, don't do anything
	if (length(new_networks) <= 1)
		return

	linked_nodes = new_networks[1]
	for (var/i in 2 to length(new_networks))
		var/list/other_net = new_networks[i]
		var/datum/mining_beacon_network/new_net = new()
		new_net.linked_nodes = other_net
		for (var/datum/component/candela_node/other_node as anything in other_net)
			// Doesn't actually run add_node code as we already "added" the nodes above, so we don't do pointless merging checks
			other_node.set_network(new_net)

	for (var/obj/item/stack/candela_beacon/beacon as anything in linked_beacon_items)
		beacon.locate_nearest_network()

/// Maximum distance between Candela beacons
#define MINING_BEACON_MAX_REACH 9

/obj/item/stack/candela_beacon
	name = "mining navigation beacon"
	singular_name = "mining navigation beacon"
	desc = "\"Candela\"-type extending mining beacon, capable of linking with nearby beacons and devices to form a satellie-free navigation network."
	icon = 'icons/obj/mining.dmi'
	icon_state = "candela_beacon"
	w_class = WEIGHT_CLASS_SMALL
	full_w_class = WEIGHT_CLASS_SMALL
	merge_type = /obj/item/stack/candela_beacon
	max_amount = 50
	novariants = TRUE
	/// Network we're connected to, if any
	var/datum/mining_beacon_network/network = null
	/// Closest node within our network (that we can see)to us
	var/atom/movable/closest_node
	/// Beam visual connecting our user to their closest node
	var/datum/beam/beam_visual = null

/obj/item/stack/candela_beacon/Initialize(mapload, new_amount, merge, list/mat_override, mat_amt)
	. = ..()
	update_appearance()

/obj/item/stack/candela_beacon/Destroy()
	set_network(null)
	return ..()

/obj/item/stack/candela_beacon/attack_self(mob/user, modifiers)
	. = ..()
	if (!.)
		place_beacon(user)

/obj/item/stack/candela_beacon/merge_without_del(obj/item/stack/candela_beacon/target_stack, limit)
	. = ..()
	if (.)
		target_stack.set_network(network)
		target_stack.set_closest_node(closest_node)

/obj/item/stack/candela_beacon/proc/place_beacon(mob/user, atom/loc_override, silent = FALSE)
	if (!isturf(user.loc))
		if (!silent)
			to_chat(user, span_warning("You need more space to place a [singular_name] here."))
		return FALSE

	if (locate(/obj/structure/candela_beacon) in user.loc)
		if (!silent)
			to_chat(user, span_warning("There is already a [singular_name] here."))
		return FALSE

	if (!use(1))
		return FALSE

	if (!silent)
		to_chat(user, span_notice("You activate and anchor [amount ? "a":"the"] [singular_name] in place."))

	playsound(user, 'sound/machines/click.ogg', 50, TRUE)
	var/obj/structure/candela_beacon/beacon = new(loc_override || user.loc, network)
	if (network != beacon.network)
		set_network(beacon.network) // Connect to the beacon's possibly new or merged network
	set_closest_node(beacon)
	transfer_fingerprints_to(beacon)
	return TRUE

/obj/item/stack/candela_beacon/attack_self_secondary(mob/user, modifiers)
	. = ..()
	if (.)
		return
	set_network(null)
	balloon_alert(user, "network connection severed")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/stack/candela_beacon/examine(mob/user)
	. = ..()
	. += "Use in-hand to plant a beacon, [EXAMINE_HINT("right-click")] in-hand to sever network link. Click on a placed beacon to form a network connection."
	. += "Automatically deployed upon reaching maximum distance or breaking line-of-sight to the network when placed in pocket or belt slots."

/obj/item/stack/candela_beacon/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_e", src, alpha = 192)

/obj/item/stack/candela_beacon/proc/set_network(datum/mining_beacon_network/new_network, merging = FALSE)
	if (network == new_network)
		return

	if (network)
		network.linked_beacon_items -= src

	network = new_network

	if (!network)
		set_closest_node(null)
		return

	if (!merging)
		network.linked_beacon_items |= src

/obj/item/stack/candela_beacon/proc/locate_nearest_node(silent = FALSE)
	if (!network)
		return null

	for (var/atom/movable/node in view(MINING_BEACON_MAX_REACH, get_turf(src)))
		if (!network.linked_nodes[node])
			continue
		set_closest_node(node)
		return node

	set_network(null)
	var/mob/living/carrier = get(loc, /mob/living)
	if (carrier && !silent)
		balloon_alert(carrier, "connection lost!")

/obj/item/stack/candela_beacon/proc/locate_nearest_network()
	for (var/obj/structure/candela_beacon/beacon in view(MINING_BEACON_MAX_REACH, get_turf(src)))
		set_network(beacon.network)
		set_closest_node(beacon)
		return network

	if (!network)
		return null

	set_network(null)
	var/mob/living/carrier = get(loc, /mob/living)
	if (carrier)
		balloon_alert(carrier, "connection lost!")

/obj/item/stack/candela_beacon/equipped(mob/user, slot, initial)
	. = ..()
	if (!(slot & (ITEM_SLOT_HANDS | ITEM_SLOT_POCKETS | ITEM_SLOT_BELT)))
		return

	RegisterSignal(user, COMSIG_MOB_CLIENT_MOVED, PROC_REF(on_user_moved))
	locate_nearest_node(silent = TRUE)

/obj/item/stack/candela_beacon/dropped(mob/user, silent)
	. = ..()
	UnregisterSignal(user, COMSIG_MOB_CLIENT_MOVED)
	set_closest_node(null)

/obj/item/stack/candela_beacon/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if (isitem(old_loc))
		UnregisterSignal(old_loc, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
		if (isliving(old_loc.loc))
			UnregisterSignal(old_loc.loc, COMSIG_MOB_CLIENT_MOVED)
			set_closest_node(null)

	if (!isitem(loc))
		return

	RegisterSignal(loc, COMSIG_ITEM_EQUIPPED, PROC_REF(on_container_equipped))
	RegisterSignal(loc, COMSIG_ITEM_DROPPED, PROC_REF(on_container_dropped))
	if (!isliving(loc.loc))
		return

	var/mob/living/owner = loc.loc
	if (owner.get_slot_by_item(loc) & (ITEM_SLOT_POCKETS | ITEM_SLOT_BELT))
		RegisterSignal(owner, COMSIG_MOB_CLIENT_MOVED, PROC_REF(on_user_moved))
		locate_nearest_node(silent = TRUE)

/obj/item/stack/candela_beacon/proc/on_container_equipped(obj/item/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if (slot & (ITEM_SLOT_POCKETS | ITEM_SLOT_BELT))
		RegisterSignal(equipper, COMSIG_MOB_CLIENT_MOVED, PROC_REF(on_user_moved))
		locate_nearest_node(silent = TRUE)

/obj/item/stack/candela_beacon/proc/on_container_dropped(obj/item/source, mob/user)
	SIGNAL_HANDLER
	UnregisterSignal(user, COMSIG_MOB_CLIENT_MOVED)
	set_closest_node(null)

/obj/item/stack/candela_beacon/proc/set_closest_node(atom/movable/new_node)
	if (new_node == closest_node)
		return

	if (closest_node)
		UnregisterSignal(closest_node, COMSIG_QDELETING)
	QDEL_NULL(beam_visual)

	closest_node = new_node

	if (!closest_node)
		return

	RegisterSignal(closest_node, COMSIG_QDELETING, PROC_REF(on_node_deleted))
	var/mob/living/owner = null
	if (isliving(loc))
		if (astype(loc, /mob/living).get_slot_by_item(src) & (ITEM_SLOT_POCKETS | ITEM_SLOT_HANDS | ITEM_SLOT_BELT))
			owner = loc
	else if (isitem(loc) && isliving(loc.loc) && astype(loc.loc, /mob/living).get_slot_by_item(src) & (ITEM_SLOT_POCKETS | ITEM_SLOT_BELT))
		owner = loc.loc

	if (owner)
		beam_visual = owner.Beam(closest_node, "1-full", 'icons/effects/beam.dmi', beam_color = LIGHT_COLOR_MINING, emissive = EMISSIVE_BLOOM, override_origin_pixel_x = 1, override_origin_pixel_y = 11, override_target_pixel_x = 1, override_target_pixel_y = 11, emissive_alpha = 192, alpha = 128, layer = BELOW_MOB_LAYER)

/obj/item/stack/candela_beacon/proc/on_node_deleted(datum/source)
	SIGNAL_HANDLER

	closest_node = null
	locate_nearest_node()

/obj/item/stack/candela_beacon/proc/on_user_moved(mob/living/source, direction, old_dir, atom/old_loc)
	SIGNAL_HANDLER

	if (!network)
		return

	var/turf/new_loc = source.loc
	// Check if this was a valid step with no teleportation involved
	if (!isturf(new_loc) || !isturf(old_loc) || get_step(old_loc, direction) != new_loc)
		set_closest_node(null)
		set_network(null)
		return

	var/atom/movable/current_closest = null
	if (source in viewers(MINING_BEACON_MAX_REACH, closest_node))
		current_closest = closest_node

	for (var/atom/movable/network_node as anything in network.linked_nodes)
		if (network_node == closest_node || get_dist(network_node, new_loc) > MINING_BEACON_MAX_REACH)
			continue

		if (get_dist_euclidean(new_loc, get_turf(network_node)) >= get_dist_euclidean(new_loc, get_turf(current_closest)))
			continue

		// viewers() is much faster than view(), so we iterate through closer nodes and check if the owner can see it instead of looking for nearby nodes from the owner
		if (source in viewers(MINING_BEACON_MAX_REACH, network_node))
			current_closest = network_node

	if (current_closest)
		if (current_closest != closest_node)
			set_closest_node(current_closest)
		return

	// If we did not change current_closest, there is a chance we cannot see any nodes near us, in which case we want to place a beacon on the previous turf where we *did* see one
	if (closest_node && place_beacon(source, old_loc, silent = TRUE))
		return

	set_closest_node(null)
	set_network(null)
	balloon_alert(source, "connection lost!")

/obj/item/stack/candela_beacon/ten
	amount = 10

/obj/item/stack/candela_beacon/thirty
	amount = 30

// Deployed beacon structure

/obj/structure/candela_beacon
	name = "mining navigation beacon"
	desc = "\"Candela\"-type extending mining beacon, capable of linking with nearby beacons and devices to form a satellie-free navigation network."
	icon = 'icons/obj/mining.dmi'
	icon_state = "candela_deployed"
	layer = ABOVE_OBJ_LAYER
	pixel_z = 8
	base_pixel_z = 8
	anchored = TRUE
	light_range = 1.5
	light_power = 2.5
	light_color = LIGHT_COLOR_MINING
	armor_type = /datum/armor/structure_candela_beacon
	max_integrity = 90

/datum/armor/structure_candela_beacon
	melee = 50
	bullet = 75
	laser = 75
	energy = 75
	bomb = 25
	fire = 25

/obj/structure/candela_beacon/Initialize(mapload, datum/mining_beacon_network/new_network)
	. = ..()
	if (isnull(new_network))
		new_network = new()
	set_network(new_network)
	update_appearance()

/obj/structure/candela_beacon/Destroy(force)
	QDEL_LIST_ASSOC_VAL(beam_visuals)
	set_network(null, destroying = TRUE)
	return ..()

/obj/structure/candela_beacon/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_e", src, alpha = 192)

/obj/structure/candela_beacon/proc/set_network(datum/mining_beacon_network/new_network, merging = FALSE, destroying = FALSE)
	if (network == new_network)
		return

	if (network)
		network.remove_node(src)

	network = new_network

	if (network)
		network.add_node(src, merging = merging)

	if (!destroying)
		update_connections()

/obj/structure/candela_beacon/proc/update_connections()
	if (!network)
		QDEL_LIST_ASSOC_VAL(beam_visuals)
		return

	var/list/atom/movable/linked_to = network.linked_nodes[src]
	for (var/lost_node, old_beam in beam_visuals - linked_to)
		beam_visuals -= lost_node
		qdel(old_beam)

	for (var/atom/movable/new_node as anything in linked_to - beam_visuals)
		if (istype(new_node, /obj/structure/candela_beacon))
			var/obj/structure/candela_beacon/beacon = new_node
			if (beacon.beam_visuals[src])
				continue
		beam_visuals[new_node] = Beam(new_node, "1-full", 'icons/effects/beam.dmi', beam_color = LIGHT_COLOR_MINING, emissive = EMISSIVE_BLOOM, override_origin_pixel_x = 1, override_origin_pixel_y = 11, override_target_pixel_x = 1, override_target_pixel_y = 11, emissive_alpha = 192, alpha = 192)

/// List of all mining beacon networks for easy connection lookups
GLOBAL_LIST_EMPTY(mining_beacon_networks)

/// Candela beacon network datum
/datum/mining_beacon_network
	/// List of all beacon nodes within our network -> their connections
	var/list/atom/movable/linked_nodes = list()
	/// List of beacon items tracking our network
	var/list/obj/item/stack/candela_beacon/linked_beacon_items = list()

/datum/mining_beacon_network/New()
	. = ..()
	GLOB.mining_beacon_networks += src

/datum/mining_beacon_network/Destroy(force)
	linked_nodes.Cut()
	linked_beacon_items.Cut()
	GLOB.mining_beacon_networks -= src
	return ..()

/datum/mining_beacon_network/proc/add_node(atom/movable/new_node, merging = FALSE)
	if (linked_nodes[new_node])
		return

	linked_nodes[new_node] = list()

	if (merging)
		return

	var/list/all_nodes = list()
	for (var/datum/mining_beacon_network/network as anything in GLOB.mining_beacon_networks)
		if (network == src)
			continue

		for (var/atom/movable/node as anything in network.linked_nodes)
			all_nodes[node] = network

	var/list/merged_networks = list()
	for (var/atom/movable/thing in view(MINING_BEACON_MAX_REACH, new_node))
		if (thing == new_node)
			continue

		if (linked_nodes[thing])
			linked_nodes[new_node] |= thing
			linked_nodes[thing] |= new_node
			update_node_connections(thing)
			continue

		if (!all_nodes[thing])
			continue

		var/datum/mining_beacon_network/network = all_nodes[thing]
		linked_nodes[new_node] |= thing
		network.linked_nodes[thing] |= new_node
		network.update_node_connections(thing)

		merged_networks |= network

	if (!length(merged_networks))
		return

	// Merge ourselves into the closest network, then merge all other located networks into it as well
	// Significantly reduces churn when placing new beacons
	var/datum/mining_beacon_network/first_net = merged_networks[1]
	first_net.merge_network(src)

	for (var/datum/mining_beacon_network/network as anything in merged_networks - first_net)
		first_net.merge_network(network)

/datum/mining_beacon_network/proc/merge_network(datum/mining_beacon_network/to_merge)
	for (var/atom/movable/node as anything in to_merge.linked_nodes + to_merge.linked_beacon_items)
		set_node_network(node, merging = TRUE)

	for (var/node, connections in to_merge.linked_nodes)
		if (linked_nodes[node])
			linked_nodes[node] |= connections
		else
			linked_nodes[node] = connections

	linked_beacon_items |= to_merge.linked_beacon_items
	qdel(to_merge)

/datum/mining_beacon_network/proc/set_node_network(atom/movable/node, merging = FALSE)
	if (istype(node, /obj/structure/candela_beacon))
		var/obj/structure/candela_beacon/beacon = node
		beacon.set_network(src, merging = merging)

	if (istype(node, /obj/item/stack/candela_beacon))
		var/obj/item/stack/candela_beacon/beacon = node
		beacon.set_network(src, merging = merging)

/datum/mining_beacon_network/proc/remove_node(atom/movable/node)
	if (!linked_nodes[node])
		return

	if (length(linked_nodes) == 1)
		qdel(src)
		return

	var/list/connections = linked_nodes[node]
	if (length(connections) == 1) // End node, no need to run separation calculations
		linked_nodes[connections[1]] -= node
		update_node_connections(connections[1])
		return

	for (var/other_node as anything in connections)
		linked_nodes[other_node] -= node
		update_node_connections(other_node)

	linked_nodes -= node

	var/list/new_networks = list()
	var/list/polling_nodes = connections.Copy()
	var/index = 1
	while (index <= length(polling_nodes))
		var/atom/movable/to_poll = polling_nodes[index]
		polling_nodes |= linked_nodes[to_poll]
		index += 1
		var/list/connected_to = list()
		for (var/i in 1 to length(new_networks))
			var/list/new_net = new_networks[i]
			if (new_net[to_poll])
				connected_to += i

		if (!length(connected_to))
			new_networks += list(list(to_poll = TRUE))
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

	// If all nodes manage to form a singular network, don't do anything
	if (length(new_networks) <= 1)
		return

	linked_nodes = new_networks[1]
	for (var/i in 2 to length(new_networks))
		var/list/other_net = new_networks[i]
		var/datum/mining_beacon_network/new_net = new()
		new_net.linked_nodes = other_net
		for (var/atom/movable/other_node as anything in other_net)
			// Doesn't actually run add_node code as we already "added" the nodes above, so we don't do pointless merging checks
			set_node_network(other_node, new_net)

	for (var/obj/item/stack/candela_beacon/beacon as anything in linked_beacon_items)
		beacon.locate_nearest_network()

/datum/mining_beacon_network/proc/update_node_connections(atom/movable/node)
	if (istype(node, /obj/structure/candela_beacon))
		var/obj/structure/candela_beacon/beacon = node
		beacon.update_connections()

#undef MINING_BEACON_MAX_REACH

/// Datum which handles interactions of items with the Candela network
/// Not a component as item interactions can be much more involved and bi-directional
/// which makes isolated nature of components a bad fit
/datum/candela_item_handler
	// Properties
	/// Item which owns this handler
	var/obj/item/parent = null
	/// Slots in which the item keeps the connection to the network
	var/active_slots = NONE
	/// Slots in which the storage containing this item can be in order for the item to keep the connection
	var/storage_active_slots = NONE
	/// Callback called when we're about to get cut from the network due to user movement : (atom/old_loc, old_dir, interrupt)
	var/datum/callback/on_network_cut_callback = null

	// Runtime variables
	/// Mob which is currently holding/using the item
	var/mob/living/owner = null
	/// Network we're connected to, if any
	var/datum/mining_beacon_network/network = null
	/// Closest node within our network (that we can see)to us
	var/datum/component/candela_node/closest_node
	/// Beam visual connecting our user to their closest node
	var/datum/beam/beam_visual = null

/datum/candela_item_handler/New(obj/item/parent, active_slots = NONE, storage_active_slots = NONE, datum/callback/on_network_cut_callback = null)
	. = ..()
	src.parent = parent
	src.active_slots = active_slots
	src.storage_active_slots = storage_active_slots
	src.on_network_cut_callback = on_network_cut_callback

	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_parent_equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_parent_dropped))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_parent_moved))

/datum/candela_item_handler/Destroy(force)
	set_network(null)
	set_owner(null)
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED, COMSIG_MOVABLE_MOVED))
	parent = null
	on_network_cut_callback = null
	return ..()

/datum/candela_item_handler/proc/on_parent_equipped(obj/item/source, mob/living/user, slot)
	SIGNAL_HANDLER
	if (slot & active_slots)
		set_owner(user)

/datum/candela_item_handler/proc/on_parent_dropped(obj/item/source, mob/living/user)
	SIGNAL_HANDLER
	set_owner(null)

/datum/candela_item_handler/proc/on_parent_moved(obj/item/source, atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	SIGNAL_HANDLER

	if (!storage_active_slots)
		return

	if (isitem(old_loc))
		if (old_loc.loc == owner)
			set_owner(null)
		UnregisterSignal(old_loc, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

	var/atom/parent_loc = parent.loc
	if (!isitem(parent_loc))
		return

	RegisterSignal(parent_loc, COMSIG_ITEM_EQUIPPED, PROC_REF(on_storage_equipped))
	RegisterSignal(parent_loc, COMSIG_ITEM_DROPPED, PROC_REF(on_storage_dropped))
	if (astype(parent_loc.loc, /mob/living)?.get_slot_by_item(parent_loc) & storage_active_slots)
		set_owner(parent_loc.loc)

/datum/candela_item_handler/proc/on_storage_equipped(obj/item/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if (slot & storage_active_slots)
		set_owner(equipper)

/datum/candela_item_handler/proc/on_storage_dropped(obj/item/source, mob/user)
	SIGNAL_HANDLER
	set_owner(null)

/datum/candela_item_handler/proc/set_owner(mob/living/new_owner)
	if (owner == new_owner)
		return

	if (owner)
		network?.unlink_mob(src, owner)

	owner = new_owner
	network?.linked_beacon_items |= src
	if (!owner)
		set_closest_node(null)
		return

	if (network)
		network.link_mob(src, owner)
		locate_closest_node(silent = TRUE)

/datum/candela_item_handler/proc/set_network(datum/mining_beacon_network/new_network, datum/component/candela_node/new_closest_node = null, merging = FALSE)
	if (network == new_network)
		if (new_closest_node)
			set_closest_node(new_closest_node)
		return

	if (network)
		if (owner)
			network.unlink_mob(src, owner)
		network.linked_beacon_items -= src

	network = new_network

	if (!network)
		set_closest_node(null)
		return

	if (owner)
		network.link_mob(src, owner)

	if (merging)
		return

	network.linked_beacon_items |= src
	if (new_closest_node)
		set_closest_node(new_closest_node)
	else
		locate_closest_node()

/// Locates the closest node within our network, or cuts the connection if none could be found
/datum/candela_item_handler/proc/locate_closest_node(silent = FALSE)
	if (!network)
		return null

	var/turf/our_turf = get_turf(parent)
	var/cur_dist = MINING_BEACON_MAX_REACH + 1
	var/cur_node = null
	for (var/datum/component/candela_node/node as anything in network.linked_nodes)
		var/turf/node_turf = get_turf(node.parent)
		var/node_dist = get_dist_euclidean(our_turf, node_turf)
		if (node_dist >= cur_dist)
			continue

		if (!can_see(our_turf, node_turf, MINING_BEACON_MAX_REACH) && !can_see(node_turf, our_turf, MINING_BEACON_MAX_REACH))
			continue

		cur_node = node
		cur_dist = node_dist

	if (cur_node)
		set_closest_node(cur_node)
		return cur_node

	set_network(null)
	if (owner && !silent)
		parent.balloon_alert(owner, "connection lost!")

/// Locates the closest node within any network to ourselves, and links to it and its network
/datum/candela_item_handler/proc/locate_closest_network()
	var/turf/our_turf = get_turf(parent)
	var/cur_dist = MINING_BEACON_MAX_REACH + 1
	var/datum/component/candela_node/cur_node = null
	for (var/datum/mining_beacon_network/network as anything in GLOB.mining_beacon_networks)
		for (var/datum/component/candela_node/node as anything in network.linked_nodes)
			var/turf/node_turf = get_turf(node.parent)
			var/node_dist = get_dist_euclidean(our_turf, node_turf)
			if (node_dist >= cur_dist)
				continue

			if (!can_see(our_turf, node_turf, MINING_BEACON_MAX_REACH) && !can_see(node_turf, our_turf, MINING_BEACON_MAX_REACH))
				continue

			cur_node = node
			cur_dist = node_dist

	if (cur_node)
		set_network(cur_node.network, cur_node)
		return network

	if (!network)
		return null

	set_network(null)
	if (owner)
		parent.balloon_alert(owner, "connection lost!")

/datum/candela_item_handler/proc/set_closest_node(datum/component/candela_node/new_node)
	if (new_node == closest_node)
		return

	if (closest_node)
		UnregisterSignal(closest_node, COMSIG_QDELETING)

	QDEL_NULL(beam_visual)
	closest_node = new_node

	if (!closest_node)
		return

	RegisterSignal(closest_node, COMSIG_QDELETING, PROC_REF(on_node_deleted))

	if (!owner)
		return

	// Don't render a beam if another handler (added to the network before us) is already rendering one to the same node as to avoid spam/overlaps
	var/list/handlers = network.linked_mobs[owner]
	for (var/datum/candela_item_handler/other_handler as anything in handlers)
		if (other_handler == src || other_handler.closest_node != closest_node) // shouldn't have a different closest node but just in case
			continue

		if (handlers.Find(other_handler) < handlers.Find(src))
			return

	redraw_beam()

/datum/candela_item_handler/proc/redraw_beam()
	QDEL_NULL(beam_visual)
	beam_visual = owner.Beam(
		closest_node.parent,
		"1-full", 'icons/effects/beam.dmi',
		beam_color = LIGHT_COLOR_MINING,
		emissive = EMISSIVE_BLOOM,
		override_target_pixel_x = closest_node.connection_pixel_x,
		override_target_pixel_y = closest_node.connection_pixel_y,
		emissive_alpha = 192,
		alpha = 128,
		layer = BELOW_MOB_LAYER
	)

/datum/candela_item_handler/proc/on_node_deleted(datum/source)
	SIGNAL_HANDLER

	closest_node = null
	locate_closest_node()

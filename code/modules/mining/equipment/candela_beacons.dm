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
	var/datum/component/candela_node/closest_node
	/// Beam visual connecting our user to their closest node
	var/datum/beam/beam_visual = null

/obj/item/stack/candela_beacon/Initialize(mapload, new_amount, merge, list/mat_override, mat_amt)
	. = ..()
	update_appearance()

/obj/item/stack/candela_beacon/Destroy()
	set_network(null)
	return ..()

/obj/item/stack/candela_beacon/attack_self(mob/user, modifiers)
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

	// In case use() deletes ourselves
	var/datum/mining_beacon_network/our_network = network
	if (!use(1))
		return FALSE

	if (!silent)
		to_chat(user, span_notice("You activate and anchor [amount ? "a":"the"] [singular_name] in place."))

	playsound(user, 'sound/machines/click.ogg', 50, TRUE)
	var/obj/structure/candela_beacon/beacon = new(loc_override || user.loc, our_network, src)
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
	. += "Use in-hand to plant a beacon, [EXAMINE_HINT("right-click")] in-hand to sever network link."
	. += "Click on a placed beacon to form a network connection, or [EXAMINE_HINT("right-click")] to pick it up."
	. += "Automatically deployed upon reaching maximum distance or breaking line-of-sight to the network when placed in pocket or belt slots, or in storage in pocket or belt slots."

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

	var/list/atoms_to_nodes = list()
	for (var/datum/component/candela_node/node as anything in network.linked_nodes)
		atoms_to_nodes[node.parent] = node

	var/turf/our_turf = get_turf(src)
	for (var/atom/movable/thing in view(MINING_BEACON_MAX_REACH, our_turf))
		// view() is not a raycast and can go through walls, but this is more optimized than iterating through all nodes
		if (!atoms_to_nodes[thing] || !can_see(our_turf, thing, MINING_BEACON_MAX_REACH) || !can_see(thing, our_turf, MINING_BEACON_MAX_REACH))
			continue
		set_closest_node(atoms_to_nodes[thing])
		return atoms_to_nodes[thing]

	set_network(null)
	var/mob/living/carrier = get(loc, /mob/living)
	if (carrier && !silent)
		balloon_alert(carrier, "connection lost!")

/obj/item/stack/candela_beacon/proc/locate_nearest_network()
	var/list/atoms_to_nodes = list()
	for (var/datum/mining_beacon_network/network as anything in GLOB.mining_beacon_networks)
		for (var/datum/component/candela_node/node as anything in network.linked_nodes)
			atoms_to_nodes[node.parent] = node

	var/turf/our_turf = get_turf(src)
	for (var/atom/movable/thing in view(MINING_BEACON_MAX_REACH, our_turf))
		if (!atoms_to_nodes[thing] || !can_see(our_turf, thing, MINING_BEACON_MAX_REACH) || !can_see(thing, our_turf, MINING_BEACON_MAX_REACH))
			continue
		var/datum/component/candela_node/node = atoms_to_nodes[thing]
		set_network(node.network)
		set_closest_node(node)
		return network

	if (!network)
		return null

	set_network(null)
	var/mob/living/carrier = get(loc, /mob/living)
	if (carrier)
		balloon_alert(carrier, "connection lost!")

/obj/item/stack/candela_beacon/equipped(mob/user, slot, initial)
	. = ..()
	if (slot & (ITEM_SLOT_HANDS | ITEM_SLOT_POCKETS | ITEM_SLOT_BELT))
		track_user(user)

/obj/item/stack/candela_beacon/dropped(mob/user, silent)
	. = ..()
	drop_user(user)

/obj/item/stack/candela_beacon/proc/track_user(mob/living/user)
	RegisterSignal(user, COMSIG_MOB_CLIENT_MOVED, PROC_REF(on_user_moved))
	locate_nearest_node(silent = TRUE)

/obj/item/stack/candela_beacon/proc/drop_user(mob/living/user)
	UnregisterSignal(user, COMSIG_MOB_CLIENT_MOVED)
	set_closest_node(null)

/obj/item/stack/candela_beacon/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if (isitem(old_loc))
		UnregisterSignal(old_loc, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
		if (isliving(old_loc.loc))
			drop_user(old_loc.loc)

	if (!isitem(loc))
		return

	RegisterSignal(loc, COMSIG_ITEM_EQUIPPED, PROC_REF(on_container_equipped))
	RegisterSignal(loc, COMSIG_ITEM_DROPPED, PROC_REF(on_container_dropped))
	if (!isliving(loc.loc))
		return

	var/mob/living/owner = loc.loc
	if (owner.get_slot_by_item(loc) & (ITEM_SLOT_POCKETS | ITEM_SLOT_BELT))
		track_user(owner)

/obj/item/stack/candela_beacon/proc/on_container_equipped(obj/item/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if (slot & (ITEM_SLOT_POCKETS | ITEM_SLOT_BELT))
		track_user(equipper)

/obj/item/stack/candela_beacon/proc/on_container_dropped(obj/item/source, mob/user)
	SIGNAL_HANDLER
	drop_user(user)

/obj/item/stack/candela_beacon/proc/set_closest_node(datum/component/candela_node/new_node)
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

	if (!owner)
		return

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

	var/datum/component/candela_node/current_closest = null
	if (closest_node && can_see(source, closest_node.parent, MINING_BEACON_MAX_REACH) && can_see(closest_node.parent, source, MINING_BEACON_MAX_REACH))
		current_closest = closest_node

	for (var/datum/component/candela_node/network_node as anything in network.linked_nodes)
		if (network_node == closest_node || get_dist(network_node.parent, new_loc) > MINING_BEACON_MAX_REACH)
			continue

		if (current_closest && get_dist_euclidean(new_loc, get_turf(network_node.parent)) >= get_dist_euclidean(new_loc, get_turf(current_closest.parent)))
			continue

		// Need a can_see rather than viewers() to avoid beams going through walls
		if (can_see(source, network_node.parent, MINING_BEACON_MAX_REACH) && can_see(network_node.parent, source, MINING_BEACON_MAX_REACH))
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
	pixel_z = 6
	base_pixel_z = 6
	anchored = TRUE
	light_range = 2
	light_power = 1.7
	light_color = LIGHT_COLOR_MINING
	armor_type = /datum/armor/structure_candela_beacon
	max_integrity = 90

/datum/armor/structure_candela_beacon
	melee = 25
	bullet = 25
	laser = 25
	energy = 25
	bomb = 75
	fire = 25

/obj/structure/candela_beacon/Initialize(mapload, datum/mining_beacon_network/new_network, obj/item/stack/candela_beacon/beacon_stack)
	. = ..()
	if (isnull(new_network))
		new_network = new()
	RegisterSignal(src, COMSIG_CANDELA_NODE_NETWORK_CHANGED, PROC_REF(on_network_changed))
	AddComponent(/datum/component/candela_node, new_network, beacon_stack, connection_pixel_x = base_pixel_w, connection_pixel_y = base_pixel_z + 3)
	update_appearance()

/obj/structure/candela_beacon/proc/on_network_changed(datum/source, datum/mining_beacon_network/old_network, datum/mining_beacon_network/new_network)
	SIGNAL_HANDLER

	if (old_network)
		UnregisterSignal(old_network, COMSIG_CANDELA_NETWORK_POWER_CHANGED)
	on_power_changed(old_state = old_network?.powered, new_state = new_network?.powered)
	if (new_network)
		RegisterSignal(new_network, COMSIG_CANDELA_NETWORK_POWER_CHANGED, PROC_REF(on_power_changed))

/obj/structure/candela_beacon/proc/on_power_changed(datum/source, old_state, new_state)
	SIGNAL_HANDLER

	var/powered = (new_state & CANDELA_NETWORK_POWERED)
	set_light_power(powered ? 1.7 : 1.3)
	set_light_range(powered ? 2 : MINIMUM_USEFUL_LIGHT_RANGE)

/obj/structure/candela_beacon/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_e", src, alpha = 192)

/obj/structure/candela_beacon/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if (.)
		return
	balloon_alert(user, "picking up the beacon...")
	if (!do_after(user, 2 SECONDS, src))
		return

	var/obj/item/stack/candela_beacon/beacon = new(loc)
	transfer_fingerprints_to(beacon)
	if (user.put_in_hands(beacon, del_on_fail = TRUE))
		playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
		qdel(src)

/obj/structure/candela_beacon/item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	if (!istype(tool, /obj/item/stack/candela_beacon))
		return NONE

	var/obj/item/stack/candela_beacon/collection = tool
	to_chat(user, span_notice("You start picking [src] up..."))
	if(!do_after(user, 2 SECONDS, src) || collection.amount + 1 > collection.max_amount)
		return ITEM_INTERACT_BLOCKING

	collection.add(1)
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

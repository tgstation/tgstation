/obj/item/stack/candela_beacon
	name = "mining navigation beacon"
	singular_name = "mining navigation beacon"
	desc = "\"Candela\"-type extending mining beacon, capable of linking with nearby beacons and devices to form a satellite-free navigation network."
	icon = 'icons/obj/mining.dmi'
	icon_state = "candela_beacon"
	w_class = WEIGHT_CLASS_SMALL
	full_w_class = WEIGHT_CLASS_SMALL
	merge_type = /obj/item/stack/candela_beacon
	max_amount = 50
	novariants = TRUE
	/// Candela network handler we use for our connection behavior
	var/datum/candela_item_handler/handler = null

/obj/item/stack/candela_beacon/Initialize(mapload, new_amount, merge, list/mat_override, mat_amt)
	. = ..()
	handler = new(
		src,
		active_slots = ITEM_SLOT_HANDS | ITEM_SLOT_POCKETS,
		storage_active_slots = ITEM_SLOT_POCKETS | ITEM_SLOT_BELT,
		on_network_cut_callback = CALLBACK(src, PROC_REF(on_network_cut)),
	)
	update_appearance()

/obj/item/stack/candela_beacon/Destroy()
	QDEL_NULL(handler)
	return ..()

/obj/item/stack/candela_beacon/attack_self(mob/user, modifiers)
	place_beacon(user)

/obj/item/stack/candela_beacon/interact(mob/user)
	return

/obj/item/stack/candela_beacon/merge_without_del(obj/item/stack/candela_beacon/target_stack, limit)
	. = ..()
	if (.)
		target_stack.handler.set_network(handler.network, handler.closest_node)

/// Deploy a beacon at user's feet, or at a given location if passed
/// Can deploy a beacon for another handler, using its network instead
/obj/item/stack/candela_beacon/proc/place_beacon(mob/user, atom/loc_override = null, datum/candela_item_handler/handler_override = null, silent = FALSE)
	if (!isturf(user.loc))
		if (!silent)
			to_chat(user, span_warning("You need more space to place a [singular_name] here."))
		return FALSE

	if (locate(/obj/structure/candela_beacon) in (loc_override || user.loc))
		if (!silent)
			to_chat(user, span_warning("There is already a [singular_name] here."))
		return FALSE

	var/datum/candela_item_handler/used_handler = handler_override || handler
	// In case use() deletes ourselves
	var/datum/mining_beacon_network/our_network = used_handler.network
	if (!use(1))
		return FALSE

	if (!silent)
		to_chat(user, span_notice("You activate and anchor [amount ? "a":"the"] [singular_name] in place."))

	playsound(user, 'sound/machines/click.ogg', 50, TRUE)
	var/obj/structure/candela_beacon/beacon = new(loc_override || user.loc, our_network, used_handler)
	transfer_fingerprints_to(beacon)
	return TRUE

/// Callback to react to breaking LOS/reaching maximum distance with a beacon
/obj/item/stack/candela_beacon/proc/on_network_cut(atom/old_loc, old_dir, interrupt)
	// If we did not change current_closest, there is a chance we cannot see any nodes near us, in which case we want to place a beacon on the previous turf where we *did* see one
	if (handler.closest_node && !interrupt)
		return place_beacon(handler.owner, old_loc, silent = TRUE)
	return FALSE

/obj/item/stack/candela_beacon/attack_self_secondary(mob/user, modifiers)
	. = ..()
	if (.)
		return
	handler.set_network(null)
	balloon_alert(user, "network connection severed")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/stack/candela_beacon/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_e", src, alpha = 192)

/obj/item/stack/candela_beacon/examine(mob/user)
	. = ..()
	. += "Use in-hand to plant a beacon, [EXAMINE_HINT("right-click")] in-hand to sever network link."
	. += "Click on a placed beacon to form a network connection, or [EXAMINE_HINT("right-click")] to pick it up."
	. += "Automatically deployed upon reaching maximum distance or breaking line-of-sight to the network when placed in pocket or belt slots, or in storage in pocket or belt slots."

/obj/item/stack/candela_beacon/ten
	amount = 10

/obj/item/stack/candela_beacon/thirty
	amount = 30

// Deployed beacon structure

/obj/structure/candela_beacon
	name = "mining navigation beacon"
	desc = "\"Candela\"-type extending mining beacon, capable of linking with nearby beacons and devices to form a satellite-free navigation network."
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

/obj/structure/candela_beacon/Initialize(mapload, datum/mining_beacon_network/new_network, datum/candela_item_handler/deployer)
	. = ..()
	if (isnull(new_network))
		new_network = new()
	RegisterSignal(src, COMSIG_CANDELA_NODE_NETWORK_CHANGED, PROC_REF(on_network_changed))
	AddComponent(/datum/component/candela_node, new_network, deployer, connection_pixel_x = base_pixel_w, connection_pixel_y = base_pixel_z + 3)
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
	if(collection.amount >= collection.max_amount)
		balloon_alert(user, "stack full!")
		return ITEM_INTERACT_BLOCKING
	to_chat(user, span_notice("You start picking [src] up..."))
	if(!do_after(user, 2 SECONDS, src) || collection.amount >= collection.max_amount)
		return ITEM_INTERACT_BLOCKING

	collection.add(1)
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

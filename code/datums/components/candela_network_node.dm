/// Component that handles stationary node behavior for the Candela mining navigation network
/datum/component/candela_network_node
	/// Network we're connected to
	var/datum/mining_beacon_network/network = null
	/// List of beam visuals we're using for connections
	var/list/beam_visuals = list()
	/// X offset for our beam connection point
	var/connection_pixel_x = null
	/// Y offset for our beam connection point
	var/connection_pixel_y = null

/datum/component/candela_network_node/Initialize(datum/mining_beacon_network/network = null, connection_pixel_x = null, connection_pixel_y = null)
	. = ..()
	if (!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	set_network(network)
	src.connection_pixel_y = connection_pixel_y
	src.connection_pixel_y = connection_pixel_y

/datum/component/candela_network_node/Destroy(force)
	set_network(null)
	return ..()

/datum/component/candela_network_node/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_item_interaction))

/datum/component/candela_network_node/proc/on_item_interaction(source, mob/living/user, obj/item/tool, list/modifiers)
	SIGNAL_HANDLER

	if (!istype(tool, /obj/item/stack/candela_beacon))
		return NONE

	var/obj/item/stack/candela_beacon/beacon = tool
	tool.set_network(network)
	tool.set_closest_node(parent)
	tool.balloon_alert(user, "network linked!")
	return ITEM_INTERACT_SUCCESS



/datum/techweb_node/syndicate_basic
	display_name = "Illegal Technology"
	description = "Dangerous research used to create dangerous objects."
	node_flags = parent_type::node_flags | TECHWEB_NODE_HIDDEN
	prerequisite_nodes = list(/datum/techweb_node/exp_tools, /datum/techweb_node/exotic_ammo)
	unlocked_designs = list(
		/datum/design/board/advanced_camera,
		/datum/design/ai_cam_upgrade,
		/datum/design/borg_syndicate_module,
		/datum/design/donksoft_refill,
		/datum/design/largecrossbow,
		/datum/design/mag_autorifle,
		/datum/design/mag_autorifle/ap_mag,
		/datum/design/mag_autorifle/ic_mag,
		/datum/design/rapidsyringe,
		/datum/design/suppressor,
		/datum/design/super_pointy_tape,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)

/datum/techweb_node/syndicate_basic/New() //Crappy way of making syndicate gear decon supported until there's another way.
	. = ..()
	if(!SSearly_assets.initialized)
		RegisterSignal(SSearly_assets, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(register_uplink_items))
	else
		register_uplink_items()

/datum/techweb_node/syndicate_basic/proc/register_uplink_items()
	SIGNAL_HANDLER
	UnregisterSignal(SSearly_assets, COMSIG_SUBSYSTEM_POST_INITIALIZE)
	required_items_to_unlock = list()
	for(var/datum/uplink_item/item as anything in SStraitor.uplink_items)
		if(isnull(item.item) || item.item == ABSTRACT_UPLINK_ITEM || !(item.uplink_item_flags & SYNDIE_ILLEGAL_TECH))
			continue
		required_items_to_unlock |= item.item //allows deconning to unlock.

/datum/techweb_node/unregulated_bluespace
	display_name = "Unregulated Bluespace Research"
	description = "Bluespace technology using unstable or unbalanced procedures, prone to damaging the fabric of bluespace. Outlawed by galactic conventions."
	prerequisite_nodes = list(/datum/techweb_node/parts_bluespace, /datum/techweb_node/syndicate_basic)
	unlocked_designs = list(
		/datum/design/desynchronizer,
		/datum/design/beamrifle,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

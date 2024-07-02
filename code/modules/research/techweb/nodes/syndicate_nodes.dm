/datum/techweb_node/syndicate_basic
	id = TECHWEB_NODE_SYNDICATE_BASIC
	display_name = "Illegal Technology"
	description = "Dangerous research used to create dangerous objects."
	prereq_ids = list(TECHWEB_NODE_EXP_TOOLS, TECHWEB_NODE_EXOTIC_AMMO)
	design_ids = list(
		"advanced_camera",
		"ai_cam_upgrade",
		"borg_syndicate_module",
		"donksoft_refill",
		"donksofttoyvendor",
		"largecrossbow",
		"mag_autorifle",
		"mag_autorifle_ap",
		"mag_autorifle_ic",
		"rapidsyringe",
		"suppressor",
		"super_pointy_tape",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)
	hidden = TRUE

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
	for(var/datum/uplink_item/item_path as anything in SStraitor.uplink_items_by_type)
		var/datum/uplink_item/item = SStraitor.uplink_items_by_type[item_path]
		if(!item.item || !(item.uplink_item_flags & SYNDIE_ILLEGAL_TECH))
			continue
		required_items_to_unlock |= item.item //allows deconning to unlock.

/datum/techweb_node/unregulated_bluespace
	id = TECHWEB_NODE_UNREGULATED_BLUESPACE
	display_name = "Unregulated Bluespace Research"
	description = "Bluespace technology using unstable or unbalanced procedures, prone to damaging the fabric of bluespace. Outlawed by galactic conventions."
	prereq_ids = list(TECHWEB_NODE_PARTS_BLUESPACE, TECHWEB_NODE_SYNDICATE_BASIC)
	design_ids = list(
		"desynchronizer",
		"beamrifle",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/material_processing
	id = TECHWEB_NODE_MATERIAL_PROC
	starting_node = TRUE
	display_name = "Material Processing"
	description = "Refinement and processing of alloys and ores to enhance their utility and value."
	design_ids = list(
		"pickaxe",
		"shovel",
		"conveyor_switch",
		"conveyor_belt",
		"mass_driver",
		"recycler",
		"stack_machine",
		"stack_console",
		"autolathe",
		"rglass",
		"plasmaglass",
		"plasmareinforcedglass",
		"plasteel",
		"titaniumglass",
		"plastitanium",
		"plastitaniumglass",
	)

/datum/techweb_node/mining
	id = TECHWEB_NODE_MINING
	display_name = "Mining Technology"
	description = "Development of tools meant to optimize mining operations and resource extraction."
	prereq_ids = list(TECHWEB_NODE_MATERIAL_PROC)
	design_ids = list(
		"cargoexpress",
		"brm",
		"b_smelter",
		"b_refinery",
		"ore_redemption",
		"mining_equipment_vendor",
		"mining_scanner",
		"mech_mscanner",
		"superresonator",
		"mech_drill",
		"mod_drill",
		"drill",
		"mod_orebag",
		"beacon",
		"telesci_gps",
		"mod_gps",
		"mod_visor_meson",
		"mesons",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SUPPLY)

/datum/techweb_node/low_pressure_excavation
	id = TECHWEB_NODE_LOW_PRESSURE_EXCAVATION
	display_name = "Low-Pressure Excavation"
	description = "Research of Proto-Kinetic Accelerators (PKAs), pneumatic guns renowned for their exceptional performance in low-pressure environments."
	prereq_ids = list(TECHWEB_NODE_MINING, TECHWEB_NODE_GAS_COMPRESSION)
	design_ids = list(
		"damagemod",
		"rangemod",
		"cooldownmod",
		"triggermod",
		"hypermod",
		"borg_upgrade_damagemod",
		"borg_upgrade_rangemod",
		"borg_upgrade_cooldownmod",
		"borg_upgrade_hypermod",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SUPPLY)

/datum/techweb_node/plasma_mining
	id = TECHWEB_NODE_PLASMA_MINING
	display_name = "Plasma Beam Mining"
	description = "Engineers' plasma welders have proven highly effective in mining operations. This led to the development of a mech-mounted variant and an enhanced handheld cutter for miners."
	prereq_ids = list(TECHWEB_NODE_LOW_PRESSURE_EXCAVATION, TECHWEB_NODE_PLASMA_CONTROL)
	design_ids = list(
		"mech_plasma_cutter",
		"plasmacutter_adv",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SUPPLY)

/datum/techweb_node/bitrunning
	id = TECHWEB_NODE_BITRUNNING
	display_name = "Bitrunning Technology"
	description = "Bluespace technology has led to the development of quantum-scale computing, which unlocks the means to materialize atomic structures while executing advanced programs."
	prereq_ids = list(TECHWEB_NODE_GAMING, TECHWEB_NODE_APPLIED_BLUESPACE)
	design_ids = list(
		"byteforge",
		"quantum_console",
		"netpod",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SUPPLY)

/datum/techweb_node/mining_adv
	id = TECHWEB_NODE_MINING_ADV
	display_name = "Advanced Mining Technology"
	description = "High-level mining equipment, pushing the boundaries of efficiency and effectiveness in resource extraction."
	prereq_ids = list(TECHWEB_NODE_PLASMA_MINING)
	design_ids = list(
		"jackhammer",
		"drill_diamond",
		"mech_diamond_drill",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_SUPPLY)

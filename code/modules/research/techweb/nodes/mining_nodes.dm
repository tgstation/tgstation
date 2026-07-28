/datum/techweb_node/material_processing
	display_name = "Material Processing"
	description = "Refinement and processing of alloys and ores to enhance their utility and value."
	node_flags = parent_type::node_flags | TECHWEB_NODE_STARTER
	unlocked_designs = list(
		/datum/design/pickaxe,
		/datum/design/shovel,
		/datum/design/conveyor_switch,
		/datum/design/conveyor_belt,
		/datum/design/board/mass_driver,
		/datum/design/board/recycler,
		/datum/design/board/stacking_machine,
		/datum/design/board/stacking_unit_console,
		/datum/design/board/autolathe,
		/datum/design/material/rglass,
		/datum/design/alloy/plaglass,
		/datum/design/alloy/plasmarglass,
		/datum/design/alloy/plasteel_alloy,
		/datum/design/alloy/titaniumglass,
		/datum/design/alloy/plastitanium,
		/datum/design/alloy/plastitaniumglass,
	)

/datum/techweb_node/mining
	display_name = "Mining Technology"
	description = "Development of tools meant to optimize mining operations and resource extraction."
	prerequisite_nodes = list(/datum/techweb_node/material_processing)
	unlocked_designs = list(
		/datum/design/cargo_express,
		/datum/design/board/brm,
		/datum/design/board/smelter,
		/datum/design/board/refinery,
		/datum/design/board/ore_redemption,
		/datum/design/board/mining_equipment_vendor,
		/datum/design/mining_scanner,
		/datum/design/mech_mining_scanner,
		/datum/design/superresonator,
		/datum/design/mech_drill,
		/datum/design/module/mod_drill,
		/datum/design/drill,
		/datum/design/module/mod_orebag,
		/datum/design/beacon,
		/datum/design/telesci_gps,
		/datum/design/module/mod_gps,
		/datum/design/module/mod_visor_meson,
		/datum/design/mesons,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SUPPLY)

/datum/techweb_node/low_pressure_excavation
	display_name = "Low-Pressure Excavation"
	description = "Research of Proto-Kinetic Accelerators (PKAs), pneumatic guns renowned for their exceptional performance in low-pressure environments."
	prerequisite_nodes = list(/datum/techweb_node/mining, /datum/techweb_node/gas_compression)
	unlocked_designs = list(
		/datum/design/damage_mod,
		/datum/design/range_mod,
		/datum/design/cooldown_mod,
		/datum/design/trigger_guard_mod,
		/datum/design/hyperaccelerator,
		/datum/design/damage_mod/borg,
		/datum/design/range_mod/borg,
		/datum/design/cooldown_mod/borg,
		/datum/design/hyperaccelerator/borg,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SUPPLY)

/datum/techweb_node/plasma_mining
	display_name = "Plasma Beam Mining"
	description = "Engineers' plasma welders have proven highly effective in mining operations. This led to the development of a mech-mounted variant and an enhanced handheld cutter for miners."
	prerequisite_nodes = list(/datum/techweb_node/low_pressure_excavation, /datum/techweb_node/plasma_control)
	unlocked_designs = list(
		/datum/design/mech_plasma_cutter,
		/datum/design/plasmacutter_adv,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SUPPLY)

/datum/techweb_node/bitrunning
	display_name = "Bitrunning Technology"
	description = "Bluespace technology has led to the development of quantum-scale computing, which unlocks the means to materialize atomic structures while executing advanced programs."
	prerequisite_nodes = list(/datum/techweb_node/gaming, /datum/techweb_node/applied_bluespace)
	unlocked_designs = list(
		/datum/design/board/byteforge,
		/datum/design/board/quantum_console,
		/datum/design/board/netpod,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SUPPLY)

/datum/techweb_node/mining_adv
	display_name = "Advanced Mining Technology"
	description = "High-level mining equipment, pushing the boundaries of efficiency and effectiveness in resource extraction."
	prerequisite_nodes = list(/datum/techweb_node/plasma_mining)
	unlocked_designs = list(
		/datum/design/jackhammer,
		/datum/design/drill_diamond,
		/datum/design/mech_diamond_drill,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_SUPPLY)

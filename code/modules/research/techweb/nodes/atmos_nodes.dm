/datum/techweb_node/atmos
	id = TECHWEB_NODE_ATMOS
	starting_node = TRUE
	display_name = "Atmospherics"
	description = "Maintaining station air and related life support systems."
	design_ids = list(
		"atmos_control",
		"atmosalerts",
		"thermomachine",
		"space_heater",
		"scrubber",
		"generic_tank",
		"oxygen_tank",
		"plasma_tank",
		"plasmaman_tank_belt",
		"plasmarefiller",
		"extinguisher",
		"gas_filter",
		"plasmaman_gas_filter",
		"analyzer",
		"pipe_painter",
	)

/datum/techweb_node/gas_compression
	id = TECHWEB_NODE_GAS_COMPRESSION
	display_name = "Gas Compression"
	description = "Highly pressurized gases hold potential for unlocking immense energy capabilities."
	prereq_ids = list(TECHWEB_NODE_ATMOS)
	design_ids = list(
		"tank_compressor",
		"pump",
		"emergency_oxygen",
		"emergency_oxygen_engi",
		"power_turbine_console",
		"turbine_part_compressor",
		"turbine_part_rotor",
		"turbine_part_stator",
		"turbine_compressor",
		"turbine_rotor",
		"turbine_stator",
		"atmos_thermal",
		"pneumatic_seal",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/plasma_control
	id = TECHWEB_NODE_PLASMA_CONTROL
	display_name = "Controlled Plasma"
	description = "Experiments with high-pressure gases and electricity resulting in crystallization and controlled plasma reactions."
	prereq_ids = list(TECHWEB_NODE_GAS_COMPRESSION, TECHWEB_NODE_ENERGY_MANIPULATION)
	design_ids = list(
		"crystallizer",
		"electrolyzer",
		"pipe_scrubber",
		"pacman",
		"mech_generator",
		"plasmacutter",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	required_experiments = list(/datum/experiment/ordnance/gaseous/plasma)

/datum/techweb_node/fusion
	id = TECHWEB_NODE_FUSION
	display_name = "Fusion"
	description = "Investigating fusion reactor technology to achieve sustainable and efficient energy production through controlled plasma reactions involving noble gases."
	prereq_ids = list(TECHWEB_NODE_PLASMA_CONTROL)
	design_ids = list(
		"HFR_core",
		"HFR_corner",
		"HFR_fuel_input",
		"HFR_interface",
		"HFR_moderator_input",
		"HFR_waste_output",
		"adv_fire_extinguisher",
		"bolter_wrench",
		"rpd_loaded",
		"engine_goggles",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	required_experiments = list(/datum/experiment/ordnance/gaseous/bz)
	discount_experiments = list(/datum/experiment/ordnance/gaseous/nitrous_oxide = TECHWEB_TIER_3_POINTS)

/datum/techweb_node/exp_tools
	id = TECHWEB_NODE_EXP_TOOLS
	display_name = "Experimental Tools"
	description = "Enhances the functionality and versatility of station tools."
	prereq_ids = list(TECHWEB_NODE_FUSION)
	design_ids = list(
		"flatpacker",
		"handdrill",
		"exwelder",
		"jawsoflife",
		"rangedanalyzer",
		"rtd_loaded",
		"rcd_loaded",
		"rcd_ammo",
		"weldingmask",
		"magboots",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	discount_experiments = list(/datum/experiment/ordnance/gaseous/noblium = TECHWEB_TIER_4_POINTS)

/datum/techweb_node/rcd_upgrade
	id = TECHWEB_NODE_RCD_UPGRADE
	display_name = "Rapid Construction Device Upgrades"
	description = "New designs and enhancements for RCD and RPD."
	prereq_ids = list(TECHWEB_NODE_EXP_TOOLS, TECHWEB_NODE_PARTS_BLUESPACE)
	design_ids = list(
		"rcd_upgrade_silo_link",
		"rcd_upgrade_anti_interrupt",
		"rcd_upgrade_cooling",
		"rcd_upgrade_frames",
		"rcd_upgrade_furnishing",
		"rcd_upgrade_simple_circuits",
		"rpd_upgrade_unwrench",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)

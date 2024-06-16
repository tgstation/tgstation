#define TIER_1_POINTS 2000
#define TIER_2_POINTS 4000
#define TIER_3_POINTS 6000
#define TIER_4_POINTS 8000
#define TIER_5_POINTS 10000

/datum/techweb_node/atmos
	id = "atmos"
	starting_node = TRUE
	display_name = "Atmospherics"
	description = "Maintaining station air and related life support systems."
	design_ids = list(
		"atmos_control",
		"atmosalerts",
		"thermomachine",
		"space_heater",
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
	id = "gas_compression"
	display_name = "Gas Compression"
	description = "Highly pressurized gases hold potential for unlocking immense energy capabilities."
	prereq_ids = list("atmos")
	design_ids = list(
		"tank_compressor",
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
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_1_POINTS)

/datum/techweb_node/plasma_control
	id = "plasma_control"
	display_name = "Controlled Plasma"
	description = "Experiments with high-pressure gases and electricity resulting in crystallization and controlled plasma reactions."
	prereq_ids = list("gas_compression", "energy_manipulation")
	design_ids = list(
		"crystallizer",
		"electrolyzer",
		"pacman",
		"mech_generator",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_2_POINTS)
	discount_experiments = list(/datum/experiment/ordnance/gaseous/plasma = TIER_2_POINTS)

/datum/techweb_node/fusion
	id = "fusion"
	display_name = "Fusion"
	description = "Investigating fusion reactor technology to achieve sustainable and efficient energy production through controlled plasma reactions involving noble gases."
	prereq_ids = list("plasma_control")
	design_ids = list(
		"HFR_core",
		"HFR_corner",
		"HFR_fuel_input",
		"HFR_interface",
		"HFR_moderator_input",
		"HFR_waste_output",
		"bolter_wrench",
		"rpd_loaded",
		"engine_goggles",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_3_POINTS)
	required_experiments = list(/datum/experiment/ordnance/gaseous/bz)
	discount_experiments = list(/datum/experiment/ordnance/gaseous/nitrous_oxide = TIER_3_POINTS)

/datum/techweb_node/exp_tools
	id = "exp_tools"
	display_name = "Experimental Tools"
	description = "Enhances the functionality and versatility of station tools."
	prereq_ids = list("fusion", "plasma")
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
		"adv_fire_extinguisher",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_4_POINTS)
	discount_experiments = list(/datum/experiment/ordnance/gaseous/noblium = TIER_4_POINTS)

/datum/techweb_node/rcd_upgrade
	id = "rcd_upgrade"
	display_name = "Rapid Device Upgrade Designs"
	description = "New designs and enhancements for RCD and RPD."
	prereq_ids = list("exp_tools")
	design_ids = list(
		"rcd_upgrade_anti_interrupt",
		"rcd_upgrade_cooling",
		"rcd_upgrade_frames",
		"rcd_upgrade_furnishing",
		"rcd_upgrade_simple_circuits",
		"rpd_upgrade_unwrench",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_5_POINTS)

/datum/techweb_node/rcd_upgrade_adv
	id = "rcd_upgrade_adv"
	display_name = "Advanced RCD Designs Upgrade"
	description = "New RCD upgrade utilizing bluespace for instant matter delivery from centralized storage."
	prereq_ids = list("rcd_upgrade", "bluespace_travel")
	design_ids = list(
		"rcd_upgrade_silo_link",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TIER_5_POINTS)

#undef TIER_1_POINTS
#undef TIER_2_POINTS
#undef TIER_3_POINTS
#undef TIER_4_POINTS
#undef TIER_5_POINTS

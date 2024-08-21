/datum/techweb_node/mod_suit
	id = TECHWEB_NODE_MOD_SUIT
	starting_node = TRUE
	display_name = "Modular Suit"
	description = "Specialized back mounted power suits with various different modules."
	prereq_ids = list(TECHWEB_NODE_ROBOTICS)
	design_ids = list(
		"suit_storage_unit",
		"mod_shell",
		"mod_chestplate",
		"mod_helmet",
		"mod_gauntlets",
		"mod_boots",
		"mod_plating_standard",
		"mod_plating_civilian",
		"mod_paint_kit",
		"mod_storage",
		"mod_plasma",
		"mod_flashlight",
	)

/datum/techweb_node/mod_equip
	id = TECHWEB_NODE_MOD_EQUIP
	display_name = "Modular Suit Equipment"
	description = "More advanced modules, to improve modular suits."
	prereq_ids = list(TECHWEB_NODE_MOD_SUIT)
	design_ids = list(
		"modlink_scryer",
		"mod_clamp",
		"mod_tether",
		"mod_welding",
		"mod_safety",
		"mod_mouthhole",
		"mod_longfall",
		"mod_thermal_regulator",
		"mod_sign_radio",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/mod_entertainment
	id = TECHWEB_NODE_MOD_ENTERTAINMENT
	display_name = "Entertainment Modular Suit"
	description = "Powered suits for protection against low-humor environments."
	prereq_ids = list(TECHWEB_NODE_MOD_SUIT)
	design_ids = list(
		"mod_plating_cosmohonk",
		"mod_bikehorn",
		"mod_microwave_beam",
		"mod_waddle",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/mod_medical
	id = TECHWEB_NODE_MOD_MEDICAL
	display_name = "Medical Modular Suit"
	description = "Medical MODsuits for quick rescue purposes."
	prereq_ids = list(TECHWEB_NODE_MOD_SUIT, TECHWEB_NODE_CHEM_SYNTHESIS)
	design_ids = list(
		"mod_plating_medical",
		"mod_quick_carry",
		"mod_injector",
		"mod_organizer",
		"mod_patienttransport",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/mod_engi
	id = TECHWEB_NODE_MOD_ENGI
	display_name = "Engineering Modular Suits"
	description = "Engineering suits, for powered engineers."
	prereq_ids = list(TECHWEB_NODE_MOD_EQUIP)
	design_ids = list(
		"mod_plating_engineering",
		"mod_t_ray",
		"mod_magboot",
		"mod_constructor",
		"mod_mister_atmos",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/mod_security
	id = TECHWEB_NODE_MOD_SECURITY
	display_name = "Security Modular Suits"
	description = "Security suits for space crime handling."
	prereq_ids = list(TECHWEB_NODE_MOD_EQUIP)
	design_ids = list(
		"mod_mirage_grenade",
		"mod_plating_security",
		"mod_stealth",
		"mod_mag_harness",
		"mod_pathfinder",
		"mod_holster",
		"mod_sonar",
		"mod_projectile_dampener",
		"mod_criminalcapture",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/mod_medical_adv
	id = TECHWEB_NODE_MOD_MEDICAL_ADV
	display_name = "Field Surgery Modules"
	description = "Medical MODsuit equipment designed for conducting surgical operations in field conditions."
	prereq_ids = list(TECHWEB_NODE_MOD_MEDICAL, TECHWEB_NODE_SURGERY_ADV)
	design_ids = list(
		"mod_defib",
		"mod_threadripper",
		"mod_surgicalprocessor",
		"mod_statusreadout",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)

/datum/techweb_node/mod_engi_adv
	id = TECHWEB_NODE_MOD_ENGI_ADV
	display_name = "Advanced Engineering Modular Suit"
	description = "Advanced Engineering suits, for advanced powered engineers."
	prereq_ids = list(TECHWEB_NODE_MOD_ENGI)
	design_ids = list(
		"mod_plating_atmospheric",
		"mod_jetpack",
		"mod_rad_protection",
		"mod_emp_shield",
		"mod_storage_expanded",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)

/datum/techweb_node/mod_engi_adv/New()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_RADIOACTIVE_NEBULA)) //we'll really need the rad protection modsuit module
		starting_node = TRUE
	return ..()

/datum/techweb_node/mod_anomaly
	id = TECHWEB_NODE_MOD_ANOMALY
	display_name = "Anomalock Modular Suit"
	description = "Modules for MODsuits that require anomaly cores to function."
	prereq_ids = list(TECHWEB_NODE_MOD_ENGI_ADV, TECHWEB_NODE_ANOMALY_RESEARCH)
	design_ids = list(
		"mod_antigrav",
		"mod_teleporter",
		"mod_kinesis",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)

/datum/techweb_node/mod_suit
	id = "mod_suit"
	starting_node = TRUE
	display_name = "Modular Exosuit"
	description = "Specialized back mounted power suits with various different modules."
	prereq_ids = list("robotics")
	design_ids = list(
		"suit_storage_unit",
		"mod_shell",
		"mod_chestplate",
		"mod_helmet",
		"mod_gauntlets",
		"mod_boots",
		"mod_plating_standard",
		"mod_paint_kit",
		"mod_storage",
		"mod_plasma",
		"mod_flashlight",
	)

/datum/techweb_node/mod_equip
	id = "mod_equip"
	display_name = "Modular Suit Equipment"
	description = "More advanced modules, to improve modular suits."
	prereq_ids = list("mod_suit")
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
	id = "mod_entertainment"
	display_name = "Entertainment Modular Suit"
	description = "Powered suits for protection against low-humor environments."
	prereq_ids = list("mod_suit")
	design_ids = list(
		"mod_plating_cosmohonk",
		"mod_bikehorn",
		"mod_microwave_beam",
		"mod_waddle",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/mod_medical
	id = "mod_medical"
	display_name = "Medical Modular Suit"
	description = "Medical exosuits for quick rescue purposes."
	prereq_ids = list("mod_suit", "chem_synthesis")
	design_ids = list(
		"mod_plating_medical",
		"mod_quick_carry",
		"mod_injector",
		"mod_organ_thrower",
		"mod_patienttransport",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/mod_engi
	id = "mod_engi"
	display_name = "Engineering Modular Suits"
	description = "Engineering suits, for powered engineers."
	prereq_ids = list("mod_equip")
	design_ids = list(
		"mod_plating_engineering",
		"mod_t_ray",
		"mod_magboot",
		"mod_constructor",
		"mod_mister_atmos",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/mod_security
	id = "mod_security"
	display_name = "Security Modular Suits"
	description = "Security suits for space crime handling."
	prereq_ids = list("mod_equip")
	design_ids = list(
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
	id = "mod_medical_adv"
	display_name = "Field Surgery Modules"
	description = "Medical exosuit equipment designed for conducting surgical operations in field conditions."
	prereq_ids = list("mod_medical", "surgery_adv")
	design_ids = list(
		"mod_defib",
		"mod_threadripper",
		"mod_surgicalprocessor",
		"mod_statusreadout",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)

/datum/techweb_node/mod_engi_adv
	id = "mod_engi_adv"
	display_name = "Advanced Engineering Modular Suit"
	description = "Advanced Engineering suits, for advanced powered engineers."
	prereq_ids = list("mod_engi")
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
	id = "mod_anomaly"
	display_name = "Anomalock Modular Suit"
	description = "Modules for exosuits that require anomaly cores to function."
	prereq_ids = list("mod_engi_adv", "anomaly_research")
	design_ids = list(
		"mod_antigrav",
		"mod_teleporter",
		"mod_kinesis",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)

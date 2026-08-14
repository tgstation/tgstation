/datum/techweb_node/mod_suit
	display_name = "Modular Suits"
	description = "Specialized back mounted power suits with various different modules."
	node_flags = parent_type::node_flags | TECHWEB_NODE_STARTER
	prerequisite_nodes = list(/datum/techweb_node/robotics)
	unlocked_designs = list(
		/datum/design/board/suit_storage_unit,
		/datum/design/mod_shell,
		/datum/design/mod_chestplate,
		/datum/design/mod_helmet,
		/datum/design/mod_gauntlets,
		/datum/design/mod_boots,
		/datum/design/mod_plating,
		/datum/design/mod_plating/civilian,
		/datum/design/mod_paint_kit,
		/datum/design/module/mod_storage,
		/datum/design/module/mod_plasma_stabilizer,
		/datum/design/module/mod_flashlight,
	)

/datum/techweb_node/mod_equip
	display_name = "Modular Suit Equipment"
	description = "More advanced modules, to improve modular suits."
	prerequisite_nodes = list(/datum/techweb_node/mod_suit)
	unlocked_designs = list(
		/datum/design/modlink_scryer,
		/datum/design/module/mod_tether,
		/datum/design/module/mod_visor_welding,
		/datum/design/module/mod_longfall,
		/datum/design/module/mod_thermal_regulator,
		/datum/design/module/mod_glove_translator,
		/datum/design/module/mod_storage_expanded,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/mod_service
	display_name = "Civilian Modular Suits"
	description = "Civilian MODsuits for dignified living."
	prerequisite_nodes = list(/datum/techweb_node/mod_suit)
	unlocked_designs = list(
		/datum/design/module/mod_clamp,
		/datum/design/module/mod_head_protection,
		/datum/design/module/mod_mouthhole,
		/datum/design/module/mister_janitor,
		/datum/design/mod_plating/portable_suit
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS / 2)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_SERVICE)

/datum/techweb_node/mod_entertainment
	display_name = "Entertainment Modular Suits"
	description = "Powered suits for protection against low-humor environments."
	prerequisite_nodes = list(/datum/techweb_node/mod_suit)
	unlocked_designs = list(
		/datum/design/mod_plating/cosmohonk,
		/datum/design/module/mod_bikehorn,
		/datum/design/module/mod_microwave_beam,
		/datum/design/module/mod_waddle,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_SERVICE)

/datum/techweb_node/mod_medical
	display_name = "Medical Modular Suits"
	description = "Medical MODsuits for quick rescue purposes."
	prerequisite_nodes = list(/datum/techweb_node/mod_suit, /datum/techweb_node/chem_synthesis)
	unlocked_designs = list(
		/datum/design/mod_plating/medical,
		/datum/design/module/mod_quick_carry,
		/datum/design/module/mod_injector,
		/datum/design/module/mod_organizer,
		/datum/design/module/patienttransport,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/mod_engi
	display_name = "Engineering Modular Suits"
	description = "Engineering suits, for powered engineers."
	prerequisite_nodes = list(/datum/techweb_node/mod_equip)
	unlocked_designs = list(
		/datum/design/mod_plating/engineering,
		/datum/design/module/mod_t_ray,
		/datum/design/module/mod_magboot,
		/datum/design/module/mod_constructor,
		/datum/design/module/mister_atmos,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_ENGINEERING)

/datum/techweb_node/mod_security
	display_name = "Security Modular Suits"
	description = "Security suits for space crime handling."
	prerequisite_nodes = list(/datum/techweb_node/mod_equip)
	unlocked_designs = list(
		/datum/design/module/mirage,
		/datum/design/module/mod_stealth,
		/datum/design/module/mod_mag_harness,
		/datum/design/module/mod_pathfinder,
		/datum/design/module/mod_holster,
		/datum/design/module/mod_sonar,
		/datum/design/module/projectile_dampener,
		/datum/design/module/criminalcapture,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_SECURITY)

/datum/techweb_node/mod_medical_adv
	display_name = "Field Surgery Modules"
	description = "Medical MODsuit equipment designed for conducting surgical operations in field conditions."
	prerequisite_nodes = list(/datum/techweb_node/mod_medical, /datum/techweb_node/surgery_adv)
	unlocked_designs = list(
		/datum/design/module/defibrillator,
		/datum/design/module/threadripper,
		/datum/design/module/surgicalprocessor,
		/datum/design/module/statusreadout,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/mod_engi_adv
	display_name = "Advanced Engineering Modular Suits"
	description = "Advanced Engineering suits, for advanced powered engineers."
	prerequisite_nodes = list(/datum/techweb_node/mod_engi)
	unlocked_designs = list(
		/datum/design/mod_plating/atmospheric,
		/datum/design/module/mod_jetpack,
		/datum/design/module/mod_rad_protection,
		/datum/design/module/mod_emp_shield,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_ENGINEERING)

/datum/techweb_node/mod_engi_adv/New()
	. = ..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_RADIOACTIVE_NEBULA)) //we'll really need the rad protection modsuit module
		node_flags |= TECHWEB_NODE_STARTER

/datum/techweb_node/mod_anomaly
	display_name = "Anomalock Modular Suits"
	description = "Modules for MODsuits that require anomaly cores to function."
	prerequisite_nodes = list(/datum/techweb_node/mod_engi_adv, /datum/techweb_node/anomaly_research)
	unlocked_designs = list(
		/datum/design/module/mod_antigrav,
		/datum/design/module/mod_teleporter,
		/datum/design/module/mod_kinesis,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

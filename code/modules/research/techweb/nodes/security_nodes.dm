/datum/techweb_node/basic_arms
	id = TECHWEB_NODE_BASIC_ARMS
	starting_node = TRUE
	display_name = "Basic Arms"
	description = "Ballistics can be unpredictable in space."
	design_ids = list(
		"toy_armblade",
		"toygun",
		"c38_rubber",
		"sec_38",
		"capbox",
		"foam_dart",
		"sec_beanbag_slug",
		"sec_dart",
		"sec_Islug",
		"sec_rshot",
	)

/datum/techweb_node/sec_equip
	id = TECHWEB_NODE_SEC_EQUIP
	display_name = "Security Equipment"
	description = "All the essentials to subdue a mime."
	prereq_ids = list(TECHWEB_NODE_BASIC_ARMS)
	design_ids = list(
		"secdata",
		"mining",
		"prisonmanage",
		"rdcamera",
		"seccamera",
		"security_photobooth",
		"photobooth",
		"scanner_gate",
		"pepperspray",
		"dragnet_beacon",
		"inspector",
		"evidencebag",
		"zipties",
		"seclite",
		"electropack",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/riot_supression
	id = TECHWEB_NODE_RIOT_SUPRESSION
	display_name = "Riot Supression"
	description = "When you are on the opposing side of a revolutionary movement."
	prereq_ids = list(TECHWEB_NODE_SEC_EQUIP)
	design_ids = list(
		"clown_firing_pin",
		"pin_testing",
		"pin_loyalty",
		"tele_shield",
		"ballistic_shield",
		"handcuffs_s",
		"bola_energy",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/explosives
	id = TECHWEB_NODE_EXPLOSIVES
	display_name = "Explosives"
	description = "For once, intentional explosions."
	prereq_ids = list(TECHWEB_NODE_RIOT_SUPRESSION)
	design_ids = list(
		"large_grenade",
		"adv_grenade",
		"pyro_grenade",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	required_experiments = list(/datum/experiment/ordnance/explosive/lowyieldbomb)

/datum/techweb_node/exotic_ammo
	id = TECHWEB_NODE_EXOTIC_AMMO
	display_name = "Exotic Ammunition"
	description = "Specialized bullets designed to ignite, freeze, and inflict various other effects on targets, expanding combat capabilities."
	prereq_ids = list(TECHWEB_NODE_EXPLOSIVES)
	design_ids = list(
		"c38_hotshot",
		"c38_iceblox",
		"techshotshell",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	discount_experiments = list(/datum/experiment/ordnance/explosive/highyieldbomb = TECHWEB_TIER_4_POINTS)

/datum/techweb_node/electric_weapons
	id = TECHWEB_NODE_ELECTRIC_WEAPONS
	display_name = "Electric Weaponry"
	description = "Energy-based weaponry designed for both lethal and non-lethal applications."
	prereq_ids = list(TECHWEB_NODE_RIOT_SUPRESSION)
	design_ids = list(
		"stunrevolver",
		"ioncarbine",
		"temp_gun",
		"lasershell",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)

/datum/techweb_node/beam_weapons
	id = TECHWEB_NODE_BEAM_WEAPONS
	display_name = "Advanced Beam Weaponry"
	description = "So advanced, even engineers are baffled by its operational principles."
	prereq_ids = list(TECHWEB_NODE_ELECTRIC_WEAPONS)
	design_ids = list(
		"xray_laser",
		"nuclear_gun",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)

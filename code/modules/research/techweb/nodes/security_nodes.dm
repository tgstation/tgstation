/datum/techweb_node/basic_arms
	display_name = "Basic Arms"
	description = "Ballistics can be unpredictable in space."
	node_flags = parent_type::node_flags | TECHWEB_NODE_STARTER
	unlocked_designs = list(
		/datum/design/toy_armblade,
		/datum/design/toy_katana,
		/datum/design/toygun,
		/datum/design/c38_rubber,
		/datum/design/c38_rubber_mag,
		/datum/design/c38/sec,
		/datum/design/c38_mag,
		/datum/design/capbox,
		/datum/design/foam_dart,
		/datum/design/beanbag_slug/sec,
		/datum/design/shotgun_dart/sec,
		/datum/design/incendiary_slug/sec,
		/datum/design/rubbershot/sec,
	)

/datum/techweb_node/sec_equip
	display_name = "Security Equipment"
	description = "All the essentials to subdue a mime."
	prerequisite_nodes = list(/datum/techweb_node/basic_arms)
	unlocked_designs = list(
		/datum/design/board/secdata,
		/datum/design/board/mining,
		/datum/design/board/prisonmanage,
		/datum/design/board/rdcamera,
		/datum/design/board/seccamera,
		/datum/design/board/security_photobooth,
		/datum/design/board/photobooth,
		/datum/design/board/scanner_gate,
		/datum/design/pepperspray,
		/datum/design/dragnet_beacon,
		/datum/design/inspector,
		/datum/design/evidencebag,
		/datum/design/zipties,
		/datum/design/seclite,
		/datum/design/electropack,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY)


/datum/techweb_node/riot_supression
	display_name = "Riot Supression"
	description = "When you are on the opposing side of a revolutionary movement."
	prerequisite_nodes = list(/datum/techweb_node/sec_equip)
	unlocked_designs = list(
		/datum/design/clown_firing_pin,
		/datum/design/pin_testing,
		/datum/design/pin_mindshield,
		/datum/design/tele_shield,
		/datum/design/ballistic_shield,
		/datum/design/handcuffs/sec,
		/datum/design/bola_energy,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY)

/datum/techweb_node/explosives
	display_name = "Explosives"
	description = "For once, intentional explosions."
	prerequisite_nodes = list(/datum/techweb_node/riot_supression)
	unlocked_designs = list(
		/datum/design/large_grenade,
		/datum/design/adv_grenade,
		/datum/design/pyro_grenade,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	required_experiments = list(/datum/experiment/ordnance/explosive/lowyieldbomb)
	announce_channels = list(RADIO_CHANNEL_SECURITY, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/exotic_ammo
	display_name = "Exotic Ammunition"
	description = "Specialized bullets designed to ignite, freeze, and inflict various other effects on targets, expanding combat capabilities."
	prerequisite_nodes = list(/datum/techweb_node/explosives)
	unlocked_designs = list(
		/datum/design/c38_hotshot,
		/datum/design/c38_hotshot_mag,
		/datum/design/c38_iceblox,
		/datum/design/c38_iceblox_mag,
		/datum/design/c38_trac,
		/datum/design/c38_trac_mag,
		/datum/design/c38_true,
		/datum/design/c38_true_mag,
		/datum/design/techshell,
		/datum/design/flechette,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	discount_experiments = list(/datum/experiment/ordnance/explosive/highyieldbomb = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY)

/datum/techweb_node/electric_weapons
	display_name = "Electric Weaponry"
	description = "Energy-based weaponry designed for both lethal and non-lethal applications."
	prerequisite_nodes = list(/datum/techweb_node/riot_supression)
	unlocked_designs = list(
		/datum/design/stunrevolver,
		/datum/design/ioncarbine,
		/datum/design/temp_gun,
		/datum/design/lasershell,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY)

/datum/techweb_node/beam_weapons
	display_name = "Advanced Beam Weaponry"
	description = "So advanced, even engineers are baffled by its operational principles."
	prerequisite_nodes = list(/datum/techweb_node/electric_weapons)
	unlocked_designs = list(
		/datum/design/xray,
		/datum/design/nuclear_gun,
		/datum/design/c38_flare,
		/datum/design/c38_flare_mag,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY)

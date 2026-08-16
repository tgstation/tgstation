/datum/techweb_node/mod_suit
	display_name = "Модульные костюмы"
	description = "Специализированные силовые костюмы, устанавливаемые на спине, с различными МОДулями."
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
	display_name = "Оборудование для модульных костюмов"
	description = "Более совершенные МОДули для улучшения модульных костюмов."
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
	display_name = "Гражданские МОДули"
	description = "Гражданские модульные костюмы для достойной жизни."
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
	display_name = "Развлекательные МОДули"
	description = "Модульные костюмы для защиты против среды с низким содержанием юмора."
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
	display_name = "Медицинские МОДули"
	description = "Медицинский МОДкостюм для быстрых спасательных операций."
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
	display_name = "Инженерные МОДули"
	description = "Инженерный МОДкостюм для работ в особо опасных условиях."
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
	display_name = "МОДули службы безопасности"
	description = "МОДкостюмы службы безопасности для ловли криминальных косманавтов."
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
	display_name = "МОДули полевой хирургии"
	description = "Медицинские МОДули, разработанное для проведения хирургических операций в полевых условиях."
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
	display_name = "Продвинутые инженерные МОДули"
	description = "Продвинутые инженерные МОДули для работы в особо опасных условиях."
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
	display_name = "Аномалок МОДули"
	description = "МОДули для МОДкостюмов, что требуют аномальные ядра для функциональности."
	prerequisite_nodes = list(/datum/techweb_node/mod_engi_adv, /datum/techweb_node/anomaly_research)
	unlocked_designs = list(
		/datum/design/module/mod_antigrav,
		/datum/design/module/mod_teleporter,
		/datum/design/module/mod_kinesis,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

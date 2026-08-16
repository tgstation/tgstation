/datum/techweb_node/robotics
	display_name = "Робототехника"
	description = "Программируемые машины, что делают нас ленивее."
	node_flags = parent_type::node_flags | TECHWEB_NODE_STARTER
	unlocked_designs = list(
		/datum/design/board/navbeacon,
		/datum/design/board/mechfab,
		/datum/design/paicard,
	)

/datum/techweb_node/exodrone
	display_name = "Исследовательские дроны"
	description = "Адаптированные аркадные автоматы для скрытого использования навыков геймеров в управлении настоящими дронами в практических целях."
	prerequisite_nodes = list(/datum/techweb_node/robotics)
	unlocked_designs = list(
		/datum/design/board/exodrone_console,
		/datum/design/board/exodrone_launcher,
		/datum/design/board/exoscanner,
		/datum/design/board/exoscanner_console,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

// AI root node
/datum/techweb_node/ai
	display_name = "Искусственный интеллект"
	description = "Исследование систем искусственного интеллекта, более интеллектуальных, чем весь экипаж вместе взятый."
	prerequisite_nodes = list(/datum/techweb_node/robotics)
	unlocked_designs = list(
		/datum/design/board/aicore,
		/datum/design/board/aifixer,
		/datum/design/board/ai_law_rack/broadcaster,
		/datum/design/board/ai_law_rack,
		/datum/design/board/ai_law_rack/portable,
		/datum/design/board/asimov,
		/datum/design/boris_ai_controller,
		/datum/design/board/corporate_module,
		/datum/design/board/default_module,
		/datum/design/board/drone_module,
		/datum/design/board/freeform_module,
		/datum/design/intellicard,
		/datum/design/mecha_tracking_ai_control,
		/datum/design/board/nutimov_module,
		/datum/design/board/oxygen_module,
		/datum/design/board/paladin_module,
		/datum/design/board/protectstation_module,
		/datum/design/board/quarantine_module,
		/datum/design/board/robocop_module,
		/datum/design/board/safeguard_module,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/ai/New()
	. = ..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_HUMAN_AI))
		unlocked_designs -= list(
			/datum/design/board/aicore,
			/datum/design/board/aifixer,
			/datum/design/boris_ai_controller,
			/datum/design/intellicard,
			/datum/design/mecha_tracking_ai_control,
		)
	else if(HAS_TRAIT(SSstation, STATION_TRAIT_UNIQUE_AI))
		research_costs[TECHWEB_POINT_TYPE_GENERIC] *= 3

/datum/techweb_node/ai_laws
	display_name = "Улучшенные модули ИИ"
	description = "Углубление в сложные директивы ИИ, в надежде, что они не приведут к вымиранию человечества."
	prerequisite_nodes = list(/datum/techweb_node/ai)
	unlocked_designs = list(
		/datum/design/ai_power_transfer,
		/datum/design/board/antimov_module,
		/datum/design/board/asimovpp_module,
		/datum/design/board/balance_module,
		/datum/design/board/damaged,
		/datum/design/board/dungeon_master_module,
		/datum/design/board/freeformcore_module,
		/datum/design/board/hippocratic_module,
		/datum/design/board/hulkamania_module,
		/datum/design/board/liveandletlive_module,
		/datum/design/board/maintain_module,
		/datum/design/board/onehuman_module,
		/datum/design/board/overlord_module,
		/datum/design/board/painter_module,
		/datum/design/board/paladin_devotion_module,
		/datum/design/board/peacekeeper_module,
		/datum/design/board/reporter_module,
		/datum/design/board/ten_commandments_module,
		/datum/design/board/thermurderdynamic_module,
		/datum/design/board/thinkermov_module,
		/datum/design/board/tyrant_module,
		/datum/design/board/yesman_module,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_COMMAND)

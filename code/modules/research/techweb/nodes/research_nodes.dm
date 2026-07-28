/datum/techweb_node/fundamental_sci
	display_name = "Fundamental Science"
	description = "Establishing the bedrock of scientific understanding, paving the way for deeper exploration and theoretical inquiry."
	node_flags = parent_type::node_flags | TECHWEB_NODE_STARTER
	unlocked_designs = list(
		/datum/design/board/rdserver,
		/datum/design/board/rdservercontrol,
		/datum/design/board/rdconsole,
		/datum/design/tech_disk,
		/datum/design/board/doppler_array,
		/datum/design/board/experimentor,
		/datum/design/board/destructive_analyzer,
		/datum/design/board/destructive_scanner,
		/datum/design/experi_scanner,
		/datum/design/laptop,
		/datum/design/portabledrive/basic,
		/datum/design/portabledrive/advanced,
		/datum/design/portabledrive/super,
	)

/datum/techweb_node/bluespace_theory
	display_name = "Bluespace Theory"
	description = "Basic studies into the mysterious alternate dimension known as bluespace."
	prerequisite_nodes = list(/datum/techweb_node/fundamental_sci)
	unlocked_designs = list(
		/datum/design/bluespace_crystal,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/applied_bluespace
	display_name = "Applied Bluespace Research"
	description = "With a heightened grasp of bluespace dynamics, sophisticated applications and technologies can be devised using data from bluespace crystal analyses."
	prerequisite_nodes = list(/datum/techweb_node/bluespace_theory)
	unlocked_designs = list(
		/datum/design/board/ore_silo,
		/datum/design/miningsatchel_holding,
		/datum/design/board/plumbing_receiver,
		/datum/design/bluespacebeaker,
		/datum/design/adv_watering_can,
		/datum/design/coffeepot_bluespace,
		/datum/design/bluespacesyringe,
		/datum/design/blutrash,
		/datum/design/light_replacer_blue,
		/datum/design/bluespacebodybag,
		/datum/design/radio_navigation_beacon,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	discount_experiments = list(/datum/experiment/scanning/points/bluespace_crystal = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL, RADIO_CHANNEL_SERVICE, RADIO_CHANNEL_SUPPLY)

/datum/techweb_node/bluespace_travel
	display_name = "Bluespace Travel"
	description = "Facilitate teleportation methods based on bluespace principles to revolutionize logistical efficiency."
	prerequisite_nodes = list(/datum/techweb_node/applied_bluespace)
	unlocked_designs = list(
		/datum/design/board/teleconsole,
		/datum/design/board/teleport_station,
		/datum/design/board/teleport_hub,
		/datum/design/board/launchpad_console,
		/datum/design/board/quantumpad,
		/datum/design/board/launchpad,
		/datum/design/bluespace_pod,
		/datum/design/quantum_keycard,
		/datum/design/swapper,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/anomaly_research
	display_name = "Anomaly Research"
	description = "Delving into the study of mysterious anomalies to investigate methods to refine and harness their unpredictable energies."
	prerequisite_nodes = list(/datum/techweb_node/applied_bluespace)
	unlocked_designs = list(
		/datum/design/board/anomaly_refinery,
		/datum/design/anomaly_neutralizer,
		/datum/design/reactive_armour,
		/datum/design/space_furnace,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/anomaly_shells
	display_name = "Advanced Anomaly Shells"
	description = "New shells designed to utilize anomaly cores, maximizing their potential in innovative ways."
	prerequisite_nodes = list(/datum/techweb_node/anomaly_research)
	unlocked_designs = list(
		/datum/design/bag_holding,
		/datum/design/cybernetic_heart/anomalock,
		/datum/design/module/mod_storage_holding,
		/datum/design/wormhole_projector,
		/datum/design/gravitygun,
		/datum/design/polymorph_belt,
		/datum/design/perceptomatrix,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)
	discount_experiments = list(/datum/experiment/scanning/points/anomalies = TECHWEB_TIER_5_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

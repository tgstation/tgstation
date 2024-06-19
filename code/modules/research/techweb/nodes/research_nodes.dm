/datum/techweb_node/fundamental_sci
	id = "fundamental_sci"
	starting_node = TRUE
	display_name = "Fundamental Science"
	description = "Establishing the bedrock of scientific understanding, paving the way for deeper exploration and theoretical inquiry."
	design_ids = list(
		"rdserver",
		"rdservercontrol",
		"rdconsole",
		"tech_disk",
		"doppler_array",
		"experimentor",
		"destructive_analyzer",
		"destructive_scanner",
		"experi_scanner",
		"ntnet_relay",
		"laptop",
		"portadrive_basic",
		"portadrive_advanced",
		"portadrive_super",
	)

/datum/techweb_node/bluespace_theory
	id = "bluespace_theory"
	display_name = "Bluespace Theory"
	description = "Basic studies into the mysterious alternate dimension known as bluespace."
	prereq_ids = list("fundamental_sci")
	design_ids = list(
		"bluespace_crystal",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/applied_bluespace
	id = "applied_bluespace"
	display_name = "Applied Bluespace Research"
	description = "With a heightened grasp of bluespace dynamics, sophisticated applications and technologies can be devised using data from bluespace crystal analyses."
	prereq_ids = list("bluespace_theory")
	design_ids = list(
		"ore_silo",
		"minerbag_holding",
		"plumbing_receiver",
		"bluespacebeaker",
		"adv_watering_can",
		"bluespace_coffeepot",
		"bluespacesyringe",
		"blutrash",
		"light_replacer_blue",
		"bluespacebodybag",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	required_experiments = list(/datum/experiment/scanning/bluespace_crystal)

/datum/techweb_node/bluespace_travel
	id = "bluespace_travel"
	display_name = "Bluespace Travel"
	description = "Facilitate teleportation methods based on bluespace principles to revolutionize logistical efficiency."
	prereq_ids = list("applied_bluespace")
	design_ids = list(
		"teleconsole",
		"tele_station",
		"tele_hub",
		"launchpad_console",
		"quantumpad",
		"launchpad",
		"bluespace_pod",
		"quantum_keycard",
		"swapper",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)

/datum/techweb_node/anomaly_research
	id = "anomaly_research"
	display_name = "Anomaly Research"
	description = "Delving into the study of mysterious anomalies to investigate methods to refine and harness their unpredictable energies."
	prereq_ids = list("applied_bluespace")
	design_ids = list(
		"anomaly_refinery",
		"anomaly_neutralizer",
		"reactive_armour",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)

/datum/techweb_node/anomaly_shells
	id = "anomaly_shells"
	display_name = "Advanced Anomaly Shells"
	description = "New shells designed to utilize anomaly cores, maximizing their potential in innovative ways."
	prereq_ids = list("anomaly_research")
	design_ids = list(
		"bag_holding",
		"wormholeprojector",
		"gravitygun",
		"polymorph_belt"
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)

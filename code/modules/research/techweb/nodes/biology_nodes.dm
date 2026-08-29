/datum/techweb_node/bio_scan
	display_name = "Biological Scan"
	description = "Advanced technology for analyzing patient health and reagent compositions, ensuring precise diagnostics and treatment in the medical bay."
	prerequisite_nodes = list(/datum/techweb_node/medbay_equip)
	unlocked_designs = list(
		/datum/design/healthanalyzer,
		/datum/design/autopsy_scanner,
		/datum/design/genescanner,
		/datum/design/board/medical_kiosk,
		/datum/design/board/chem_master,
		/datum/design/ph_meter,
		/datum/design/sci_goggles,
		/datum/design/module/mod_reagent_scanner,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/cytology
	display_name = "Cytology"
	description = "Cellular biology research focused on cultivation of limbs and diverse organisms from cells."
	prerequisite_nodes = list(/datum/techweb_node/bio_scan)
	unlocked_designs = list(
		/datum/design/board/limbgrower,
		/datum/design/board/pandemic,
		/datum/design/board/vatgrower,
		/datum/design/petridish,
		/datum/design/swab,
		/datum/design/biopsy_tool,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/xenobiology
	display_name = "Xenobiology"
	description = "Exploration of non-human biology, unlocking the secrets of extraterrestrial lifeforms and their unique biological processes."
	prerequisite_nodes = list(/datum/techweb_node/cytology)
	unlocked_designs = list(
		/datum/design/board/xenobiocamera,
		/datum/design/slime_scanner,
		/datum/design/limb_disk/ethereal,
		/datum/design/limb_disk/felinid,
		/datum/design/limb_disk/lizard,
		/datum/design/limb_disk/plasmaman,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	discount_experiments = list(/datum/experiment/scanning/cytology/slime = TECHWEB_TIER_3_POINTS)

/datum/techweb_node/gene_engineering
	display_name = "Gene Engineering"
	description = "Research into sophisticated DNA manipulation techniques, enabling the modification of human genetic traits to unlock specific abilities and enhancements."
	prerequisite_nodes = list(/datum/techweb_node/selection, /datum/techweb_node/xenobiology)
	unlocked_designs = list(
		/datum/design/board/dnascanner,
		/datum/design/board/scan_console,
		/datum/design/dna_disk,
		/datum/design/board/dnainfuser,
		/datum/design/module/mod_dna_lock,
		/datum/design/flesh_reshapers,
		/datum/design/flesh_reshapers/medical,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	discount_experiments = list(/datum/experiment/scanning/people/mutant = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

// Botany root node
/datum/techweb_node/botany_equip
	display_name = "Botany Equipment"
	description = "Essential tools for maintaining onboard gardens, supporting plant growth in the unique environment of the space station."
	node_flags = parent_type::node_flags | TECHWEB_NODE_STARTER
	unlocked_designs = list(
		/datum/design/board/seed_extractor,
		/datum/design/plant_analyzer,
		/datum/design/watering_can,
		/datum/design/spade,
		/datum/design/cultivator,
		/datum/design/secateurs,
		/datum/design/hatchet,
	)

/datum/techweb_node/hydroponics
	display_name = "Hydroponics"
	description = "Research into advanced hydroponic systems for efficient and sustainable plant cultivation."
	prerequisite_nodes = list(/datum/techweb_node/botany_equip, /datum/techweb_node/chem_synthesis)
	unlocked_designs = list(
		/datum/design/board/biogenerator,
		/datum/design/board/hydroponics,
		/datum/design/portaseeder,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SERVICE)

/datum/techweb_node/selection
	display_name = "Artificial Selection"
	description = "Advancement in plant cultivation techniques through artificial selection, enabling precise manipulation of plant DNA."
	prerequisite_nodes = list(/datum/techweb_node/hydroponics)
	unlocked_designs = list(
		/datum/design/flora_gun,
		/datum/design/geneshears,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	required_experiments = list(/datum/experiment/scanning/random/plants/wild)
	discount_experiments = list(/datum/experiment/scanning/random/plants/traits = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SERVICE)

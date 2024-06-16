/datum/techweb_node/bio_scan
	id = "bio_scan"
	display_name = "Biological Scan"
	description = "Advanced technology for analyzing patient health and reagent compositions, ensuring precise diagnostics and treatment in the medical bay."
	prereq_ids = list("medbay_equip")
	design_ids = list(
		"healthanalyzer",
		"autopsyscanner",
		"medical_kiosk",
		"chem_master",
		"ph_meter",
		"scigoggles",
		"mod_reagent_scanner",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/cytology
	id = "cytology"
	display_name = "Cytology"
	description = "Cellular biology research focused on cultivation of limbs and diverse organisms from cells."
	prereq_ids = list("bio_scan")
	design_ids = list(
		"limbgrower",
		"pandemic",
		"petri_dish",
		"swab",
		"biopsy_tool",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)

/datum/techweb_node/xenobiology
	id = "xenobiology"
	display_name = "Xenobiology"
	description = "Exploration of non-human biology, unlocking the secrets of extraterrestrial lifeforms and their unique biological processes."
	prereq_ids = list("cytology")
	design_ids = list(
		"xenobioconsole",
		"slime_scanner",
		"limbdesign_ethereal",
		"limbdesign_felinid",
		"limbdesign_lizard",
		"limbdesign_plasmaman",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	required_experiments = list(/datum/experiment/scanning/random/cytology)

/datum/techweb_node/gene_engineering
	id = "gene_engineering"
	display_name = "Gene Engineering"
	description = "Research into sophisticated DNA manipulation techniques, enabling the modification of human genetic traits to unlock specific abilities and enhancements."
	prereq_ids = list("selection", "xenobiology")
	design_ids = list(
		"dnascanner",
		"scan_console",
		"dna_disk",
		"dnainfuser",
		"genescanner",
		"mod_dna_lock",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	discount_experiments = list(
		/datum/experiment/scanning/random/plants/traits = TECHWEB_TIER_2_POINTS,
		/datum/experiment/scanning/points/slime/hard = TECHWEB_TIER_2_POINTS,
		)

/datum/techweb_node/oldstation_surgery
	id = TECHWEB_NODE_OLDSTATION_SURGERY
	display_name = "Experimental Dissection"
	description = "Grants access to experimental dissections, which allows generation of research points."
	prereq_ids = list(TECHWEB_NODE_MEDBAY_EQUIP)
	design_ids = list(
		"surgery_oldstation_dissection",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	hidden = TRUE
	show_on_wiki = FALSE

/datum/techweb_node/surgery
	id = TECHWEB_NODE_SURGERY
	display_name = "Improved Wound-Tending"
	description = "Who would have known being more gentle with a hemostat decreases patient pain?"
	prereq_ids = list(TECHWEB_NODE_MEDBAY_EQUIP)
	design_ids = list(
		"surgery_heal_brute_upgrade",
		"surgery_heal_burn_upgrade",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/surgery_adv
	id = TECHWEB_NODE_SURGERY_ADV
	display_name = "Advanced Surgery"
	description = "When simple medicine doesn't cut it."
	prereq_ids = list(TECHWEB_NODE_SURGERY)
	design_ids = list(
		"harvester",
		"surgery_heal_brute_upgrade_femto",
		"surgery_heal_burn_upgrade_femto",
		"surgery_heal_combo",
		"surgery_lobotomy",
		"surgery_wing_reconstruction",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	required_experiments = list(/datum/experiment/autopsy/human)

/datum/techweb_node/surgery_exp
	id = TECHWEB_NODE_SURGERY_EXP
	display_name = "Experimental Surgery"
	description = "When evolution isn't fast enough."
	prereq_ids = list(TECHWEB_NODE_SURGERY_ADV)
	design_ids = list(
		"surgery_cortex_folding",
		"surgery_cortex_imprint",
		"surgery_heal_combo_upgrade",
		"surgery_ligament_hook",
		"surgery_ligament_reinforcement",
		"surgery_muscled_veins",
		"surgery_nerve_ground",
		"surgery_nerve_splice",
		"surgery_pacify",
		"surgery_vein_thread",
		"surgery_viral_bond",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	discount_experiments = list(/datum/experiment/autopsy/nonhuman = TECHWEB_TIER_3_POINTS)

/datum/techweb_node/surgery_tools
	id = TECHWEB_NODE_SURGERY_TOOLS
	display_name = "Advanced Surgery Tools"
	description = "Surgical instruments of dual purpose for quick operations."
	prereq_ids = list(TECHWEB_NODE_SURGERY_EXP)
	design_ids = list(
		"laserscalpel",
		"searingtool",
		"mechanicalpinches",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	discount_experiments = list(/datum/experiment/autopsy/xenomorph = TECHWEB_TIER_4_POINTS)

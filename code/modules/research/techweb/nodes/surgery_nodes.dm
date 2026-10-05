/datum/techweb_node/oldstation_surgery
	display_name = "Experimental Dissection"
	description = "Grants access to experimental dissections, which allows generation of research points."
	prerequisite_nodes = list(/datum/techweb_node/medbay_equip)
	unlocked_designs = list(
		/datum/design/surgery/experimental_dissection,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	node_flags = TECHWEB_NODE_HIDDEN

/datum/techweb_node/surgery
	display_name = "Improved Wound-Tending"
	description = "Who would have known being more gentle with a hemostat decreases patient pain?"
	prerequisite_nodes = list(/datum/techweb_node/medbay_equip)
	unlocked_designs = list(
		/datum/design/surgery/tend_wounds_upgrade,
		/datum/design/medibot_upgrade,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/surgery_adv
	display_name = "Advanced Surgery"
	description = "When simple medicine doesn't cut it."
	prerequisite_nodes = list(/datum/techweb_node/surgery)
	unlocked_designs = list(
		/datum/design/board/harvester,
		/datum/design/medibot_upgrade/tier_two,
		/datum/design/surgery/tend_wounds_combo,
		/datum/design/surgery/tend_wounds_upgrade/femto,
		/datum/design/surgery/lobotomy,
		/datum/design/surgery/lobotomy/mechanic,
		/datum/design/surgery/wing_reconstruction,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	discount_experiments = list(/datum/experiment/autopsy/human = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/surgery_exp
	display_name = "Experimental Surgery"
	description = "When evolution isn't fast enough."
	prerequisite_nodes = list(/datum/techweb_node/surgery_adv)
	unlocked_designs = list(
		/datum/design/medibot_upgrade/tier_three,
		/datum/design/surgery/cortex_folding,
		/datum/design/surgery/cortex_folding/mechanic,
		/datum/design/surgery/cortex_imprint,
		/datum/design/surgery/cortex_imprint/mechanic,
		/datum/design/surgery/tend_wounds_combo/upgrade,
		/datum/design/surgery/ligament_hook,
		/datum/design/surgery/ligament_hook/mechanic,
		/datum/design/surgery/ligament_reinforcement,
		/datum/design/surgery/ligament_reinforcement/mechanic,
		/datum/design/surgery/muscled_veins,
		/datum/design/surgery/muscled_veins/mechanic,
		/datum/design/surgery/nerve_grounding,
		/datum/design/surgery/nerve_grounding/mechanic,
		/datum/design/surgery/nerve_splicing,
		/datum/design/surgery/nerve_splicing/mechanic,
		/datum/design/surgery/pacify,
		/datum/design/surgery/pacify/mechanic,
		/datum/design/surgery/vein_threading,
		/datum/design/surgery/vein_threading/mechanic,
		/datum/design/surgery/viral_bonding,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	discount_experiments = list(/datum/experiment/autopsy/nonhuman = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/surgery_tools
	display_name = "Advanced Surgery Tools"
	description = "Surgical instruments of dual purpose for quick operations."
	prerequisite_nodes = list(/datum/techweb_node/surgery_exp)
	unlocked_designs = list(
		/datum/design/laserscalpel,
		/datum/design/searingtool,
		/datum/design/mechanicalpinches,
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	discount_experiments = list(/datum/experiment/autopsy/xenomorph = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)

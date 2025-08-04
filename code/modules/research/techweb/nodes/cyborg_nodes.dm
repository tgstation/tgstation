/datum/techweb_node/augmentation
	id = TECHWEB_NODE_AUGMENTATION
	starting_node = TRUE
	display_name = "Augmentation"
	description = "For those who prefer shiny metal over squishy flesh."
	prereq_ids = list(TECHWEB_NODE_ROBOTICS)
	design_ids = list(
		"borg_chest",
		"borg_head",
		"borg_l_arm",
		"borg_l_leg",
		"borg_r_arm",
		"borg_r_leg",
		"borg_suit",
		"cybernetic_eyes",
		"cybernetic_eyes_moth",
		"cybernetic_ears",
		"cybernetic_lungs",
		"cybernetic_stomach",
		"cybernetic_liver",
		"cybernetic_heart",
	)
	experiments_to_unlock = list(
		/datum/experiment/scanning/people/android,
	)

/datum/techweb_node/cybernetics
	id = TECHWEB_NODE_CYBERNETICS
	display_name = "Cybernetics"
	description = "Sapient robots with preloaded tool modules and programmable laws."
	prereq_ids = list(TECHWEB_NODE_AUGMENTATION)
	design_ids = list(
		"robocontrol",
		"borgupload",
		"cyborgrecharger",
		"mmi_posi",
		"mmi",
		"mmi_m",
		"advanced_l_arm",
		"advanced_r_arm",
		"advanced_l_leg",
		"advanced_r_leg",
		"borg_upgrade_rename",
		"borg_upgrade_restart",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/borg_service
	id = TECHWEB_NODE_BORG_SERVICES
	display_name = "Service Cyborg Upgrades"
	description = "Let them do the cookin' by the book."
	prereq_ids = list(TECHWEB_NODE_CYBERNETICS)
	design_ids = list(
		"borg_upgrade_rolling_table",
		"borg_upgrade_condiment_synthesizer",
		"borg_upgrade_silicon_knife",
		"borg_upgrade_service_apparatus",
		"borg_upgrade_drink_apparatus",
		"borg_upgrade_service_cookbook",
		"borg_upgrade_botany",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/borg_mining
	id = TECHWEB_NODE_BORG_MINING
	display_name = "Mining Cyborg Upgrades"
	description = "To mine places too dangerous for humans."
	prereq_ids = list(TECHWEB_NODE_CYBERNETICS)
	design_ids = list(
		"borg_upgrade_lavaproof",
		"borg_upgrade_holding",
		"borg_upgrade_diamonddrill",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/borg_medical
	id = TECHWEB_NODE_BORG_MEDICAL
	display_name = "Medical Cyborg Upgrades"
	description = "Let them follow Asimov's First Law."
	prereq_ids = list(TECHWEB_NODE_BORG_SERVICES, TECHWEB_NODE_SURGERY_ADV)
	design_ids = list(
		"borg_upgrade_pinpointer",
		"borg_upgrade_beakerapp",
		"borg_upgrade_defibrillator",
		"borg_upgrade_expandedsynthesiser",
		"borg_upgrade_piercinghypospray",
		"borg_upgrade_surgicalprocessor",
		"borg_upgrade_surgicalomnitool",
		"borg_upgrade_syringe",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/borg_utility
	id = TECHWEB_NODE_BORG_UTILITY
	display_name = "Utility Cyborg Upgrades"
	description = "Let them wipe our floors for us."
	prereq_ids = list(TECHWEB_NODE_BORG_SERVICES, TECHWEB_NODE_SANITATION)
	design_ids = list(
		"borg_upgrade_advancedmop",
		"borg_upgrade_broomer",
		"borg_upgrade_expand",
		"borg_upgrade_prt",
		"borg_upgrade_plunger",
		"borg_upgrade_high_capacity_replacer",
		"borg_upgrade_selfrepair",
		"borg_upgrade_thrusters",
		"borg_upgrade_trashofholding",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

/datum/techweb_node/borg_utility/New()
	. = ..()
	if(!CONFIG_GET(flag/disable_secborg))
		design_ids += "borg_upgrade_disablercooler"

/datum/techweb_node/borg_engi
	id = TECHWEB_NODE_BORG_ENGI
	display_name = "Engineering Cyborg Upgrades"
	description = "To slack even more."
	prereq_ids = list(TECHWEB_NODE_BORG_MINING, TECHWEB_NODE_PARTS_UPG)
	design_ids = list(
		"borg_upgrade_rped",
		"borg_upgrade_engineeringomnitool",
		"borg_upgrade_engineeringapp",
		"borg_upgrade_inducer",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE)

// Implants root node
/datum/techweb_node/passive_implants
	id = TECHWEB_NODE_PASSIVE_IMPLANTS
	display_name = "Passive Implants"
	description = "Implants designed to operate seamlessly without active user input, enhancing various physiological functions or providing continuous benefits."
	prereq_ids = list(TECHWEB_NODE_AUGMENTATION)
	design_ids = list(
		"skill_station",
		"implant_trombone",
		"implant_chem",
		"implant_tracking",
		"implant_exile",
		"implant_beacon",
		"implant_bluespace",
		"implantcase",
		"implanter",
		"locator",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_SECURITY, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/cyber/cyber_implants
	id = TECHWEB_NODE_CYBER_IMPLANTS
	display_name = "Cybernetic Implants"
	description = "Advanced technological enhancements integrated into the body, offering improved physical capabilities."
	prereq_ids = list(TECHWEB_NODE_PASSIVE_IMPLANTS, TECHWEB_NODE_CYBERNETICS)
	design_ids = list(
		"ci-breather",
		"ci-nutriment",
		"ci-thrusters",
		"ci-herculean",
		"ci-connector",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/cyber/New()
	..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CYBERNETIC_REVOLUTION))
		research_costs[TECHWEB_POINT_TYPE_GENERIC] /= 2

/datum/techweb_node/cyber/combat_implants
	id = TECHWEB_NODE_COMBAT_IMPLANTS
	display_name = "Combat Implants"
	description = "To make sure that you can wake the f*** up, samurai."
	prereq_ids = list(TECHWEB_NODE_CYBER_IMPLANTS)
	design_ids = list(
		"ci-reviver",
		"ci-antidrop",
		"ci-antistun",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/cyber/integrated_toolsets
	id = TECHWEB_NODE_INTERGRATED_TOOLSETS
	display_name = "Integrated Toolsets"
	description = "Decades of contraband smuggling by assistants have led to the development of a full toolbox that fits seamlessly into your arm."
	prereq_ids = list(TECHWEB_NODE_COMBAT_IMPLANTS, TECHWEB_NODE_EXP_TOOLS)
	design_ids = list(
		"ci-nutrimentplus",
		"ci-toolset",
		"ci-surgery",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/cyber/cyber_organs
	id = TECHWEB_NODE_CYBER_ORGANS
	display_name = "Cybernetic Organs"
	description = "We have the technology to rebuild him."
	prereq_ids = list(TECHWEB_NODE_CYBERNETICS)
	design_ids = list(
		"cybernetic_eyes_improved",
		"cybernetic_eyes_improved_moth",
		"cybernetic_ears_u",
		"cybernetic_lungs_tier2",
		"cybernetic_stomach_tier2",
		"cybernetic_liver_tier2",
		"cybernetic_heart_tier2",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/cyber/cyber_organs_upgraded
	id = TECHWEB_NODE_CYBER_ORGANS_UPGRADED
	display_name = "Upgraded Cybernetic Organs"
	description = "We have the technology to upgrade him."
	prereq_ids = list(TECHWEB_NODE_CYBER_ORGANS)
	design_ids = list(
		"ci-gloweyes",
		"ci-welding",
		"ci-gloweyes-moth",
		"ci-welding-moth",
		"cybernetic_ears_whisper",
		"cybernetic_lungs_tier3",
		"cybernetic_stomach_tier3",
		"cybernetic_liver_tier3",
		"cybernetic_heart_tier3",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	required_experiments = list(/datum/experiment/scanning/people/augmented_organs)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/cyber/cyber_organs_adv
	id = TECHWEB_NODE_CYBER_ORGANS_ADV
	display_name = "Advanced Cybernetic Organs"
	description = "Cutting-edge cybernetic organs offering enhanced sensory capabilities, making it easier than ever to detect ERP."
	prereq_ids = list(TECHWEB_NODE_CYBER_ORGANS_UPGRADED, TECHWEB_NODE_NIGHT_VISION)
	design_ids = list(
		"cybernetic_ears_xray",
		"ci-thermals",
		"ci-xray",
		"ci-thermals-moth",
		"ci-xray-moth",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_5_POINTS)
	discount_experiments = list(/datum/experiment/scanning/people/android = TECHWEB_TIER_5_POINTS)
	announce_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_MEDICAL)

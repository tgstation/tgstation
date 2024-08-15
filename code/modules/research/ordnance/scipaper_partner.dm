/datum/scientific_partner/mining
	name = "Mining Corps"
	flufftext = "A local group of miners are looking for ways to improve their mining output. They are interested in smaller scale explosives and plasma research."
	accepted_experiments = list(
		/datum/experiment/ordnance/gaseous/plasma,
		/datum/experiment/ordnance/explosive/lowyieldbomb,
		/datum/experiment/ordnance/explosive/highyieldbomb,
	)
	multipliers = list(SCIPAPER_COOPERATION_INDEX = 0.75, SCIPAPER_FUNDING_INDEX = 0.75)
	boostable_nodes = list(
		TECHWEB_NODE_LOW_PRESSURE_EXCAVATION = TECHWEB_TIER_2_POINTS,
		TECHWEB_NODE_PLASMA_MINING = TECHWEB_TIER_3_POINTS,
		TECHWEB_NODE_MINING_ADV = TECHWEB_TIER_4_POINTS,
		TECHWEB_NODE_NIGHT_VISION = TECHWEB_TIER_4_POINTS,
		TECHWEB_NODE_BORG_ENGI = TECHWEB_TIER_3_POINTS,
	)

/datum/scientific_partner/baron
	name = "Ghost Writing"
	flufftext = "A nearby research station ran by a very wealthy captain seems to be struggling with their scientific output. They might reward us handsomely if we ghostwrite for them."
	multipliers = list(SCIPAPER_COOPERATION_INDEX = 0.25, SCIPAPER_FUNDING_INDEX = 2)
	boostable_nodes = list(
		TECHWEB_NODE_CONSOLES = TECHWEB_TIER_1_POINTS,
		TECHWEB_NODE_GAMING = TECHWEB_TIER_2_POINTS,
		TECHWEB_NODE_BITRUNNING = TECHWEB_TIER_3_POINTS,
		TECHWEB_NODE_PROGRAMMED_SERVER = TECHWEB_TIER_3_POINTS,
	)

/datum/scientific_partner/defense
	name = "Defense Partnership"
	flufftext = "We can work directly for Nanotrasen's \[REDACTED\] division, potentially providing us access with advanced offensive and defensive gadgets."
	accepted_experiments = list(
		/datum/experiment/ordnance/explosive/lowyieldbomb,
		/datum/experiment/ordnance/explosive/highyieldbomb,
		/datum/experiment/ordnance/explosive/pressurebomb,
		/datum/experiment/ordnance/explosive/hydrogenbomb,
	)
	boostable_nodes = list(
		TECHWEB_NODE_RIOT_SUPRESSION = TECHWEB_TIER_2_POINTS,
		TECHWEB_NODE_EXPLOSIVES = TECHWEB_TIER_3_POINTS,
		TECHWEB_NODE_MECH_ENERGY_GUNS = TECHWEB_TIER_4_POINTS,
		TECHWEB_NODE_MECH_FIREARMS = TECHWEB_TIER_5_POINTS,
		TECHWEB_NODE_MECH_HEAVY_ARMS = TECHWEB_TIER_5_POINTS,
	)

/datum/scientific_partner/medical
	name = "Biological Research Division"
	flufftext = "A collegiate of the best medical researchers Nanotrasen employs. They seem to be interested in the biological effects of some more exotic gases. Especially stimulants and neurosupressants."
	accepted_experiments = list(
		/datum/experiment/ordnance/gaseous/nitrous_oxide,
		/datum/experiment/ordnance/gaseous/bz,
	)
	boostable_nodes = list(
		TECHWEB_NODE_CYBER_ORGANS = TECHWEB_TIER_2_POINTS,
		TECHWEB_NODE_CYBER_ORGANS_UPGRADED = TECHWEB_TIER_3_POINTS,
		TECHWEB_NODE_MEDBAY_EQUIP_ADV = TECHWEB_TIER_3_POINTS,
		TECHWEB_NODE_CYTOLOGY = TECHWEB_TIER_3_POINTS,
		TECHWEB_NODE_BORG_MEDICAL = TECHWEB_TIER_3_POINTS,
		TECHWEB_NODE_COMBAT_IMPLANTS = TECHWEB_TIER_4_POINTS,
	)

/datum/scientific_partner/physics
	name = "NT Physics Quarterly"
	flufftext = "A prestigious physics journal managed by Nanotrasen. The main journal for publishing cutting-edge physics research conducted by Nanotrasen, given that they aren't classified."
	accepted_experiments = list(
		/datum/experiment/ordnance/gaseous/bz,
		/datum/experiment/ordnance/explosive/hydrogenbomb,
		/datum/experiment/ordnance/gaseous/noblium,
		/datum/experiment/ordnance/explosive/nobliumbomb,
	)
	boostable_nodes = list(
		TECHWEB_NODE_PARTS_ADV = TECHWEB_TIER_3_POINTS,
		TECHWEB_NODE_BLUESPACE_TRAVEL = TECHWEB_TIER_3_POINTS,
		TECHWEB_NODE_ANOMALY_RESEARCH = TECHWEB_TIER_3_POINTS,
		TECHWEB_NODE_TELECOMS =  TECHWEB_TIER_5_POINTS,
		TECHWEB_NODE_MECH_EQUIP_BLUESPACE = TECHWEB_TIER_5_POINTS,
	)

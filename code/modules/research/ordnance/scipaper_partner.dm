/datum/scientific_partner/mining
	name = "Mining Corps"
	flufftext = "A local group of miners are looking for ways to improve their mining output. They are interested in smaller scale explosives."
	accepted_experiments = list(/datum/experiment/ordnance/explosive/lowyieldbomb)
	multipliers = list(SCIPAPER_COOPERATION_INDEX = 0.75, SCIPAPER_FUNDING_INDEX = 0.75)
	boostable_nodes = list(
		TECHWEB_NODE_BLUESPACE_THEORY = TECHWEB_TIER_3_POINTS,
		TECHWEB_NODE_NIGHT_VISION = TECHWEB_TIER_2_POINTS,
		TECHWEB_NODE_ANOMALY_RESEARCH = TECHWEB_TIER_2_POINTS,
		TECHWEB_NODE_MINING = TECHWEB_TIER_1_POINTS,
		TECHWEB_NODE_MINING_ADV = TECHWEB_TIER_2_POINTS,
	)

/datum/scientific_partner/baron
	name = "Ghost Writing"
	flufftext = "A nearby research station ran by a very wealthy captain seems to be struggling with their scientific output. They might reward us handsomely if we ghostwrite for them."
	multipliers = list(SCIPAPER_COOPERATION_INDEX = 0.25, SCIPAPER_FUNDING_INDEX = 2)
	boostable_nodes = list(
		TECHWEB_NODE_CONSOLES = TECHWEB_TIER_1_POINTS,
		TECHWEB_NODE_FUNDIMENTAL_SCI = TECHWEB_TIER_1_POINTS,
	)

/datum/scientific_partner/defense
	name = "Defense Partnership"
	flufftext = "We can work directly for Nanotrasen's \[REDACTED\] division, potentially providing us access with advanced defensive gadgets."
	accepted_experiments = list(
		/datum/experiment/ordnance/explosive/highyieldbomb,
		/datum/experiment/ordnance/explosive/pressurebomb,
		/datum/experiment/ordnance/explosive/hydrogenbomb,
	)
	boostable_nodes = list(
		TECHWEB_NODE_RIOT_SUPRESSION = TECHWEB_TIER_3_POINTS,
		TECHWEB_NODE_SEC_EQUIP = TECHWEB_TIER_1_POINTS,
		TECHWEB_NODE_EXPLOSIVES = TECHWEB_TIER_2_POINTS,
		TECHWEB_NODE_ELECTRIC_WEAPONS = TECHWEB_TIER_2_POINTS,
		TECHWEB_NODE_BEAM_WEAPONS = TECHWEB_TIER_3_POINTS,
	)

/datum/scientific_partner/medical
	name = "Biological Research Division"
	flufftext = "A collegiate of the best medical researchers Nanotrasen employs. They seem to be interested in the biological effects of some more exotic gases. Especially stimulants and neurosupressants."
	accepted_experiments = list(
		/datum/experiment/ordnance/gaseous/nitrous_oxide,
		/datum/experiment/ordnance/gaseous/bz,
	)
	boostable_nodes = list(
		TECHWEB_NODE_CYBER_ORGANS = TECHWEB_TIER_1_POINTS,
		TECHWEB_NODE_CYBER_ORGANS_UPGRADED = TECHWEB_TIER_2_POINTS,
		TECHWEB_NODE_GENE_ENGINEERING = TECHWEB_TIER_1_POINTS,
		TECHWEB_NODE_PASSIVE_IMPLANTS = TECHWEB_TIER_1_POINTS,
		TECHWEB_NODE_BIO_SCAN = TECHWEB_TIER_1_POINTS,
		TECHWEB_NODE_CHEM_SYNTHESIS = TECHWEB_TIER_2_POINTS,
	)

/datum/scientific_partner/physics
	name = "NT Physics Quarterly"
	flufftext = "A prestigious physics journal managed by Nanotrasen. The main journal for publishing cutting-edge physics research conducted by Nanotrasen, given that they aren't classified."
	accepted_experiments = list(
		/datum/experiment/ordnance/gaseous/noblium,
		/datum/experiment/ordnance/explosive/nobliumbomb,
	)
	boostable_nodes = list(
		TECHWEB_NODE_PARTS_UPG = TECHWEB_TIER_2_POINTS,
		TECHWEB_NODE_EXP_TOOLS = TECHWEB_TIER_4_POINTS,
		TECHWEB_NODE_PARTS_BLUESPACE = TECHWEB_TIER_3_POINTS,
		TECHWEB_NODE_PARTS_ADV = TECHWEB_TIER_1_POINTS,
	)

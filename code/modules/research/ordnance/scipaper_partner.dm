/datum/scientific_partner/mining
	name = "Mining Corps"
	flufftext = "A local group of miners are looking for ways to improve their mining output. They are interested in smaller scale explosives."
	accepted_experiments = list(/datum/experiment/ordnance/explosive/lowyieldbomb)
	multipliers = list(SCIPAPER_COOPERATION_INDEX = 0.75, SCIPAPER_FUNDING_INDEX = 0.75)
	boostable_nodes = list(
		TECHWEB_NODE_BLUESPACE_THEORY = 2000,
		TECHWEB_NODE_NIGHT_VISION = 1500,
		TECHWEB_NODE_ANOMALY_RESEARCH = 2500,
		TECHWEB_NODE_MINING = 2000,
		TECHWEB_NODE_MINING_ADV = 2000,
	)

/datum/scientific_partner/baron
	name = "Ghost Writing"
	flufftext = "A nearby research station ran by a very wealthy captain seems to be struggling with their scientific output. They might reward us handsomely if we ghostwrite for them."
	multipliers = list(SCIPAPER_COOPERATION_INDEX = 0.25, SCIPAPER_FUNDING_INDEX = 2)
	boostable_nodes = list(
		TECHWEB_NODE_CONSOLES = 500,
		TECHWEB_NODE_FUNDIMENTAL_SCI = 500,
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
		TECHWEB_NODE_RIOT_SUPRESSION = 5000,
		TECHWEB_NODE_SEC_EQUIP = 1250,
		TECHWEB_NODE_EXPLOSIVES = 1250,
		TECHWEB_NODE_ELECTRIC_WEAPONS = 1250,
		TECHWEB_NODE_BEAM_WEAPONS = 1250,
	)

/datum/scientific_partner/medical
	name = "Biological Research Division"
	flufftext = "A collegiate of the best medical researchers Nanotrasen employs. They seem to be interested in the biological effects of some more exotic gases. Especially stimulants and neurosupressants."
	accepted_experiments = list(
		/datum/experiment/ordnance/gaseous/nitrous_oxide,
		/datum/experiment/ordnance/gaseous/bz,
	)
	boostable_nodes = list(
		TECHWEB_NODE_CYBER_ORGANS = 750,
		TECHWEB_NODE_CYBER_ORGANS_UPGRADED = 1000,
		TECHWEB_NODE_GENE_ENGINEERING = 500,
		TECHWEB_NODE_PASSIVE_IMPLANTS = 1250,
		TECHWEB_NODE_BIO_SCAN = 1000,
		TECHWEB_NODE_CHEM_SYNTHESIS = 1000,
	)

/datum/scientific_partner/physics
	name = "NT Physics Quarterly"
	flufftext = "A prestigious physics journal managed by Nanotrasen. The main journal for publishing cutting-edge physics research conducted by Nanotrasen, given that they aren't classified."
	accepted_experiments = list(
		/datum/experiment/ordnance/gaseous/noblium,
		/datum/experiment/ordnance/explosive/nobliumbomb,
	)
	boostable_nodes = list(
		TECHWEB_NODE_PARTS_UPG = 5000,
		TECHWEB_NODE_EXP_TOOLS = 5000,
		TECHWEB_NODE_PARTS_BLUESPACE = 3000,
		TECHWEB_NODE_PARTS_ADV = 1250,
	)

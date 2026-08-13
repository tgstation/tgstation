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
		/datum/techweb_node/low_pressure_excavation = TECHWEB_TIER_2_POINTS,
		/datum/techweb_node/plasma_mining = TECHWEB_TIER_3_POINTS,
		/datum/techweb_node/mining_adv = TECHWEB_TIER_4_POINTS,
		/datum/techweb_node/night_vision = TECHWEB_TIER_4_POINTS,
		/datum/techweb_node/borg_engi = TECHWEB_TIER_3_POINTS,
	)

/datum/scientific_partner/baron
	name = "Ghost Writing"
	flufftext = "A nearby research station ran by a very wealthy captain seems to be struggling with their scientific output. They might reward us handsomely if we ghostwrite for them."
	multipliers = list(SCIPAPER_COOPERATION_INDEX = 0.25, SCIPAPER_FUNDING_INDEX = 2)
	boostable_nodes = list(
		/datum/techweb_node/consoles = TECHWEB_TIER_1_POINTS,
		/datum/techweb_node/gaming = TECHWEB_TIER_2_POINTS,
		/datum/techweb_node/bitrunning = TECHWEB_TIER_3_POINTS,
		/datum/techweb_node/programmed_server = TECHWEB_TIER_3_POINTS,
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
		/datum/techweb_node/riot_supression = TECHWEB_TIER_2_POINTS,
		/datum/techweb_node/explosives = TECHWEB_TIER_3_POINTS,
		/datum/techweb_node/mech_energy_guns = TECHWEB_TIER_4_POINTS,
		/datum/techweb_node/mech_firearms = TECHWEB_TIER_5_POINTS,
		/datum/techweb_node/mech_heavy_arms = TECHWEB_TIER_5_POINTS,
	)

/datum/scientific_partner/medical
	name = "Biological Research Division"
	flufftext = "A collegiate of the best medical researchers Nanotrasen employs. They seem to be interested in the biological effects of some more exotic gases. Especially stimulants and neurosupressants."
	accepted_experiments = list(
		/datum/experiment/ordnance/gaseous/nitrous_oxide,
		/datum/experiment/ordnance/gaseous/bz,
	)
	boostable_nodes = list(
		/datum/techweb_node/cyber/cyber_organs = TECHWEB_TIER_2_POINTS,
		/datum/techweb_node/cyber/cyber_organs_upgraded = TECHWEB_TIER_3_POINTS,
		/datum/techweb_node/medbay_equip_adv = TECHWEB_TIER_3_POINTS,
		/datum/techweb_node/cytology = TECHWEB_TIER_2_POINTS,
		/datum/techweb_node/borg_medical = TECHWEB_TIER_3_POINTS,
		/datum/techweb_node/cyber/combat_implants = TECHWEB_TIER_4_POINTS,
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
		/datum/techweb_node/parts_adv = TECHWEB_TIER_3_POINTS,
		/datum/techweb_node/bluespace_travel = TECHWEB_TIER_3_POINTS,
		/datum/techweb_node/anomaly_research = TECHWEB_TIER_3_POINTS,
		/datum/techweb_node/telecomms =  TECHWEB_TIER_5_POINTS,
		/datum/techweb_node/mech_equip_bluespace = TECHWEB_TIER_5_POINTS,
	)

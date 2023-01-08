/datum/scientific_partner/mining
	name = "Mining Corps"
	flufftext = "A local group of miners are looking for ways to improve their mining output. They are interested in smaller scale explosives."
	accepted_experiments = list(/datum/experiment/ordnance/explosive/lowyieldbomb)
	multipliers = list(SCIPAPER_COOPERATION_INDEX = 0.75, SCIPAPER_FUNDING_INDEX = 0.75)
	boosted_nodes = list(
		"bluespace_basic" = 2000,
		"NVGtech" = 1500,
		"practical_bluespace" = 2500,
		"basic_plasma" = 2000,
		"basic_mining" = 2000,
		"adv_mining" = 2000,
	)

/datum/scientific_partner/baron
	name = "Ghost Writing"
	flufftext = "A nearby research station ran by a very wealthy captain seems to be struggling with their scientific output. They might reward us handsomely if we ghostwrite for them."
	multipliers = list(SCIPAPER_COOPERATION_INDEX = 0.25, SCIPAPER_FUNDING_INDEX = 2)
	boosted_nodes = list(
		"comp_recordkeeping" = 500,
		"computer_data_disks" = 500,
	)

/datum/scientific_partner/defense
	name = "Defense Partnership"
	flufftext = "We can work directly for Nanotrasen's \[REDACTED\] division, potentially providing us access with advanced defensive gadgets."
	accepted_experiments = list(
		/datum/experiment/ordnance/explosive/highyieldbomb,
		/datum/experiment/ordnance/explosive/pressurebomb,
		/datum/experiment/ordnance/explosive/hydrogenbomb,
	)
	boosted_nodes = list(
		"adv_weaponry" = 5000,
		"weaponry" = 2500,
		"sec_basic" = 1250,
		"explosive_weapons" = 1250,
		"electronic_weapons" = 1250,
		"radioactive_weapons" = 1250,
		"beam_weapons" = 1250,
		"explosive_weapons" = 1250,
	)

/datum/scientific_partner/medical
	name = "Biological Research Division"
	flufftext = "A collegiate of the best medical researchers Nanotrasen employs. They seem to be interested in the biological effects of some more exotic gases. Especially stimulants and neurosupressants."
	accepted_experiments = list(
		/datum/experiment/ordnance/gaseous/nitrous_oxide,
		/datum/experiment/ordnance/gaseous/bz,
	)
	boosted_nodes = list(
		"cyber_organs" = 750,
		"cyber_organs_upgraded" = 1000,
		"genetics" = 500,
		"subdermal_implants" = 1250,
		"adv_biotech" = 1000,
		"biotech" = 1000,
	)

/datum/scientific_partner/physics
	name = "NT Physics Quarterly"
	flufftext = "A prestigious physics journal managed by Nanotrasen. The main journal for publishing cutting-edge physics research conducted by Nanotrasen, given that they aren't classified."
	accepted_experiments = list(
		/datum/experiment/ordnance/gaseous/noblium,
		/datum/experiment/ordnance/explosive/nobliumbomb,
	)
	boosted_nodes = list(
		"engineering" = 5000,
		"adv_engi" = 5000,
		"emp_super" = 3000,
		"emp_adv" = 1250,
		"high_efficiency" = 5000,
		"micro_bluespace" = 5000,
		"adv_power" = 1500,
	)

/datum/scientific_partner/mining
	name = "Mining Corps"
	flufftext = "A local group of miners are looking for ways to improve their mining output. They are interested in smaller scale explosives and plasma research."
	accepted_experiments = list(
		/datum/experiment/ordnance/explosive/lowyieldbomb,
		/datum/experiment/ordnance/gaseous/plasma,
	)
	multipliers = list(SCIPAPER_COOPERATION_INDEX = 0.75, SCIPAPER_FUNDING_INDEX = 0.75)
	boostable_nodes = list(
		"low_pressure_excavation" = TECHWEB_TIER_2_POINTS,
		"plasma_mining" = TECHWEB_TIER_3_POINTS,
		"bitrunning" = TECHWEB_TIER_3_POINTS,
		"mining_adv" = TECHWEB_TIER_4_POINTS,
	)

/datum/scientific_partner/baron
	name = "Ghost Writing"
	flufftext = "A nearby research station ran by a very wealthy captain seems to be struggling with their scientific output. They might reward us handsomely if we ghostwrite for them."
	multipliers = list(SCIPAPER_COOPERATION_INDEX = 0.25, SCIPAPER_FUNDING_INDEX = 2)
	boostable_nodes = list(
		"food_proc" = TECHWEB_TIER_2_POINTS,
		"hydroponics" = TECHWEB_TIER_2_POINTS,
		"programmed_server" = TECHWEB_TIER_3_POINTS,
		"cyber_organs_adv" = TECHWEB_TIER_5_POINTS,
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
		"electric_weapons" = TECHWEB_TIER_3_POINTS,
		"beam_weapons" = TECHWEB_TIER_4_POINTS,
		"exotic_ammo" = TECHWEB_TIER_4_POINTS,
		"combat_implants" = TECHWEB_TIER_4_POINTS,
		"mech_firearms" = TECHWEB_TIER_5_POINTS,
		"beam_wemech_heavy_armsapons" = TECHWEB_TIER_5_POINTS,
	)

/datum/scientific_partner/medical
	name = "Biological Research Division"
	flufftext = "A collegiate of the best medical researchers Nanotrasen employs. They seem to be interested in the biological effects of some more exotic gases. Especially stimulants and neurosupressants."
	accepted_experiments = list(
		/datum/experiment/ordnance/gaseous/nitrous_oxide,
		/datum/experiment/ordnance/gaseous/bz,
	)
	boostable_nodes = list(
		"xenobiology" = TECHWEB_TIER_3_POINTS,
		"surgery_exp" = TECHWEB_TIER_3_POINTS,
		"mod_medical_adv" = TECHWEB_TIER_3_POINTS,
		"cyber_organs_upgraded" = TECHWEB_TIER_4_POINTS,
		"medbay_equip_adv" = TECHWEB_TIER_4_POINTS,
	)

/datum/scientific_partner/physics
	name = "NT Physics Quarterly"
	flufftext = "A prestigious physics journal managed by Nanotrasen. The main journal for publishing cutting-edge physics research conducted by Nanotrasen, given that they aren't classified."
	accepted_experiments = list(
		/datum/experiment/ordnance/gaseous/noblium,
		/datum/experiment/ordnance/explosive/nobliumbomb,
	)
	boostable_nodes = list(
		"bluespace_travel" = TECHWEB_TIER_3_POINTS,
		"anomaly_research" = TECHWEB_TIER_3_POINTS,
		"anomaly_shells" = TECHWEB_TIER_4_POINTS,
		"night_vision" = TECHWEB_TIER_4_POINTS,
		"rcd_upgrade" = TECHWEB_TIER_5_POINTS,
		"mech_equip_bluespace" = TECHWEB_TIER_5_POINTS,
		"telecomms" = TECHWEB_TIER_5_POINTS,
	)

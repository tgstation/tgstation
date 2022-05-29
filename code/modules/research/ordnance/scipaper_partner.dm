/datum/scientific_partner/spinward_science
	name="Spinward Science"
	flufftext="A local scientific community started by the diverse inhabitants of the Spinward Sector. Not generally advanced, but they will gladly work with us."
	multipliers=list(SCIPAPER_COOPERATION_INDEX = 1, SCIPAPER_FUNDING_INDEX=0.75)
	boosted_nodes=list("emp_basic" = 500, "NVGtech" = 1500, "integrated_HUDs" = 500)

/datum/scientific_partner/baron
	name = "Ghost Writing"
	flufftext="A nearby research station ran by a very wealthy captain seems to be struggling with their scientific output. They might reward us handsomely if we ghostwrite for them."
	multipliers = list(SCIPAPER_COOPERATION_INDEX = 0.25, SCIPAPER_FUNDING_INDEX=5)
	boosted_nodes = list("comp_recordkeeping" = 500, "computer_hardware_basic"=500)

/datum/scientific_partner/defense
	name="Defense Partnership"
	flufftext="We can work directly for Nanotrasen's \[REDACTED\] division, potentially providing us access with advanced defensive gadgets."
	accepted_experiments=list(/datum/experiment/ordnance/explosive/lowyieldbomb, /datum/experiment/ordnance/explosive/highyieldbomb, /datum/experiment/ordnance/explosive/pressurebomb)
	boosted_nodes = list("adv_weaponry" = 5000, "weaponry" = 2500, "sec_basic" = 1250, "explosive_weapons"=1250)

/datum/scientific_partner/energy
	name="High-Energy Research"
	flufftext="A recently established high-energy research concern started by Nanotrasen. They might be able to assist our energy-based research."
	accepted_experiments=list(/datum/experiment/ordnance/explosive/hydrogenbomb, /datum/experiment/ordnance/explosive/nobliumbomb)
	boosted_nodes = list("adv_beam_weapons" = 1250, "beam_weapons" = 1250, "electronic_weapons"=1250, "mech_laser"=1250, "mech_laser_heavy"=1250)

/datum/scientific_partner/engineering
	name="Corps of Engineers"
	flufftext = "Many engineers are interested in the application of exotic gases in their day-to-day work. They might be able to offer us information on some their gadgets in return."
	accepted_experiments=list(/datum/experiment/ordnance/gaseous/halon, /datum/experiment/ordnance/gaseous/noblium, /datum/experiment/ordnance/explosive/lowyieldbomb)
	boosted_nodes=list(/datum/techweb_node/adv_engi=2500, /datum/techweb_node/adv_power=1500, /datum/techweb_node/bluespace_power=2000, /datum/techweb_node/high_efficiency=2500, /datum/techweb_node/micro_bluespace=2500)

/datum/scientific_partner/medical
	name="Biological Research Division"
	flufftext="A collegiate of the best medical researchers Nanotrason employs. They seem to be interested in the biological effects of some more exotic gases."
	accepted_experiments=list(/datum/experiment/ordnance/gaseous/nitrium, /datum/experiment/ordnance/gaseous/bz)
	boosted_nodes=list("cyber_organs"=750, "cyber_organs_upgraded"=1000, "genetics"=500, "subdermal_implants"=1250, "adv_biotech"=1000)

/datum/scientific_partner/ordnance
	name="Ordnance Partners"
	flufftext="There are other stations tasked with researching the more esoteric reactions. We might be able to exchange some information with them."
	accepted_experiments=list(/datum/experiment/ordnance/explosive/pressurebomb, /datum/experiment/ordnance/explosive/nobliumbomb)
	boosted_nodes=list("gravity_gun"=1250, "mecha_phazon"=1500, "mech_wormhole_gen"=1250, "bluespace_travel"=1000, "micro_bluespace"=3000, "basic_plasma"=1000, "adv_plasma"=1000)

/datum/scientific_partner/cold_physics
	name="Low Temperature Research"
	flufftext="A Nanotrasen division researching matter interactions at very low temperatures. Very interested in our hyper-noblium research."
	accepted_experiments=list(/datum/experiment/ordnance/gaseous/noblium, /datum/experiment/ordnance/explosive/nobliumbomb)
	boosted_nodes=list("emp_super" = 3000, "emp_adv"=1250, "cryotech"=1500)

/datum/design/nanites
	name = "Idle Nanites"
	desc = "An injector containing some idle nanites."
	id = "idle_nanites"
	build_type = NANITE_PRINTER
	materials = list(MAT_GLASS = 150)
	reagents_list = list("idle_nanites" = 2)
	construction_time = 100
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite
	category = list("Utility Nanites")

////////////////////UTILITY NANITES//////////////////////////////////////

/datum/design/nanites/replicating
	name = "Self-Replicating Nanites"
	desc = "Nanites able to replicate autonomously. Does not cause harm to the host."
	id = "replicating_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/replicating
	category = list("Utility Nanites")

/datum/design/nanites/aggressive_replicating
	name = "Aggressive-Replicating Nanites"
	desc = "Nanites able to replicate rapidly by consuming organic matter. Causes internal damage while doing so."
	id = "aggressive_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/aggressive_replicating
	category = list("Utility Nanites")

/datum/design/nanites/infective
	name = "Infective Nanites"
	desc = "Coordinates nanite movement, making nanites able to infect nearby potential hosts."
	id = "infective_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/infective
	category = list("Utility Nanites")

/datum/design/nanites/monitoring
	name = "Monitoring Nanites"
	desc = "Monitors the host's vitals and location, sending them to the suit sensor network."
	id = "monitoring_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/monitoring
	category = list("Utility Nanites")

/datum/design/nanites/relay
	name = "Relay Nanites"
	desc = "Relays remote nanite signals from long distances."
	id = "relay_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/relay
	category = list("Utility Nanites")

/datum/design/nanites/hunter
	name = "Hunter Nanites"
	desc = "Seeks and destroys pattern nanites. Can not be programmed."
	id = "hunter_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/hunter
	category = list("Utility Nanites")

/datum/design/nanites/emp
	name = "EMP Nanites"
	desc = "Causes an EMP around the host when triggered."
	id = "emp_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/emp
	category = list("Utility Nanites")

////////////////////MEDICAL NANITES//////////////////////////////////////
/datum/design/nanites/regenerative
	name = "Regenerative Nanites"
	desc = "Patches up physical damage inside the host."
	id = "regenerative_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/regenerative
	category = list("Medical Nanites")

/datum/design/nanites/temperature
	name = "Temperature-Adjustment Nanites"
	desc = "Balances the host's temperature while active."
	id = "temperature_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/temperature
	category = list("Medical Nanites")

/datum/design/nanites/purging
	name = "Purging Nanites"
	desc = "Purges toxins and chemicals from the host's bloodstream."
	id = "purging_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/purging
	category = list("Medical Nanites")

/datum/design/nanites/brain_heal
	name = "Brain-Restoring Nanites"
	desc = "Fixes neural connections in the host's brain, reversing brain damage and minor traumas."
	id = "brainheal_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/brain_heal
	category = list("Medical Nanites")

/datum/design/nanites/blood_restoring
	name = "Blood-Restoring Nanites"
	desc = "Replaces the host's lost blood."
	id = "bloodheal_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/blood_restoring
	category = list("Medical Nanites")

/datum/design/nanites/repairing
	name = "Repairing Nanites"
	desc = "Patches up mechanical damage inside the host."
	id = "repairing_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/repairing
	category = list("Medical Nanites")


////////////////////AUGMENTATION NANITES//////////////////////////////////////

/datum/design/nanites/nervous
	name = "Nervous Nanites"
	desc = "Acts as a secondary nervous system, reducing the amount of time the host is stunned."
	id = "nervous_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/nervous
	category = list("Augmentation Nanites")

/datum/design/nanites/hardening
	name = "Hardening Nanites"
	desc = "Makes the host harder to damage with bullets and melee attacks."
	id = "hardening_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/hardening
	category = list("Augmentation Nanites")

/datum/design/nanites/coagulating
	name = "Coagulating Nanites"
	desc = "Slows the host's bleeding rate."
	id = "coagulating_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/coagulating
	category = list("Augmentation Nanites")

////////////////////DANGEROUS NANITES//////////////////////////////////////

/datum/design/nanites/necrotic
	name = "Necrotic Nanites"
	desc = "Attacks tissues indiscriminately, causing widespread physical damage."
	id = "necrotic_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/necrotic
	category = list("Dangerous Nanites")

/datum/design/nanites/brain_decay
	name = "Brain-Eating Nanites"
	desc = "Damages brain cells, gradually decreasing the host's cognitive functions."
	id = "braindecay_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/brain_decay
	category = list("Dangerous Nanites")

/datum/design/nanites/pyro
	name = "Pyroclastic Nanites"
	desc = "Ignites the user while active."
	id = "pyro_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/pyro
	category = list("Dangerous Nanites")

/datum/design/nanites/cryo
	name = "Cryogenic Nanites"
	desc = "Cools down and freezes the host."
	id = "cryo_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/cryo
	category = list("Dangerous Nanites")

/datum/design/nanites/toxic
	name = "Toxic Nanites"
	desc = "Causes slow but constant toxin buildup inside the host."
	id = "toxic_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/toxic
	category = list("Dangerous Nanites")

/datum/design/nanites/suffocating
	name = "Suffocating Nanites"
	desc = "Prevents the host from absorbing oxygen from the air, suffocating them."
	id = "suffocating_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/suffocating
	category = list("Dangerous Nanites")

/datum/design/nanites/heart_stop
	name = "Heart-Stopping Nanites"
	desc = "Stops the host's heart when triggered; restarts it if triggered again."
	id = "heartstop_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/heart_stop
	category = list("Dangerous Nanites")

/datum/design/nanites/explosive
	name = "Explosive Nanites"
	desc = "Blows up all the nanites inside the host in a chain reaction when triggered."
	id = "explosive_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/explosive
	category = list("Dangerous Nanites")

////////////////////SUPPRESSING NANITES//////////////////////////////////////

/datum/design/nanites/shock
	name = "Shock Nanites"
	desc = "Shocks the host when triggered."
	id = "shock_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/shock
	category = list("Suppressing Nanites")

/datum/design/nanites/sleepy
	name = "Sleep Nanites"
	desc = "Causes near-instant narcolepsy when triggered."
	id = "sleep_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/sleepy
	category = list("Suppressing Nanites")

/datum/design/nanites/paralyzing
	name = "Paralyzing Nanites"
	desc = "Keeps the host paralyzed, but decays quickly while active."
	id = "paralyzing_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/paralyzing
	category = list("Suppressing Nanites")

/datum/design/nanites/fake_death
	name = "Death Simulation Nanites"
	desc = "Causes the host to fall into a near-death coma."
	id = "fakedeath_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/fake_death
	category = list("Suppressing Nanites")

/datum/design/nanites/pacifying
	name = "Pacifying Nanites"
	desc = "Prevents direct aggression from the host while active."
	id = "pacifying_nanites"
	build_path = /obj/item/reagent_containers/hypospray/medipen/nanite/pacifying
	category = list("Suppressing Nanites")
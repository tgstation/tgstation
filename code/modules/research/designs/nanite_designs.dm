/datum/design/nanites
	name = "Nanite Program Disk \[Nanite Program Disk"
	desc = "An injector containing some idle nanites."
	id = "idle_nanites"
	build_type = NANITE_PRINTER
	materials = list(MAT_METAL = 150)
	construction_time = 50
	build_path = /obj/item/disk/nanite_program
	category = list("Utility Nanites")

////////////////////UTILITY NANITES//////////////////////////////////////

/datum/design/nanites/cloud
	name = "Nanite Program Disk \[Cloud Sync\]"
	desc = "When triggered, syncs nanite programs to a console-controlled cloud copy."
	id = "cloud_nanites"
	build_path = /obj/item/disk/nanite_program/cloud
	category = list("Utility Nanites")

/datum/design/nanites/metabolic_synthesis
	name = "Nanite Program Disk \[Metabolic Synthesis\]"
	desc = "The nanites use the metabolic cycle of the host to speed up their replication rate, using their extra nutrition as fuel."
	id = "metabolic_nanites"
	build_path = /obj/item/disk/nanite_program/metabolic_synthesis
	category = list("Utility Nanites")

/datum/design/nanites/viral
	name = "Nanite Program Disk \[Viral Replica\]"
	desc = "The nanites constantly send encrypted signals attempting to forcefully copy their own programming into other nanite clusters."
	id = "viral_nanites"
	build_path = /obj/item/disk/nanite_program/viral
	category = list("Utility Nanites")

/datum/design/nanites/monitoring
	name = "Nanite Program Disk \[Monitoring\]"
	desc = "The nanites monitor the host's vitals and location, sending them to the suit sensor network."
	id = "monitoring_nanites"
	build_path = /obj/item/disk/nanite_program/monitoring
	category = list("Utility Nanites")

/datum/design/nanites/relay
	name = "Nanite Program Disk \[Relay\]"
	desc = "The nanites receive and relay long-range nanite signals."
	id = "relay_nanites"
	build_path = /obj/item/disk/nanite_program/relay
	category = list("Utility Nanites")

/datum/design/nanites/emp
	name = "Nanite Program Disk \[Electromagnetic Resonance\]"
	desc = "The nanites cause an elctromagnetic pulse around the host when triggered. Will corrupt other nanite programs!"
	id = "emp_nanites"
	build_path = /obj/item/disk/nanite_program/emp
	category = list("Utility Nanites")

////////////////////MEDICAL NANITES//////////////////////////////////////
/datum/design/nanites/regenerative
	name = "Nanite Program Disk \[Accelerated Regeneration\]"
	desc = "The nanites boost the host's natural regeneration, increasing their healing speed."
	id = "regenerative_nanites"
	build_path = /obj/item/disk/nanite_program/regenerative
	category = list("Medical Nanites")

/datum/design/nanites/temperature
	name = "Nanite Program Disk \[Temperature Adjustment\]"
	desc = "The nanites adjust the host's internal temperature to an ideal level."
	id = "temperature_nanites"
	build_path = /obj/item/disk/nanite_program/temperature
	category = list("Medical Nanites")

/datum/design/nanites/purging
	name = "Nanite Program Disk \[Blood Purification\]"
	desc = "The nanites purge toxins and chemicals from the host's bloodstream."
	id = "purging_nanites"
	build_path = /obj/item/disk/nanite_program/purging
	category = list("Medical Nanites")

/datum/design/nanites/brain_heal
	name = "Nanite Program Disk \[Neural Regeneration\]"
	desc = "The nanites fix neural connections in the host's brain, reversing brain damage and minor traumas."
	id = "brainheal_nanites"
	build_path = /obj/item/disk/nanite_program/brain_heal
	category = list("Medical Nanites")

/datum/design/nanites/blood_restoring
	name = "Nanite Program Disk \[Blood Regeneration\]"
	desc = "The nanites stimulate and boost blood cell production in the host."
	id = "bloodheal_nanites"
	build_path = /obj/item/disk/nanite_program/blood_restoring
	category = list("Medical Nanites")

/datum/design/nanites/repairing
	name = "Nanite Program Disk \[Mechanical Repair\]"
	desc = "The nanites fix damage in the host's mechanical limbs."
	id = "repairing_nanites"
	build_path = /obj/item/disk/nanite_program/repairing
	category = list("Medical Nanites")


////////////////////AUGMENTATION NANITES//////////////////////////////////////

/datum/design/nanites/nervous
	name = "Nanite Program Disk \[Nerve Support\]"
	desc = "The nanites act as a secondary nervous system, reducing the amount of time the host is stunned."
	id = "nervous_nanites"
	build_path = /obj/item/disk/nanite_program/nervous
	category = list("Augmentation Nanites")

/datum/design/nanites/hardening
	name = "Nanite Program Disk \[Dermal Hardening\]"
	desc = "The nanites form a mesh under the host's skin, protecting them from melee and bullet impacts."
	id = "hardening_nanites"
	build_path = /obj/item/disk/nanite_program/hardening
	category = list("Augmentation Nanites")

/datum/design/nanites/refractive
	name = "Nanite Program Disk \[Dermal Refractive Surface\]"
	desc = "The nanites form a membrane above the host's skin, reducing the effect of laser and energy impacts."
	id = "refractive_nanites"
	build_path = /obj/item/disk/nanite_program/refractive
	category = list("Augmentation Nanites")

/datum/design/nanites/coagulating
	name = "Nanite Program Disk \[Rapid Coagulation\]"
	desc = "The nanites induce rapid coagulation when the host is wounded, dramatically reducing bleeding rate."
	id = "coagulating_nanites"
	build_path = /obj/item/disk/nanite_program/coagulating
	category = list("Augmentation Nanites")

/datum/design/nanites/conductive
	name = "Nanite Program Disk \[Electric Conduction\]"
	desc = "The nanites act as a grounding rod for electric shocks, protecting the host. Shocks can still damage the nanites themselves."
	id = "conductive_nanites"
	build_path = /obj/item/disk/nanite_program/conductive
	category = list("Augmentation Nanites")

////////////////////DANGEROUS NANITES//////////////////////////////////////

/datum/design/nanites/glitch
	name = "Nanite Program Disk \[Glitch\]"
	desc = "A heavy software corruption that causes nanites to gradually break down."
	id = "glitch_nanites"
	build_path = /obj/item/disk/nanite_program/glitch
	category = list("Dangerous Nanites")

/datum/design/nanites/necrotic
	name = "Nanite Program Disk \[Necrosis\]"
	desc = "The nanites attack internal tissues indiscriminately, causing widespread damage."
	id = "necrotic_nanites"
	build_path = /obj/item/disk/nanite_program/necrotic
	category = list("Dangerous Nanites")

/datum/design/nanites/toxic
	name = "Nanite Program Disk \[Toxin Buildup\]"
	desc = "The nanites cause a slow but constant toxin buildup inside the host."
	id = "toxic_nanites"
	build_path = /obj/item/disk/nanite_program/toxic
	category = list("Dangerous Nanites")

/datum/design/nanites/suffocating
	name = "Nanite Program Disk \[Hypoxemia\]"
	desc = "The nanites prevent the host's blood from absorbing oxygen efficiently."
	id = "suffocating_nanites"
	build_path = /obj/item/disk/nanite_program/suffocating
	category = list("Dangerous Nanites")

/datum/design/nanites/brain_misfire
	name = "Nanite Program Disk \[Brain Misfire\]"
	desc = "The nanites interfere with neural pathways, causing minor psychological disturbances."
	id = "brainmisfire_nanites"
	build_path = /obj/item/disk/nanite_program/brain_misfire
	category = list("Dangerous Nanites")

/datum/design/nanites/skin_decay
	name = "Nanite Program Disk \[Dermalysis\]"
	desc = "The nanites attack skin cells, causing irritation, rashes, and minor damage."
	id = "skindecay_nanites"
	build_path = /obj/item/disk/nanite_program/skin_decay
	category = list("Dangerous Nanites")

/datum/design/nanites/nerve_decay
	name = "Nanite Program Disk \[Nerve Decay\]"
	desc = "The nanites attack the host's nerves, causing lack of coordination and short bursts of paralysis."
	id = "nervedecay_nanites"
	build_path = /obj/item/disk/nanite_program/nerve_decay
	category = list("Dangerous Nanites")

/datum/design/nanites/brain_decay
	name = "Nanite Program Disk \[Brain-Eating Nanites\]"
	desc = "Damages brain cells, gradually decreasing the host's cognitive functions."
	id = "braindecay_nanites"
	build_path = /obj/item/disk/nanite_program/brain_decay
	category = list("Dangerous Nanites")

/datum/design/nanites/aggressive_replication
	name = "Nanite Program Disk \[Aggressive Replication\]"
	desc = "Nanites will consume organic matter to improve their replication rate, damaging the host."
	id = "aggressive_nanites"
	build_path = /obj/item/disk/nanite_program/aggressive_replication
	category = list("Dangerous Nanites")

/datum/design/nanites/meltdown
	name = "Nanite Program Disk \[Meltdown\]"
	desc = "Causes an internal meltdown inside the nanites, causing internal burns inside the host as well as rapidly destroying the nanite population.\
			Sets the nanites' safety threshold to 0 when activated."
	id = "meltdown_nanites"
	build_path = /obj/item/disk/nanite_program/meltdown
	category = list("Dangerous Nanites")

/datum/design/nanites/cryo
	name = "Nanite Program Disk \[Cryogenic Treatment\]"
	desc = "The nanites rapidly skin heat through the host's skin, lowering their temperature."
	id = "cryo_nanites"
	build_path = /obj/item/disk/nanite_program/cryo
	category = list("Dangerous Nanites")

/datum/design/nanites/pyro
	name = "Nanite Program Disk \[Sub-Dermal Combustion\]"
	desc = "The nanites cause buildup of flammable fluids under the host's skin, then ignites them."
	id = "pyro_nanites"
	build_path = /obj/item/disk/nanite_program/pyro
	category = list("Dangerous Nanites")

/datum/design/nanites/heart_stop
	name = "Nanite Program Disk \[Heart-Stopping Nanites\]"
	desc = "Stops the host's heart when triggered; restarts it if triggered again."
	id = "heartstop_nanites"
	build_path = /obj/item/disk/nanite_program/heart_stop
	category = list("Dangerous Nanites")

/datum/design/nanites/explosive
	name = "Nanite Program Disk \[Explosive Nanites\]"
	desc = "Blows up all the nanites inside the host in a chain reaction when triggered."
	id = "explosive_nanites"
	build_path = /obj/item/disk/nanite_program/explosive
	category = list("Dangerous Nanites")

////////////////////SUPPRESSING NANITES//////////////////////////////////////

/datum/design/nanites/shock
	name = "Nanite Program Disk \[Electric Shock\]"
	desc = "The nanites shock the host when triggered. Destroys a large amount of nanites!"
	id = "shock_nanites"
	build_path = /obj/item/disk/nanite_program/shock
	category = list("Suppressing Nanites")

/datum/design/nanites/stun
	name = "Nanite Program Disk \[Neural Shock\]"
	desc = "The nanites pulse the host's nerves when triggered, inapacitating them for a short period."
	id = "stun_nanites"
	build_path = /obj/item/disk/nanite_program/stun
	category = list("Suppressing Nanites")

/datum/design/nanites/sleepy
	name = "Nanite Program Disk \[Sleep Induction\]"
	desc = "The nanites cause rapid narcolepsy when triggered."
	id = "sleep_nanites"
	build_path = /obj/item/disk/nanite_program/sleepy
	category = list("Suppressing Nanites")

/datum/design/nanites/paralyzing
	name = "Nanite Program Disk \[Paralysis\]"
	desc = "The nanites actively suppress nervous pulses, effectively paralyzing the host."
	id = "paralyzing_nanites"
	build_path = /obj/item/disk/nanite_program/paralyzing
	category = list("Suppressing Nanites")

/datum/design/nanites/fake_death
	name = "Nanite Program Disk \[Death Simulation\]"
	desc = "The nanites induce a death-like coma into the host, able to fool most medical scans."
	id = "fakedeath_nanites"
	build_path = /obj/item/disk/nanite_program/fake_death
	category = list("Suppressing Nanites")

/datum/design/nanites/pacifying
	name = "Nanite Program Disk \[Pacification\]"
	desc = "The nanites suppress the aggression center of the brain, preventing the host from causing direct harm to others."
	id = "pacifying_nanites"
	build_path = /obj/item/disk/nanite_program/pacifying
	category = list("Suppressing Nanites")
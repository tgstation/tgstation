
//jobs from ss13 but DEAD.

/obj/effect/mob_spawn/corpse/human/cargo_tech
	name = JOB_CARGO_TECHNICIAN
	outfit = /datum/outfit/job/cargo_tech
	icon_state = "corpsecargotech"

/obj/effect/mob_spawn/corpse/human/cook
	name = JOB_COOK
	outfit = /datum/outfit/job/cook
	icon_state = "corpsecook"

/obj/effect/mob_spawn/corpse/human/doctor
	name = JOB_MEDICAL_DOCTOR
	outfit = /datum/outfit/job/doctor
	icon_state = "corpsedoctor"

/obj/effect/mob_spawn/corpse/human/geneticist
	name = JOB_GENETICIST
	outfit = /datum/outfit/job/geneticist
	icon_state = "corpsescientist"

/obj/effect/mob_spawn/corpse/human/engineer
	name = JOB_STATION_ENGINEER
	outfit = /datum/outfit/job/engineer/gloved
	icon_state = "corpseengineer"

/obj/effect/mob_spawn/corpse/human/engineer/mod
	outfit = /datum/outfit/job/engineer/mod

/obj/effect/mob_spawn/corpse/human/clown
	name = JOB_CLOWN
	outfit = /datum/outfit/job/clown
	icon_state = "corpseclown"

/obj/effect/mob_spawn/corpse/human/scientist
	name = JOB_SCIENTIST
	outfit = /datum/outfit/job/scientist
	icon_state = "corpsescientist"

/obj/effect/mob_spawn/corpse/human/miner
	name = JOB_SHAFT_MINER
	outfit = /datum/outfit/job/miner
	icon_state = "corpseminer"

/obj/effect/mob_spawn/corpse/human/miner/mod
	outfit = /datum/outfit/job/miner/equipped/mod

/obj/effect/mob_spawn/corpse/human/miner/explorer
	outfit = /datum/outfit/job/miner/equipped

/obj/effect/mob_spawn/corpse/human/plasmaman
	mob_species = /datum/species/plasmaman
	outfit = /datum/outfit/plasmaman

/obj/effect/mob_spawn/corpse/human/assistant
	name = JOB_ASSISTANT
	outfit = /datum/outfit/job/assistant
	icon_state = "corpsegreytider"

/obj/effect/mob_spawn/corpse/human/assistant/beesease_infection/special(mob/living/spawned_mob)
	. = ..()
	spawned_mob.ForceContractDisease(new /datum/disease/beesease)

/obj/effect/mob_spawn/corpse/human/assistant/brainrot_infection/special(mob/living/spawned_mob)
	. = ..()
	spawned_mob.ForceContractDisease(new /datum/disease/brainrot)

/obj/effect/mob_spawn/corpse/human/assistant/spanishflu_infection/special(mob/living/spawned_mob)
	. = ..()
	spawned_mob.ForceContractDisease(new /datum/disease/fluspanish)

/obj/effect/mob_spawn/corpse/human/bartender
	name = JOB_BARTENDER
	outfit = /datum/outfit/spacebartender

/obj/effect/mob_spawn/corpse/human/prisoner
	name = JOB_PRISONER
	outfit = /datum/outfit/job/prisoner

/obj/effect/mob_spawn/corpse/human/roboticist
	name = JOB_ROBOTICIST
	outfit = /datum/outfit/job/roboticist
	icon_state = "corpseroboticist"

/obj/effect/mob_spawn/corpse/human/bitrunner
	name = JOB_BITRUNNER
	outfit = /datum/outfit/job/bitrunner
	icon_state = "corpsecargotech"

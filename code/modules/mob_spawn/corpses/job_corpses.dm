
//jobs from ss13 but DEAD.

/obj/effect/mob_spawn/corpse/human/cargo_tech
	name = "Cargo Tech"
	outfit = /datum/outfit/job/cargo_tech
	icon_state = "corpsecargotech"

/obj/effect/mob_spawn/corpse/human/cook
	name = "Cook"
	outfit = /datum/outfit/job/cook
	icon_state = "corpsecook"

/obj/effect/mob_spawn/corpse/human/doctor
	name = "Doctor"
	outfit = /datum/outfit/job/doctor
	icon_state = "corpsedoctor"

/obj/effect/mob_spawn/corpse/human/geneticist
	name = "Geneticist"
	outfit = /datum/outfit/job/geneticist
	icon_state = "corpsescientist"

/obj/effect/mob_spawn/corpse/human/engineer
	name = "Engineer"
	outfit = /datum/outfit/job/engineer/gloved
	icon_state = "corpseengineer"

/obj/effect/mob_spawn/corpse/human/engineer/rig
	outfit = /datum/outfit/job/engineer/gloved/rig

/obj/effect/mob_spawn/corpse/human/engineer/rig/gunner
	outfit = /datum/outfit/job/engineer/gloved/rig/gunner

/obj/effect/mob_spawn/corpse/human/clown
	name = "Clown"
	outfit = /datum/outfit/job/clown
	icon_state = "corpseclown"

/obj/effect/mob_spawn/corpse/human/scientist
	name = "Scientist"
	outfit = /datum/outfit/job/scientist
	icon_state = "corpsescientist"

/obj/effect/mob_spawn/corpse/human/miner
	name = "Shaft Miner"
	outfit = /datum/outfit/job/miner
	icon_state = "corpseminer"

/obj/effect/mob_spawn/corpse/human/miner/rig
	outfit = /datum/outfit/job/miner/equipped/hardsuit

/obj/effect/mob_spawn/corpse/human/miner/explorer
	outfit = /datum/outfit/job/miner/equipped

/obj/effect/mob_spawn/corpse/human/plasmaman
	mob_species = /datum/species/plasmaman
	outfit = /datum/outfit/plasmaman

/obj/effect/mob_spawn/corpse/human/assistant
	name = "Assistant"
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
	name = "Bartender"
	outfit = /datum/outfit/spacebartender

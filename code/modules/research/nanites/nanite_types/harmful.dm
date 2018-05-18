//Nanites that are actively harmful to the host.

/datum/reagent/nanites/programmed/necrotic
	name = "Necrotic Nanites"
	description = "Causes physical damage inside the host."
	id = "necrotic_nanites"
	metabolization_rate = 1.25
	rogue_types = list("regenerative_nanites","bloodheal_nanites")

/datum/reagent/nanites/programmed/necrotic/nanite_life(mob/living/M)
	M.adjustBruteLoss(2, TRUE)

/datum/reagent/nanites/programmed/brain_decay
	name = "Brain-Eating Nanites"
	description = "Damages brain cells, gradually decreasing the host's cognitive functions."
	id = "braindecay_nanites"
	metabolization_rate = 1
	rogue_types = list("brainheal_nanites")

/datum/reagent/nanites/programmed/brain_decay/nanite_life(mob/living/M)
	M.adjustBrainLoss(1)

/datum/reagent/nanites/programmed/pyro
	name = "Pyroclastic Nanites"
	description = "Ignites the user while active."
	id = "pyro_nanites"
	metabolization_rate = 4
	rogue_types = list("temperature_nanites","cryo_nanites")

/datum/reagent/nanites/programmed/pyro/check_conditions(mob/living/M)
	if(M.fire_stacks >= 10 && M.on_fire)
		return FALSE
	. = ..()

/datum/reagent/nanites/programmed/pyro/nanite_life(mob/living/M)
	M.fire_stacks += 1
	M.IgniteMob()

/datum/reagent/nanites/programmed/cryo
	name = "Cryogenic Nanites"
	description = "Cools down and freezes the host."
	id = "cryo_nanites"
	metabolization_rate = 1.5
	rogue_types = list("temperature_nanites","pyro_nanites")

/datum/reagent/nanites/programmed/cryo/check_conditions(mob/living/M)
	if(M.bodytemperature <= 70)
		return FALSE
	. = ..()

/datum/reagent/nanites/programmed/cryo/nanite_life(mob/living/M)
	M.adjust_bodytemperature(-rand(10,20), 50)

/datum/reagent/nanites/programmed/toxic
	name = "Toxic Nanites"
	description = "Causes slow but constant toxin buildup inside the host."
	id = "toxic_nanites"
	metabolization_rate = 0.5
	rogue_types = list("purging_nanites")

/datum/reagent/nanites/programmed/toxic/nanite_life(mob/living/M)
	M.adjustToxLoss(0.5)

/datum/reagent/nanites/programmed/suffocating
	name = "Suffocating Nanites"
	description = "Causes subtle oxygen deprivation in the host."
	id = "suffocating_nanites"
	metabolization_rate = 1.75
	rogue_types = list("purging_nanites")

/datum/reagent/nanites/programmed/suffocating/nanite_life(mob/living/M)
	M.adjustOxyLoss(4, 0)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.losebreath = min(C.losebreath, 3)

//Nanites that heal the host in some way.

/datum/reagent/nanites/programmed/regenerative
	name = "Regenerative Nanites"
	description = "Patches up physical damage inside the host."
	id = "regenerative_nanites"
	metabolization_rate = 0.75
	rogue_types = list("necrotic_nanites")

/datum/reagent/nanites/programmed/regenerative/check_conditions(mob/living/M)
	if(!M.getBruteLoss() && !M.getFireLoss())
		return FALSE
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		var/list/parts = C.get_damaged_bodyparts(TRUE,TRUE, status = BODYPART_ORGANIC)
		if(!parts.len)
			return FALSE
	. = ..()

/datum/reagent/nanites/programmed/regenerative/nanite_life(mob/living/M)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		var/list/parts = C.get_damaged_bodyparts(TRUE,TRUE, status = BODYPART_ORGANIC)
		if(!parts.len)
			return
		for(var/obj/item/bodypart/L in parts)
			if(L.heal_damage(2/parts.len, 2/parts.len))
				M.update_damage_overlays()
	else
		M.adjustBruteLoss(-2, TRUE)
		M.adjustFireLoss(-2, TRUE)

/datum/reagent/nanites/programmed/temperature
	name = "Temperature-Adjustment Nanites"
	description = "Balances the host's temperature."
	id = "temperature_nanites"
	metabolization_rate = 0.75
	rogue_types = list("pyro_nanites","cryo_nanites")

/datum/reagent/nanites/programmed/temperature/check_conditions(mob/living/M)
	if(M.bodytemperature > (BODYTEMP_NORMAL - 30) && M.bodytemperature < (BODYTEMP_NORMAL + 30))
		return FALSE
	. = ..()

/datum/reagent/nanites/programmed/temperature/nanite_life(mob/living/M)
	if(M.bodytemperature > BODYTEMP_NORMAL)
		M.adjust_bodytemperature(-40 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	else if(M.bodytemperature < (BODYTEMP_NORMAL + 1))
		M.adjust_bodytemperature(40 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)

/datum/reagent/nanites/programmed/purging
	name = "Purging Nanites"
	description = "Purges toxins and chemicals from the host's bloodstream."
	id = "purging_nanites"
	metabolization_rate = 0.75
	rogue_types = list("toxic_nanites")

/datum/reagent/nanites/programmed/purging/check_conditions(mob/living/M)
	var/foreign_reagent = FALSE
	for(var/X in holder.reagent_list)
		var/datum/reagent/R = X
		if(!istype(R, /datum/reagent/nanites))
			foreign_reagent = TRUE
			break
	if(!M.getToxLoss() && !foreign_reagent)
		return FALSE
	. = ..()

/datum/reagent/nanites/programmed/purging/nanite_life(mob/living/M)
	M.adjustToxLoss(-2)
	for(var/X in holder.reagent_list)
		var/datum/reagent/R = X
		if(!istype(R, /datum/reagent/nanites))
			holder.remove_reagent(R.id, 1)


/datum/reagent/nanites/programmed/brain_heal
	name = "Brain-Restoring Nanites"
	description = "Fixes neural connections in the host's brain, reversing brain damage and minor traumas."
	id = "brainheal_nanites"
	metabolization_rate = 1
	rogue_types = list("braindecay_nanites")

/datum/reagent/nanites/programmed/brain_heal/check_conditions(mob/living/M)
	if(!M.getBrainLoss())
		return FALSE
	. = ..()

/datum/reagent/nanites/programmed/brain_heal/nanite_life(mob/living/M)
	M.adjustBrainLoss(-1, TRUE)
	if(iscarbon(M) && prob(10))
		var/mob/living/carbon/C = M
		C.cure_trauma_type(resilience = TRAUMA_RESILIENCE_BASIC)

/datum/reagent/nanites/programmed/blood_restoring
	name = "Blood-Restoring Nanites"
	description = "Replaces the host's lost blood."
	id = "bloodheal_nanites"
	metabolization_rate = 0.75
	rogue_types = list("necrotic_nanites")

/datum/reagent/nanites/programmed/blood_restoring/check_conditions(mob/living/M)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.blood_volume >= BLOOD_VOLUME_SAFE)
			return FALSE
	else
		return FALSE
	. = ..()

/datum/reagent/nanites/programmed/blood_restoring/nanite_life(mob/living/M)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.blood_volume += 2

/datum/reagent/nanites/programmed/repairing
	name = "Repairing Nanites"
	description = "Patches up mechanical damage inside the host."
	id = "repairing_nanites"
	metabolization_rate = 0.50
	rogue_types = list("necrotic_nanites")

/datum/reagent/nanites/programmed/repairing/check_conditions(mob/living/M)
	if(!M.getBruteLoss() && !M.getFireLoss())
		return FALSE
	if(!(MOB_ROBOTIC in M.mob_biotypes))
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			var/list/parts = C.get_damaged_bodyparts(TRUE, TRUE, status = BODYPART_ROBOTIC)
			if(!parts.len)
				return FALSE
		else
			return FALSE
	. = ..()

/datum/reagent/nanites/programmed/repairing/nanite_life(mob/living/M)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		var/list/parts = C.get_damaged_bodyparts(TRUE, TRUE, status = BODYPART_ROBOTIC)
		if(!parts.len)
			return
		for(var/obj/item/bodypart/L in parts)
			if(L.heal_damage(2/parts.len, 2/parts.len))
				M.update_damage_overlays()
	else
		M.adjustBruteLoss(-2, TRUE)
		M.adjustFireLoss(-2, TRUE)
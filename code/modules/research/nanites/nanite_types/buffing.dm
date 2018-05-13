//Nanites that buff the host in some way.

/datum/reagent/nanites/programmed/nervous
	name = "Nervous Nanites"
	description = "Reduces stunning effects on the host."
	id = "nervous_nanites"
	metabolization_rate = 1.5
	rogue_types = list("paralyzing_nanites")

/datum/reagent/nanites/programmed/nervous/check_conditions(mob/living/M)
	if(!M.IsStun() && !M.IsKnockdown() && !M.IsUnconscious() && !M.IsSleeping())
		return FALSE
	. = ..()

/datum/reagent/nanites/programmed/nervous/nanite_life(mob/living/M)
	M.AdjustStun(-20)
	M.AdjustKnockdown(-20)
	M.AdjustUnconscious(-20)
	M.AdjustSleeping(-20)

/datum/reagent/nanites/programmed/hardening
	name = "Hardening Nanites"
	description = "Makes the host harder to damage with bullets and melee attacks."
	id = "hardening_nanites"
	metabolization_rate = 0.50
	rogue_types = list("necrotic_nanites")

/datum/reagent/nanites/programmed/hardening/enable_passive_effect()
	..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.armor.melee += 40
		H.physiology.armor.bullet += 25

/datum/reagent/nanites/programmed/hardening/disable_passive_effect()
	..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.armor.melee -= 40
		H.physiology.armor.bullet -= 25

/datum/reagent/nanites/programmed/coagulating
	name = "Coagulating Nanites"
	description = "Slows the host's bleeding rate."
	id = "hardening_nanites"
	metabolization_rate = 0.05
	rogue_types = list("necrotic_nanites")

/datum/reagent/nanites/programmed/coagulating/enable_passive_effect()
	..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.bleed_mod *= 0.1

/datum/reagent/nanites/programmed/coagulating/disable_passive_effect()
	..()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		H.physiology.bleed_mod *= 10


/* NEEDS THE MEMENTO MORI PR
/datum/reagent/nanites/programmed/survival
	name = "Survival Nanites"
	description = "Keeps the host alive under extreme conditions."
	id = "survival_nanites"
	metabolization_rate = 5
	rogue_types = list("necrotic_nanites")

/datum/reagent/nanites/programmed/survival/check_conditions(mob/living/M)
	metabolization_rate = min(0, -5 * M.health) //only activates (and consumes nanites) if in crit, consumes faster if dying harder
	. = ..()

/datum/reagent/nanites/programmed/survival/enable_passive_effect()
	..()
	if(iscarbon(host_mob))
		host_mob.add_trait(TRAIT_NODEATH, "nanites")
		host_mob.add_trait(TRAIT_NOHARDCRIT, "nanites")
		host_mob.add_trait(TRAIT_NOCRITDAMAGE, "nanites")

/datum/reagent/nanites/programmed/survival/disable_passive_effect()
	..()
	if(iscarbon(host_mob))
		host_mob.remove_trait(TRAIT_NODEATH, "nanites")
		host_mob.remove_trait(TRAIT_NOHARDCRIT, "nanites")
		host_mob.remove_trait(TRAIT_NOCRITDAMAGE, "nanites")
*/
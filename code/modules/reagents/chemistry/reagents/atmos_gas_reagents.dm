/datum/reagent/freon
	name = "Freon"
	description = "A powerful heat absorbent."
	reagent_state = GAS
	metabolization_rate = REAGENTS_METABOLISM * 0.5 // Because nitrium/freon/hypernoblium are handled through gas breathing, metabolism must be lower for breathcode to keep up
	color = "90560B"
	taste_description = "burning"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/freon/on_mob_metabolize(mob/living/breather)
	. = ..()
	breather.add_movespeed_modifier(/datum/movespeed_modifier/reagent/freon)

/datum/reagent/freon/on_mob_end_metabolize(mob/living/breather)
	breather.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/freon)
	return ..()

/datum/reagent/halon
	name = "Halon"
	description = "A fire suppression gas that removes oxygen and cools down the area"
	reagent_state = GAS
	metabolization_rate = REAGENTS_METABOLISM * 0.5
	color = "90560B"
	taste_description = "minty"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/halon/on_mob_metabolize(mob/living/breather)
	. = ..()
	breather.add_movespeed_modifier(/datum/movespeed_modifier/reagent/halon)
	ADD_TRAIT(breather, TRAIT_RESISTHEAT, type)

/datum/reagent/halon/on_mob_end_metabolize(mob/living/breather)
	breather.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/halon)
	REMOVE_TRAIT(breather, TRAIT_RESISTHEAT, type)
	return ..()

/datum/reagent/healium
	name = "Healium"
	description = "A powerful sleeping agent with healing properties"
	reagent_state = GAS
	metabolization_rate = REAGENTS_METABOLISM * 0.5
	color = "90560B"
	taste_description = "rubbery"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/healium/on_mob_metabolize(mob/living/breather)
	. = ..()
	breather.PermaSleeping()

/datum/reagent/healium/on_mob_end_metabolize(mob/living/breather)
	breather.SetSleeping(10)
	return ..()

/datum/reagent/healium/on_mob_life(mob/living/breather, delta_time, times_fired)
	breather.adjustFireLoss(-2 * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
	breather.adjustToxLoss(-5 * REM * delta_time, FALSE, required_biotype = affected_biotype)
	breather.adjustBruteLoss(-2 * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
	return ..()

/datum/reagent/hypernoblium
	name = "Hyper-Noblium"
	description = "A suppressive gas that stops gas reactions on those who inhale it."
	reagent_state = GAS
	metabolization_rate = REAGENTS_METABOLISM * 0.5 // Because nitrium/freon/hyper-nob are handled through gas breathing, metabolism must be lower for breathcode to keep up
	color = "90560B"
	taste_description = "searingly cold"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/hypernoblium/on_mob_life(mob/living/carbon/breather, delta_time, times_fired)
	if(isplasmaman(breather))
		breather.set_timed_status_effect(10 SECONDS * REM * delta_time, /datum/status_effect/hypernob_protection)
	..()

/datum/reagent/nitrium_high_metabolization
	name = "Nitrosyl plasmide"
	description = "A highly reactive byproduct that stops you from sleeping, while dealing increasing toxin damage over time."
	reagent_state = GAS
	metabolization_rate = REAGENTS_METABOLISM * 0.5 // Because nitrium/freon/hypernoblium are handled through gas breathing, metabolism must be lower for breathcode to keep up
	color = "E1A116"
	taste_description = "sourness"
	ph = 1.8
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE
	addiction_types = list(/datum/addiction/stimulants = 14)

/datum/reagent/nitrium_high_metabolization/on_mob_metabolize(mob/living/breather)
	. = ..()
	ADD_TRAIT(breather, TRAIT_SLEEPIMMUNE, type)

/datum/reagent/nitrium_high_metabolization/on_mob_end_metabolize(mob/living/breather)
	REMOVE_TRAIT(breather, TRAIT_SLEEPIMMUNE, type)
	return ..()

/datum/reagent/nitrium_high_metabolization/on_mob_life(mob/living/carbon/breather, delta_time, times_fired)
	breather.adjustStaminaLoss(-2 * REM * delta_time, FALSE, required_biotype = affected_biotype)
	breather.adjustToxLoss(0.1 * current_cycle * REM * delta_time, FALSE, required_biotype = affected_biotype) // 1 toxin damage per cycle at cycle 10
	return ..()

/datum/reagent/nitrium_low_metabolization
	name = "Nitrium"
	description = "A highly reactive gas that makes you feel faster."
	reagent_state = GAS
	metabolization_rate = REAGENTS_METABOLISM * 0.5 // Because nitrium/freon/hypernoblium are handled through gas breathing, metabolism must be lower for breathcode to keep up
	color = "90560B"
	taste_description = "burning"
	ph = 2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/nitrium_low_metabolization/on_mob_metabolize(mob/living/breather)
	. = ..()
	breather.add_movespeed_modifier(/datum/movespeed_modifier/reagent/nitrium)

/datum/reagent/nitrium_low_metabolization/on_mob_end_metabolize(mob/living/breather)
	breather.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/nitrium)
	return ..()

/datum/reagent/pluoxium
	name = "Pluoxium"
	description = "A gas that is eight times more efficient than O2 at lung diffusion with organ healing properties on sleeping patients."
	reagent_state = GAS
	metabolization_rate = REAGENTS_METABOLISM * 0.5
	color = "#808080"
	taste_description = "irradiated air"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/pluoxium/on_mob_life(mob/living/carbon/breather, delta_time, times_fired)
	if(!HAS_TRAIT(breather, TRAIT_KNOCKEDOUT))
		return ..()

	for(var/obj/item/organ/organ_being_healed as anything in breather.internal_organs)
		organ_being_healed.applyOrganDamage(-0.5 * REM * delta_time)

	return ..()

/datum/reagent/zauker
	name = "Zauker"
	description = "An unstable gas that is toxic to all living beings."
	reagent_state = GAS
	metabolization_rate = REAGENTS_METABOLISM * 0.5
	color = "90560B"
	taste_description = "bitter"
	chemical_flags = REAGENT_NO_RANDOM_RECIPE

/datum/reagent/zauker/on_mob_life(mob/living/breather, delta_time, times_fired)
	breather.adjustBruteLoss(6 * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
	breather.adjustOxyLoss(1 * REM * delta_time, FALSE, required_biotype = affected_biotype)
	breather.adjustFireLoss(2 * REM * delta_time, FALSE, required_bodytype = affected_bodytype)
	breather.adjustToxLoss(2 * REM * delta_time, FALSE, required_biotype = affected_biotype)
	return ..()

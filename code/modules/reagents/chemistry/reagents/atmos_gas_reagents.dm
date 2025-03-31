/datum/reagent/freon
	name = "Freon"
	description = "A powerful heat absorbent."
	metabolization_rate = REAGENTS_METABOLISM * 0.5 // Because nitrium/freon/hypernoblium are handled through gas breathing, metabolism must be lower for breathcode to keep up
	color = "90560B"
	taste_description = "burning"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/freon/on_mob_metabolize(mob/living/breather)
	. = ..()
	breather.add_movespeed_modifier(/datum/movespeed_modifier/reagent/freon)

/datum/reagent/freon/on_mob_end_metabolize(mob/living/breather)
	. = ..()
	breather.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/freon)

/datum/reagent/halon
	name = "Halon"
	description = "A fire suppression gas that removes oxygen and cools down the area"
	metabolization_rate = REAGENTS_METABOLISM * 0.5
	color = "90560B"
	taste_description = "minty"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE
	metabolized_traits = list(TRAIT_RESISTHEAT)

/datum/reagent/halon/on_mob_metabolize(mob/living/breather)
	. = ..()
	breather.add_movespeed_modifier(/datum/movespeed_modifier/reagent/halon)

/datum/reagent/halon/on_mob_end_metabolize(mob/living/breather)
	. = ..()
	breather.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/halon)

/datum/reagent/healium
	name = "Healium"
	description = "A powerful sleeping agent with healing properties"
	metabolization_rate = REAGENTS_METABOLISM * 0.5
	color = "90560B"
	taste_description = "rubbery"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/healium/on_mob_end_metabolize(mob/living/breather)
	. = ..()
	breather.SetSleeping(1 SECONDS)

/datum/reagent/healium/on_mob_life(mob/living/breather, seconds_per_tick, times_fired)
	. = ..()
	breather.SetSleeping(30 SECONDS)
	var/need_mob_update
	need_mob_update = breather.adjustFireLoss(-2 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += breather.adjustToxLoss(-5 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)
	need_mob_update += breather.adjustBruteLoss(-2 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/hypernoblium
	name = "Hyper-Noblium"
	description = "A suppressive gas that stops gas reactions on those who inhale it."
	metabolization_rate = REAGENTS_METABOLISM * 0.5 // Because nitrium/freon/hyper-nob are handled through gas breathing, metabolism must be lower for breathcode to keep up
	color = "90560B"
	taste_description = "searingly cold"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/hypernoblium/on_mob_life(mob/living/carbon/breather, seconds_per_tick, times_fired)
	. = ..()
	if(isplasmaman(breather))
		breather.set_timed_status_effect(10 SECONDS * REM * seconds_per_tick, /datum/status_effect/hypernob_protection)

/datum/reagent/nitrium_high_metabolization
	name = "Nitrosyl plasmide"
	description = "A highly reactive byproduct that stops you from sleeping, while dealing increasing toxin damage over time."
	metabolization_rate = REAGENTS_METABOLISM * 0.5 // Because nitrium/freon/hypernoblium are handled through gas breathing, metabolism must be lower for breathcode to keep up
	color = "E1A116"
	taste_description = "sourness"
	ph = 1.8
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE
	addiction_types = list(/datum/addiction/stimulants = 14)
	metabolized_traits = list(TRAIT_SLEEPIMMUNE)

/datum/reagent/nitrium_high_metabolization/on_mob_life(mob/living/carbon/breather, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = breather.adjustStaminaLoss(-4 * REM * seconds_per_tick, updating_stamina = FALSE, required_biotype = affected_biotype)
	need_mob_update += breather.adjustToxLoss(0.1 * (current_cycle-1) * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype) // 1 toxin damage per cycle at cycle 10
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/nitrium_low_metabolization
	name = "Nitrium"
	description = "A highly reactive gas that makes you feel faster."
	metabolization_rate = REAGENTS_METABOLISM * 0.5 // Because nitrium/freon/hypernoblium are handled through gas breathing, metabolism must be lower for breathcode to keep up
	color = "90560B"
	taste_description = "burning"
	ph = 2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/nitrium_low_metabolization/on_mob_metabolize(mob/living/breather)
	. = ..()
	breather.add_movespeed_modifier(/datum/movespeed_modifier/reagent/nitrium)

/datum/reagent/nitrium_low_metabolization/on_mob_end_metabolize(mob/living/breather)
	. = ..()
	breather.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/nitrium)

/datum/reagent/pluoxium
	name = "Pluoxium"
	description = "A gas that is eight times more efficient than O2 at lung diffusion with organ healing properties on sleeping patients."
	metabolization_rate = REAGENTS_METABOLISM * 0.5
	color = COLOR_GRAY
	taste_description = "irradiated air"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/pluoxium/on_mob_life(mob/living/carbon/breather, seconds_per_tick, times_fired)
	. = ..()
	if(!HAS_TRAIT(breather, TRAIT_KNOCKEDOUT))
		return

	for(var/obj/item/organ/organ_being_healed as anything in breather.organs)
		if(!organ_being_healed.damage)
			continue

		if(organ_being_healed.apply_organ_damage(-0.5 * REM * seconds_per_tick, required_organ_flag = ORGAN_ORGANIC))
			. = UPDATE_MOB_HEALTH

/datum/reagent/zauker
	name = "Zauker"
	description = "An unstable gas that is toxic to all living beings."
	metabolization_rate = REAGENTS_METABOLISM * 0.5
	color = "90560B"
	taste_description = "bitter"
	chemical_flags = REAGENT_NO_RANDOM_RECIPE
	affected_biotype = MOB_ORGANIC | MOB_MINERAL | MOB_PLANT // "toxic to all living beings"
	affected_respiration_type = ALL

/datum/reagent/zauker/on_mob_life(mob/living/breather, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = breather.adjustBruteLoss(6 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += breather.adjustOxyLoss(1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
	need_mob_update += breather.adjustFireLoss(2 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
	need_mob_update += breather.adjustToxLoss(2 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

//does toxin damage, hallucination, targets think they're not hurt at all
/datum/blobstrain/reagent/regenerative_materia
	name = "Regenerative Materia"
	description = "will do medium initial toxin damage, injecting a poison which does more toxin damage and makes targets believe they are fully healed. The core regenerates much faster."
	analyzerdescdamage = "Does medium initial toxin damage, injecting a poison which does more toxin damage and makes targets believe they are fully healed. Core regenerates much faster."
	color = "#A88FB7"
	complementary_color = "#AF7B8D"
	message_living = ", and you feel <i>alive</i>"
	reagent = /datum/reagent/blob/regenerative_materia
	core_regen_bonus = 18
	point_rate_bonus = 1

/datum/reagent/blob/regenerative_materia
	name = "Regenerative Materia"
	taste_description = "heaven"
	color = "#A88FB7"

/datum/reagent/blob/regenerative_materia/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/overmind)
	. = ..()
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	exposed_mob.adjust_drugginess(reac_volume * 2 SECONDS)
	if(exposed_mob.reagents)
		exposed_mob.reagents.add_reagent(/datum/reagent/blob/regenerative_materia, 0.2*reac_volume)
		exposed_mob.reagents.add_reagent(/datum/reagent/toxin/spore, 0.2*reac_volume)
	exposed_mob.apply_damage(0.7*reac_volume, TOX)

/datum/reagent/blob/regenerative_materia/on_mob_life(mob/living/carbon/metabolizer, delta_time, times_fired)
	metabolizer.adjustToxLoss(1 * REAGENTS_EFFECT_MULTIPLIER * delta_time)
	..()
	return TRUE

/datum/reagent/blob/regenerative_materia/on_mob_metabolize(mob/living/metabolizer)
	. = ..()
	metabolizer.apply_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)

/datum/reagent/blob/regenerative_materia/on_mob_end_metabolize(mob/living/metabolizer)
	. = ..()
	metabolizer.remove_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)

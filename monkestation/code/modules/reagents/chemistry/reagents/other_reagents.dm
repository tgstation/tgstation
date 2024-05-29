/datum/reagent/acetone_oxide // Overriding to give this an actual function as liquid fire.
	name = "Acetone Oxide"
	description = "Enslaved oxygen"
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "acid"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/acetone_oxide/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)//Splashing people kills people!
	. = ..()
	if(methods & TOUCH | VAPOR | INGEST)
		exposed_mob.adjustFireLoss(((reac_volume * 2) / 1.65))
		exposed_mob.adjust_fire_stacks((reac_volume / 5))

/datum/reagent/acetone_oxide/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired) // Old acetone oxide didn't have a metabolism effect!
	. = ..()
	var/uh_oh_message = pick("You rub your eyes.", "Your eyes lose focus for a second.", "Your stomach cramps!")
	if (SPT_PROB(2.5, seconds_per_tick))
		to_chat(affected_mob, span_notice("[uh_oh_message]"))
	affected_mob.adjustOrganLoss(ORGAN_SLOT_STOMACH, 2 * REM * 1, required_organtype = affected_organtype) // Kills your stomach.
	affected_mob.adjustOrganLoss(ORGAN_SLOT_EYES, 2 * REM * 1, required_organtype = affected_organtype) // Kills your eyes too.



/datum/reagent/hydrogen_peroxide // The wimpier cousin to Acetone Oxide which burns half as hot. Also needed an override because it's wimpy in TG code.
	name = "Hydrogen Peroxide"
	description = "An ubiquitous chemical substance that is composed of hydrogen and oxygen and oxygen." //intended intended
	color = "#AAAAAA77" // rgb: 170, 170, 170, 77 (alpha)
	taste_description = "burning water"
	ph = 6.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	turf_exposure = TRUE

/datum/glass_style/shot_glass/hydrogen_peroxide
	required_drink_type = /datum/reagent/hydrogen_peroxide
	icon_state = "shotglassclear"

/datum/glass_style/drinking_glass/hydrogen_peroxide
	required_drink_type = /datum/reagent/hydrogen_peroxide
	name = "glass of oxygenated water"
	desc = "The father of all refreshments. Surely it tastes great, right?"
	icon_state = "glass_clear"

/*
 * Water reaction to turf
 */

/datum/reagent/hydrogen_peroxide/expose_turf(turf/open/exposed_turf, reac_volume)
	. = ..()
	if(!istype(exposed_turf))
		return
	if(reac_volume >= 5)
		exposed_turf.MakeSlippery(TURF_WET_WATER, 10 SECONDS, min(reac_volume*1.5 SECONDS, 60 SECONDS))
/*
 * Water reaction to a mob
 */

/datum/reagent/hydrogen_peroxide/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)//Splashing people with h2o2 can burn them !
	. = ..()
	if(methods & TOUCH)
		exposed_mob.adjustFireLoss(((reac_volume * 2) / 3))

/datum/reagent/hydrogen_peroxide/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired) // Old h2o2 didn't have a metabolizing effect either!
	. = ..()
	var/tummy_ache_message = pick("Your stomach rumbles.", "Your stomach is upset!", "You don't feel very good...")
	if (SPT_PROB(2.5, seconds_per_tick))
		to_chat(affected_mob, span_notice("[tummy_ache_message]"))
	affected_mob.adjustOrganLoss(ORGAN_SLOT_STOMACH, 2 * REM * 1, required_organtype = affected_organtype) // Tumby hurty...



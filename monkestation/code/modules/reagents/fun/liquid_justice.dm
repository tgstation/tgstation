/datum/reagent/liquid_justice
	name = "Liquid justice"
	description = "Rumors say that only the truly robust can safelly process this chemical"
	color = "#00ffff" // rgb: 0,255,255
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	ph = 0

/*
Liquid justce - Metabolizes 50% quicker than phlogiston, gives double the firestacks but dosent deal direct fire damage
*/

/datum/reagent/liquid_justice/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	// if you don't have a liver, or your liver isn't an officer's liver
	var/obj/item/organ/internal/liver/liver = affected_mob.get_organ_slot(ORGAN_SLOT_LIVER)
	if(!liver || !HAS_TRAIT(liver, TRAIT_LAW_ENFORCEMENT_METABOLISM))
		affected_mob.adjust_fire_stacks(2 * REM * seconds_per_tick)
		affected_mob.ignite_mob()

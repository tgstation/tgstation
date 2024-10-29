//does brute, burn, and toxin damage, and cools targets down
/datum/blobstrain/reagent/cryogenic_poison
	name = "Cryogenic Poison"
	description = "will inject targets with a freezing poison, applying little impact damage but dealing high damage over time."
	analyzerdescdamage = "Injects targets with a freezing poison that will gradually solidify the target's internal organs."
	color = "#8BA6E9"
	complementary_color = "#7D6EB4"
	blobbernaut_message = "injects"
	message = "The blob stabs you"
	message_living = ", and you feel like your insides are solidifying"
	reagent = /datum/reagent/blob/cryogenic_poison

/datum/reagent/blob/cryogenic_poison
	name = "Cryogenic Poison"
	description = "A freezing poison that does high damage over time. Cryogenic poison blobs inject this into their victims."
	color = "#8BA6E9"
	taste_description = "brain freeze"

/datum/reagent/blob/cryogenic_poison/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/overmind)
	. = ..()
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	if(exposed_mob.reagents)
		exposed_mob.reagents.add_reagent(/datum/reagent/consumable/frostoil, 0.3*reac_volume)
		exposed_mob.reagents.add_reagent(/datum/reagent/consumable/ice, 0.3*reac_volume)
		exposed_mob.reagents.add_reagent(/datum/reagent/blob/cryogenic_poison, 0.3*reac_volume)
	exposed_mob.apply_damage(0.2*reac_volume, BRUTE, wound_bonus=CANT_WOUND)

/datum/reagent/blob/cryogenic_poison/on_mob_life(mob/living/carbon/exposed_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = exposed_mob.adjustBruteLoss(0.5 * REM * seconds_per_tick, updating_health = FALSE)
	need_mob_update += exposed_mob.adjustFireLoss(0.5 * REM * seconds_per_tick, updating_health = FALSE)
	need_mob_update += exposed_mob.adjustToxLoss(0.5 * REM * seconds_per_tick, updating_health = FALSE)
	if(need_mob_update)
		. = UPDATE_MOB_HEALTH

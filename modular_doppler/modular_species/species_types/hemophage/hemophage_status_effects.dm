/// How much brute damage their body regenerates per second while using blood regeneration.
#define BLOOD_REGEN_BRUTE_AMOUNT 2
/// How much burn damage their body regenerates per second while using blood regeneration.
#define BLOOD_REGEN_BURN_AMOUNT 2
/// How much toxin damage their body regenerates per second while using blood regeneration.
#define BLOOD_REGEN_TOXIN_AMOUNT 1.5
/// How much cellular damage their body regenerates per second while using blood regeneration.
#define BLOOD_REGEN_CELLULAR_AMOUNT 1.50

/datum/status_effect/blood_thirst_satiated
	id = "blood_thirst_satiated"
	duration = 30 MINUTES
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/blood_thirst_satiated
	/// What will the bloodloss_speed_multiplier of the Hemophage be changed by upon receiving this status effect?
	var/bloodloss_speed_multiplier = 0.5


/datum/status_effect/blood_thirst_satiated/on_apply()
	// This status effect should not exist on its own, or on a non-human.
	if(!owner || !ishuman(owner))
		return FALSE

	var/obj/item/organ/heart/hemophage/tumor_heart = owner.get_organ_by_type(/obj/item/organ/heart/hemophage)

	if(!tumor_heart)
		return FALSE

	tumor_heart.bloodloss_rate *= bloodloss_speed_multiplier

	return TRUE


/datum/status_effect/blood_thirst_satiated/on_remove()
	// This status effect should not exist on its own, or on a non-human.
	if(!owner || !ishuman(owner))
		return

	var/obj/item/organ/heart/hemophage/tumor_heart = owner.get_organ_by_type(/obj/item/organ/heart/hemophage)

	if(!tumor_heart)
		return

	tumor_heart.bloodloss_rate /= bloodloss_speed_multiplier


/datum/status_effect/blood_regen_active
	id = "blood_regen_active"
	status_type = STATUS_EFFECT_UNIQUE
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS
	alert_type = /atom/movable/screen/alert/status_effect/blood_regen_active
	/// Current multiplier for how much blood they spend healing themselves for every point of damage healed.
	var/blood_to_health_multiplier = 0.25


/datum/status_effect/blood_regen_active/on_apply()
	// This status effect should not exist on its own, or on a non-human.
	if(!owner || !ishuman(owner))
		return FALSE

	to_chat(owner, span_notice("You feel the tumor inside you pulse faster as the absence of light eases its work, allowing it to knit your flesh and reconstruct your body."))

	return TRUE


// This code also had to be copied over from /datum/action/item_action to ensure that we could display the heart in the alert.
/datum/status_effect/blood_regen_active/on_creation(mob/living/new_owner, ...)
	. = ..()
	if(!.)
		return

	if(!linked_alert)
		return

	var/obj/item/organ/heart/hemophage/tumor_heart = owner.get_organ_by_type(/obj/item/organ/heart/hemophage)
	if(tumor_heart)
		var/old_layer = tumor_heart.layer
		var/old_plane = tumor_heart.plane
		// reset the x & y offset so that item is aligned center
		tumor_heart.pixel_x = 0
		tumor_heart.pixel_y = 0
		tumor_heart.layer = FLOAT_LAYER // They need to be displayed on the proper layer and plane to show up on the button. We elevate them temporarily just to steal their appearance, and then revert it.
		tumor_heart.plane = FLOAT_PLANE
		linked_alert.cut_overlays()
		linked_alert.add_overlay(tumor_heart)
		tumor_heart.layer = old_layer
		tumor_heart.plane = old_plane

	return .


/datum/status_effect/blood_regen_active/on_remove()
	// This status effect should not exist on its own.
	if(!owner)
		return

	to_chat(owner, span_notice("You feel the pulse of the tumor in your chest returning back to normal."))


/datum/status_effect/blood_regen_active/tick(seconds_between_ticks)
	var/mob/living/carbon/human/regenerator = owner

	var/max_blood_for_regen = regenerator.blood_volume - MINIMUM_VOLUME_FOR_REGEN
	var/blood_used = NONE

	var/brutes_to_heal = NONE
	var/brute_damage = regenerator.getBruteLoss()

	// We have to check for the damaged bodyparts like this as well, to account for robotic bodyparts, as we don't want to heal those. Stupid, I know, but that's the best proc we got to check that currently.
	if(brute_damage && length(regenerator.get_damaged_bodyparts(brute = TRUE, burn = FALSE, required_bodytype = BODYTYPE_ORGANIC)))
		brutes_to_heal = min(max_blood_for_regen, min(BLOOD_REGEN_BRUTE_AMOUNT, brute_damage) * seconds_between_ticks)
		blood_used += brutes_to_heal * blood_to_health_multiplier
		max_blood_for_regen -= brutes_to_heal * blood_to_health_multiplier

	var/burns_to_heal = NONE
	var/burn_damage = regenerator.getFireLoss()

	if(burn_damage && max_blood_for_regen > NONE && length(regenerator.get_damaged_bodyparts(brute = FALSE, burn = TRUE, required_bodytype = BODYTYPE_ORGANIC)))
		burns_to_heal = min(max_blood_for_regen, min(BLOOD_REGEN_BURN_AMOUNT, burn_damage) * seconds_between_ticks)
		blood_used += burns_to_heal * blood_to_health_multiplier
		max_blood_for_regen -= burns_to_heal * blood_to_health_multiplier

	if(brutes_to_heal || burns_to_heal)
		regenerator.heal_overall_damage(brutes_to_heal, burns_to_heal, NONE, BODYTYPE_ORGANIC)

	var/toxin_damage = regenerator.getToxLoss()

	if(toxin_damage && max_blood_for_regen > NONE)
		var/toxins_to_heal = min(max_blood_for_regen, min(BLOOD_REGEN_TOXIN_AMOUNT, toxin_damage) * seconds_between_ticks)
		blood_used += toxins_to_heal * blood_to_health_multiplier
		max_blood_for_regen -= toxins_to_heal * blood_to_health_multiplier
		regenerator.adjustToxLoss(-toxins_to_heal)

	if(!blood_used)
		regenerator.remove_status_effect(/datum/status_effect/blood_regen_active)
		return

	regenerator.blood_volume = max(regenerator.blood_volume - blood_used, MINIMUM_VOLUME_FOR_REGEN)


/datum/movespeed_modifier/hemophage_dormant_state
	id = "hemophage_dormant_state"
	multiplicative_slowdown = 2 // Yeah, they'll be quite significantly slower when in their dormant state.
	blacklisted_movetypes = FLOATING|FLYING


/atom/movable/screen/alert/status_effect/blood_thirst_satiated
	name = "Thirst Satiated"
	desc = "Substitutes and taste-thin imitations keep your pale body standing, but nothing abates eternal thirst and slakes the infection quite like the real thing: Hot blood from a real sentient being."
	icon = 'icons/effects/bleed.dmi'
	icon_state = "bleed10"


/atom/movable/screen/alert/status_effect/blood_regen_active
	name = "Enhanced Regeneration"
	desc = "Being in a sufficiently dark location allows your tumor to allocate more energy to enhancing your body's natural regeneration, at the cost of blood volume proportional to the damage healed."
	icon = 'icons/hud/screen_alert.dmi'
	icon_state = "template"


#undef BLOOD_REGEN_BRUTE_AMOUNT
#undef BLOOD_REGEN_BURN_AMOUNT
#undef BLOOD_REGEN_TOXIN_AMOUNT
#undef BLOOD_REGEN_CELLULAR_AMOUNT

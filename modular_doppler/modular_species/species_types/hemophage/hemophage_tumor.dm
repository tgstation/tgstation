/// Minimum amount of light for Hemophages to be considered in pure darkness, and therefore be allowed to heal just like in a closet.
#define MINIMUM_LIGHT_THRESHOLD_FOR_REGEN 0.1

/// How high should the damage multiplier to the Hemophage be when they're in a dormant state?
#define DORMANT_DAMAGE_MULTIPLIER 3
/// By how much the blood drain will be divided when the tumor is in a dormant state.
#define DORMANT_BLOODLOSS_MULTIPLIER 10
/// How much blood do Hemophages normally lose per second (visible effect is every two seconds, so twice this value).
#define NORMAL_BLOOD_DRAIN 0.05

/// Just a conversion factor that ensures there's no weird floating point errors when blood is draining.
#define FLOATING_POINT_ERROR_AVOIDING_FACTOR 1000

/// Trait gained from the pulsating tumor.
#define TRAIT_TUMOR "tumor"


/obj/item/organ/heart/hemophage
	name = "pulsating tumor"
	icon = 'modular_doppler/modular_species/species_types/hemophage/icons/hemophage_organs.dmi'
	icon_state = "tumor-on"
	base_icon_state = "tumor"
	desc = "This pulsating organ nearly resembles a normal heart, but it's been twisted beyond any human appearance, having turned to the color of coal. The way it barely fits where the original organ was sends shivers down your spine... <i>The fact that it's what keeps them alive makes it all the more terrifying.</i>"
	actions_types = list(/datum/action/cooldown/hemophage/toggle_dormant_state)
	/// Are we currently dormant? Defaults to PULSATING_TUMOR_ACTIVE (so FALSE).
	var/is_dormant = PULSATING_TUMOR_ACTIVE
	/// What is the current rate (per second) at which the tumor is consuming blood?
	var/bloodloss_rate = NORMAL_BLOOD_DRAIN
	/// hud element to display our blood level
	var/atom/movable/screen/hemophage/blood/blood_tracker

/obj/item/organ/heart/hemophage/Insert(mob/living/carbon/tumorful, special, movement_flags)
	. = ..()
	if(!. || !owner)
		return

	SEND_SIGNAL(tumorful, COMSIG_PULSATING_TUMOR_ADDED, tumorful)
	tumorful.AddElement(/datum/element/tumor_corruption)
	RegisterSignal(tumorful, COMSIG_MOB_GET_STATUS_TAB_ITEMS, PROC_REF(get_status_tab_item))

/obj/item/organ/heart/hemophage/Remove(mob/living/carbon/tumorless, special = FALSE, movement_flags)
	. = ..()

	SEND_SIGNAL(tumorless, COMSIG_PULSATING_TUMOR_REMOVED, tumorless)
	tumorless.RemoveElement(/datum/element/tumor_corruption)
	tumorless.remove_status_effect(/datum/status_effect/blood_thirst_satiated)
	UnregisterSignal(tumorless, COMSIG_MOB_GET_STATUS_TAB_ITEMS)

	if(!ishuman(tumorless))
		return

	var/mob/living/carbon/human/tumorless_human = tumorless

	// We make sure to account for dormant tumor vulnerabilities, so that we don't achieve states that shouldn't be possible.
	if(is_dormant)
		toggle_dormant_state()
		toggle_dormant_tumor_vulnerabilities(tumorless_human)
		tumorless_human.remove_movespeed_modifier(/datum/movespeed_modifier/hemophage_dormant_state)

	if(tumorless_human.hud_used)
		var/datum/hud/hud_used = tumorless_human.hud_used

		hud_used.infodisplay -= blood_tracker
		QDEL_NULL(blood_tracker)

/obj/item/organ/heart/hemophage/on_life(seconds_per_tick, times_fired)
	. = ..()

	// A Hemophage's tumor will be able to be operated on multiple times, so
	// they are not entirely dependant on Xenobiology when they die more than
	// once.
	// It's intended that you can't print a tumor, because why would you?
	operated = FALSE

	if(blood_tracker)
		blood_tracker.update_blood_hud(owner.blood_volume)
	// create the hud
	else if(owner.hud_used)
		var/datum/hud/hud_used = owner.hud_used
		blood_tracker = new /atom/movable/screen/hemophage/blood(null, hud_used)
		hud_used.infodisplay += blood_tracker

		owner.hud_used.show_hud(owner.hud_used.hud_version)

	if(can_heal_owner_damage())
		owner.apply_status_effect(/datum/status_effect/blood_regen_active)

	else
		owner.remove_status_effect(/datum/status_effect/blood_regen_active)

	if(in_closet(owner)) // No regular bloodloss if you're in a closet
		return

	owner.blood_volume = (owner.blood_volume * FLOATING_POINT_ERROR_AVOIDING_FACTOR - bloodloss_rate * seconds_per_tick * FLOATING_POINT_ERROR_AVOIDING_FACTOR) / FLOATING_POINT_ERROR_AVOIDING_FACTOR

	if(owner.blood_volume <= BLOOD_VOLUME_SURVIVE)
		to_chat(owner, span_danger("You ran out of blood!"))
		owner.investigate_log("starved to death from lack of blood caused by [src].", INVESTIGATE_DEATHS)
		owner.death() // Owch! Ran out of blood.


/// Simple helper proc that toggles the dormant state of the tumor, which also switches its appearance to reflect said change.
/obj/item/organ/heart/hemophage/proc/toggle_dormant_state()
	is_dormant = !is_dormant
	base_icon_state = is_dormant ? "[base_icon_state]-dormant" : initial(base_icon_state)

	bloodloss_rate *= is_dormant ? 1 / DORMANT_BLOODLOSS_MULTIPLIER : DORMANT_BLOODLOSS_MULTIPLIER

	update_appearance()

	if(isnull(owner))
		return

	if(is_dormant)
		owner.add_movespeed_modifier(/datum/movespeed_modifier/hemophage_dormant_state)
		ADD_TRAIT(owner, TRAIT_AGEUSIA, TRAIT_TUMOR)

	else
		owner.remove_movespeed_modifier(/datum/movespeed_modifier/hemophage_dormant_state)
		REMOVE_TRAIT(owner, TRAIT_AGEUSIA, TRAIT_TUMOR)


/// Simple helper proc that returns whether or not the given hemophage is in a closet subtype (but not in any bodybag subtype).
/obj/item/organ/heart/hemophage/proc/in_closet(mob/living/carbon/human/hemophage)
	return istype(hemophage.loc, /obj/structure/closet) && !istype(hemophage.loc, /obj/structure/closet/body_bag)


/// Simple helper proc that returns whether or not the given hemophage is in total darkness.
/obj/item/organ/heart/hemophage/proc/in_total_darkness(mob/living/carbon/human/hemophage)
	var/turf/current_turf = get_turf(hemophage)
	if(!istype(current_turf))
		return FALSE

	return current_turf.get_lumcount() <= MINIMUM_LIGHT_THRESHOLD_FOR_REGEN


/// Whether or not we should be applying the healing status effect for the owner.
/obj/item/organ/heart/hemophage/proc/can_heal_owner_damage()
	// We handle the least expensive checks first.
	if(owner.health >= owner.maxHealth || is_dormant || owner.blood_volume <= MINIMUM_VOLUME_FOR_REGEN || (!in_closet(owner) && !in_total_darkness(owner)))
		return FALSE

	return owner.getBruteLoss() || owner.getFireLoss() || owner.getToxLoss()


/// Simple helper to toggle the hemophage's vulnerability (or lack thereof) based on the status of their tumor.
/// This proc contains no check whatsoever, to avoid redundancy of null checks and such.
/// That being said, it shouldn't be used by anything but the tumor, if you have to call it outside of that, you probably have gone wrong somewhere.
/obj/item/organ/heart/hemophage/proc/toggle_dormant_tumor_vulnerabilities(mob/living/carbon/human/hemophage)
	var/datum/physiology/hemophage_physiology = hemophage.physiology
	var/damage_multiplier = is_dormant ? DORMANT_DAMAGE_MULTIPLIER : 1 / DORMANT_DAMAGE_MULTIPLIER

	hemophage_physiology.brute_mod *= damage_multiplier
	hemophage_physiology.burn_mod *= damage_multiplier
	hemophage_physiology.tox_mod *= damage_multiplier
	hemophage_physiology.stamina_mod *= damage_multiplier / 2 // Doing half here so that they don't instantly hit stam-crit when hit like only once.


/obj/item/organ/heart/hemophage/proc/get_status_tab_item(mob/living/source, list/items)
	SIGNAL_HANDLER
	items += "Current blood level: [owner.blood_volume]/[BLOOD_VOLUME_MAXIMUM]"

#undef MINIMUM_LIGHT_THRESHOLD_FOR_REGEN

#undef FLOATING_POINT_ERROR_AVOIDING_FACTOR

#undef DORMANT_DAMAGE_MULTIPLIER
#undef DORMANT_BLOODLOSS_MULTIPLIER
#undef NORMAL_BLOOD_DRAIN

#undef TRAIT_TUMOR

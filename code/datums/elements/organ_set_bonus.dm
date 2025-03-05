/**
 * organ set bonus element; which makes organs in the same set, all in one person, provide a unique bonus!
 *
 * Used for infused organs!
 */
/datum/element/organ_set_bonus
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Status Effect typepath to instantiate and apply to the mob.
	var/datum/status_effect/organ_set_bonus/bonus_type

/datum/element/organ_set_bonus/Attach(datum/target, bonus_type)
	. = ..()

	if(!isorgan(target))
		return ELEMENT_INCOMPATIBLE
	src.bonus_type = bonus_type
	RegisterSignal(target, COMSIG_ORGAN_IMPLANTED, PROC_REF(on_implanted))
	RegisterSignal(target, COMSIG_ORGAN_REMOVED, PROC_REF(on_removed))

/datum/element/organ_set_bonus/Detach(obj/item/organ/target)
	UnregisterSignal(target, list(COMSIG_ORGAN_IMPLANTED, COMSIG_ORGAN_REMOVED))
	if(target.owner)
		UnregisterSignal(target.owner, COMSIG_ATOM_EXAMINE)
	return ..()

/datum/element/organ_set_bonus/proc/on_implanted(obj/item/organ/target, mob/living/carbon/receiver)
	SIGNAL_HANDLER

	var/datum/status_effect/organ_set_bonus/set_bonus = receiver.has_status_effect(bonus_type)
	if(!set_bonus)
		set_bonus = receiver.apply_status_effect(bonus_type)
	set_bonus.set_organs(set_bonus.organs + 1)

/datum/element/organ_set_bonus/proc/on_removed(obj/item/organ/target, mob/living/carbon/loser)
	SIGNAL_HANDLER

	//get status effect or remove it
	var/datum/status_effect/organ_set_bonus/set_bonus = loser.has_status_effect(bonus_type)
	if(set_bonus)
		set_bonus.set_organs(set_bonus.organs - 1)

/datum/status_effect/organ_set_bonus
	id = "organ_set_bonus"
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = null
	///how many organs the carbon with this has in the set
	var/organs = 0
	///how many organs in the set you need to enable the bonus
	var/organs_needed = 0
	///if the bonus is active
	var/bonus_active = FALSE
	var/bonus_activate_text = span_notice("??? DNA is deeply infused with you! You've learned how to make error reports!")
	var/bonus_deactivate_text = span_notice("Your DNA is no longer majority ???. You did make an issue report, right?")
	/// Required mob bio-type. Also checks DNA validity it's set to MOB_ORGANIC.
	var/required_biotype = MOB_ORGANIC
	/// A list of traits added to the mob upon bonus activation, can be of any length.
	var/list/bonus_traits = list()
	/// Bonus biotype to add on bonus activation.
	var/bonus_biotype
	/// If the biotype was added - used to check if we should remove the biotype or not, on organ set loss.
	var/biotype_added = FALSE
	/// Limb overlay to apply upon activation
	var/limb_overlay
	/// Color priority for limb overlay
	var/color_overlay_priority

/datum/status_effect/organ_set_bonus/proc/set_organs(new_value)
	organs = new_value
	if(!organs) //initial value but won't kick in without calling the setter
		qdel(src)
	if(organs >= organs_needed)
		if(!bonus_active)
			INVOKE_ASYNC(src, PROC_REF(enable_bonus))
	else if(bonus_active)
		INVOKE_ASYNC(src, PROC_REF(disable_bonus))

/datum/status_effect/organ_set_bonus/proc/enable_bonus()
	SHOULD_CALL_PARENT(TRUE)
	if(required_biotype)
		if(!(owner.mob_biotypes & required_biotype))
			return FALSE
		if((required_biotype == MOB_ORGANIC) && !owner.can_mutate())
			return FALSE
	bonus_active = TRUE
	// Add traits
	if(length(bonus_traits))
		owner.add_traits(bonus_traits, TRAIT_STATUS_EFFECT(id))

	// Add biotype
	if(owner.mob_biotypes & bonus_biotype)
		biotype_added = FALSE
	owner.mob_biotypes |= bonus_biotype
	biotype_added = TRUE

	if(bonus_activate_text)
		to_chat(owner, bonus_activate_text)

	// Add limb overlay
	if(!iscarbon(owner) || !limb_overlay)
		return TRUE
	var/mob/living/carbon/carbon_owner = owner
	for(var/obj/item/bodypart/limb in carbon_owner.bodyparts)
		limb.add_bodypart_overlay(new limb_overlay())
		limb.add_color_override(COLOR_WHITE, color_overlay_priority)
	carbon_owner.update_body()
	return TRUE

/datum/status_effect/organ_set_bonus/proc/disable_bonus()
	SHOULD_CALL_PARENT(TRUE)
	bonus_active = FALSE

	// Remove traits
	if(length(bonus_traits))
		owner.remove_traits(bonus_traits, TRAIT_STATUS_EFFECT(id))
	// Remove biotype (if added)
	if(biotype_added)
		owner.mob_biotypes &= ~bonus_biotype

	if(bonus_deactivate_text)
		to_chat(owner, bonus_deactivate_text)

	// Remove limb overlay
	if(!iscarbon(owner) || QDELETED(owner) || !limb_overlay)
		return
	var/mob/living/carbon/carbon_owner = owner
	for(var/obj/item/bodypart/limb in carbon_owner.bodyparts)
		var/overlay = locate(limb_overlay) in limb.bodypart_overlays
		if(overlay)
			limb.remove_bodypart_overlay(overlay)
			limb.remove_color_override(color_overlay_priority)
	carbon_owner.update_body()

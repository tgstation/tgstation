/**
 * organ set bonus element; which makes organs in the same set, all in one person, provide a unique bonus!
 *
 * Used for infused organs!
 */
/datum/element/organ_set_bonus
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///status effect type to apply/update!
	var/bonus_type

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
		UnregisterSignal(target.owner, COMSIG_PARENT_EXAMINE)
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
	duration = -1
	tick_interval = -1
	alert_type = null
	///how many organs the carbon with this has in the set
	var/organs = 0
	///how many organs in the set you need to enable the bonus
	var/organs_needed = 5
	///if the bonus is active
	var/bonus_active = FALSE
	var/bonus_activate_text = span_notice("??? DNA is deeply infused with you! You've learned how to make error reports!")
	var/bonus_deactivate_text = span_notice("Your DNA is no longer majority ???. You did make an issue report, right?")

/datum/status_effect/organ_set_bonus/proc/set_organs(new_value)
	organs = new_value
	if(!organs) //initial value but won't kick in without calling the setter
		qdel(src)
	if(organs >= organs_needed)
		if(!bonus_active)
			enable_bonus()
	else if(bonus_active)
		disable_bonus()

/datum/status_effect/organ_set_bonus/proc/enable_bonus()
	SHOULD_CALL_PARENT(TRUE)
	bonus_active = TRUE
	if(bonus_activate_text)
		to_chat(owner, bonus_activate_text)

/datum/status_effect/organ_set_bonus/proc/disable_bonus()
	SHOULD_CALL_PARENT(TRUE)
	bonus_active = FALSE
	if(bonus_deactivate_text)
		to_chat(owner, bonus_deactivate_text)

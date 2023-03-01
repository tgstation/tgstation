// NOTE: All Targeted spells are Toggles! We just don't bother checking here.
/datum/action/bloodsucker/targeted
	power_flags = BP_AM_TOGGLE

	var/obj/effect/proc_holder/bloodsucker/bs_proc_holder
	var/target_range = 99
	var/prefire_message = ""
	///Most powers happen the moment you click. Some, like Mesmerize, require time and shouldn't cost you if they fail.
	var/power_activates_immediately = TRUE
	///Is this power LOCKED due to being used?
	var/power_in_use = FALSE

/// Modify description to add notice that this is aimed.
/datum/action/bloodsucker/targeted/New(Target)
	desc += "<br>\[<i>Targeted Power</i>\]"
	. = ..()
	// Create Proc Holder for intercepting clicks
	bs_proc_holder = new()
	bs_proc_holder.linked_power = src

/datum/action/bloodsucker/targeted/Trigger(trigger_flags)
	if(active && CheckCanDeactivate())
		DeactivatePower()
		return FALSE
	if(!CheckCanPayCost(owner) || !CheckCanUse(owner))
		return FALSE

	ActivatePower()
	UpdateButtonIcon()
	// Create & Link Targeting Proc
	var/mob/living/user = owner
	if(user.ranged_ability)
		user.ranged_ability.remove_ranged_ability()
	bs_proc_holder.add_ranged_ability(user)
	if(prefire_message != "")
		to_chat(owner, span_announce("[prefire_message]"))
	return TRUE

/datum/action/bloodsucker/targeted/DeactivatePower()
	if(power_flags & BP_AM_TOGGLE)
		UnregisterSignal(owner, COMSIG_LIVING_BIOLOGICAL_LIFE)
	active = FALSE
	DeactivateRangedAbility()
	UpdateButtonIcon()
//	..() // we don't want to pay cost here

/// Only Turned off when CLICK is disabled...aka, when you successfully clicked
/datum/action/bloodsucker/targeted/proc/DeactivateRangedAbility()
	bs_proc_holder.remove_ranged_ability()

/// Check if target is VALID (wall, turf, or character?)
/datum/action/bloodsucker/targeted/proc/CheckValidTarget(atom/target_atom)
	if(target_atom == owner)
		return FALSE
	return TRUE

/// Check if valid target meets conditions
/datum/action/bloodsucker/targeted/proc/CheckCanTarget(atom/target_atom)
	// Out of Range
	if(!(target_atom in view(target_range, owner)))
		if(target_range > 1) // Only warn for range if it's greater than 1. Brawn doesn't need to announce itself.
			to_chat(owner, "Target out of range.")
		return FALSE
	return istype(target_atom)

/// Click Target
/datum/action/bloodsucker/targeted/proc/ClickWithPower(atom/target_atom)
	// CANCEL RANGED TARGET check
	if(power_in_use || !CheckValidTarget(target_atom))
		return FALSE
	// Valid? (return true means DON'T cancel power!)
	if(!CheckCanPayCost() || !CheckCanUse(owner) || !CheckCanTarget(target_atom))
		return TRUE
	power_in_use = TRUE // Lock us into this ability until it successfully fires off. Otherwise, we pay the blood even if we fail.
	FireTargetedPower(target_atom) // We use this instead of ActivatePower(), which has no input
	// Skip this part so we can return TRUE right away.
	if(power_activates_immediately)
		PowerActivatedSuccessfully() // Mesmerize pays only after success.
	power_in_use = FALSE
	return TRUE

/// Like ActivatePower, but specific to Targeted (and takes an atom input). We don't use ActivatePower for targeted.
/datum/action/bloodsucker/targeted/proc/FireTargetedPower(atom/target_atom)
	log_combat(owner, target_atom, "used [name] on")

/// The power went off! We now pay the cost of the power.
/datum/action/bloodsucker/targeted/proc/PowerActivatedSuccessfully()
	PayCost()
	DeactivatePower()
	StartCooldown()	// Do AFTER UpdateIcon() inside of DeactivatePower. Otherwise icon just gets wiped.

/// Target Proc Holder
/obj/effect/proc_holder/bloodsucker
	///The linked Bloodsucker power
	var/datum/action/bloodsucker/targeted/linked_power

/obj/effect/proc_holder/bloodsucker/InterceptClickOn(mob/living/caller, params, atom/targeted_atom)
	return linked_power.ClickWithPower(targeted_atom)

/// How long it takes for an organ to be corrupted by default.
#define BASE_TIME_BEFORE_CORRUPTION 60 SECONDS
/// The generic corrupted organ color.
#define GENERIC_CORRUPTED_ORGAN_COLOR "#333333"
/// How much organ damage do all corrupted organs take per second when the tumor is removed?
/// This will go by MUCH faster than you might expect, don't set it up too high.
#define CORRUPTED_ORGAN_DAMAGE_TUMORLESS 0.5

/// Component for Hemophage tumor-induced organ corruption, for the organs
/// that need to receive the `ORGAN_TUMOR_CORRUPTED` flag, to corrupt
/// them properly.
/datum/component/organ_corruption
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// The type of organ affected by this specific type of organ corruption.
	var/corruptable_organ_type = /obj/item/organ
	/// If this type of organ has a unique sprite for what its corrupted
	/// version should look like, this will be the icon file it will be pulled
	/// from.
	var/corrupted_icon = 'modular_doppler/modular_species/species_types/hemophage/icons/hemophage_organs.dmi'
	/// If this type of organ has a unique sprite for what its corrupted
	/// version should look like, this will be the icon state it will be pulled
	/// from.
	var/corrupted_icon_state = null
	/// The timer associated with the corruption process, if any.
	var/corruption_timer_id = null
	/// The prefix added to the organ once it is successfully corrupted.
	var/corrupted_prefix = "corrupted"
	/// Whether this organ is tumorless and therefore should be taking damage.
	/// Note: This variable isn't there to handle the behavior, and is only there
	/// to prevent organs taking damage when tumors are being swapped around between
	/// multiple people, somehow.
	VAR_PROTECTED/currently_tumorless = FALSE


/datum/component/organ_corruption/Initialize(time_to_corrupt = BASE_TIME_BEFORE_CORRUPTION)
	if(!istype(parent, corruptable_organ_type))
		return COMPONENT_INCOMPATIBLE

	if(time_to_corrupt <= 0)
		corrupt_organ(parent)
		return

	corruption_timer_id = addtimer(CALLBACK(src, PROC_REF(corrupt_organ), parent), time_to_corrupt, TIMER_STOPPABLE)


/datum/component/organ_corruption/RegisterWithParent()
	if(corruption_timer_id)
		RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(clear_corruption_timer))
		RegisterSignal(parent, COMSIG_ORGAN_REMOVED, PROC_REF(clear_corruption_timer))


/datum/component/organ_corruption/UnregisterFromParent()
	. = ..()

	UnregisterSignal(parent, list(COMSIG_ORGAN_IMPLANTED, COMSIG_ORGAN_REMOVED))

	var/obj/item/organ/parent_organ = parent
	if(istype(parent_organ) && parent_organ.owner)
		UnregisterSignal(parent_organ.owner)

	clear_corruption_timer()


/// Handles clearing the timer for corrupting an organ if the organ is `QDELETING`.
/datum/component/organ_corruption/proc/clear_corruption_timer()
	SIGNAL_HANDLER

	if(corruption_timer_id)
		deltimer(corruption_timer_id)

	UnregisterSignal(parent, list(COMSIG_QDELETING, COMSIG_ORGAN_REMOVED))


/**
 * Handles corrupting the organ, adding any sort of behavior on it as needed.
 *
 * Arguments:
 * * corruption_target - The organ that will get corrupted.
 */
/datum/component/organ_corruption/proc/corrupt_organ(obj/item/organ/corruption_target)
	SHOULD_CALL_PARENT(TRUE)
	if(!corruption_target)
		return FALSE

	corruption_timer_id = null
	corruption_target.organ_flags |= ORGAN_TUMOR_CORRUPTED
	corruption_target.name = "[corrupted_prefix] [corruption_target.name]"

	if(corrupted_icon_state && corrupted_icon)
		corruption_target.icon = corrupted_icon
		corruption_target.icon_state = corrupted_icon_state
		corruption_target.update_appearance()

	else
		corruption_target.color = GENERIC_CORRUPTED_ORGAN_COLOR

	RegisterSignal(corruption_target, COMSIG_ORGAN_IMPLANTED, PROC_REF(register_signals_on_organ_owner))
	RegisterSignal(corruption_target, COMSIG_ORGAN_REMOVED, PROC_REF(unregister_signals_from_organ_loser), override = TRUE)

	return TRUE


/// Returns whether or not the attached organ has been corrupted yet or not.
/// Fancy wrapper for just `!corruption_timer_id`.
/datum/component/organ_corruption/proc/organ_is_corrupted()
	return !corruption_timer_id


/**
 * Handles registering signals on the (new) organ owner, if it was to ever be
 * taken out and put into someone else.
 */
/datum/component/organ_corruption/proc/register_signals_on_organ_owner(obj/item/organ/implanted_organ, mob/living/carbon/receiver)
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE)

	if(implanted_organ != parent)
		return FALSE

	RegisterSignal(receiver, COMSIG_PULSATING_TUMOR_REMOVED, PROC_REF(on_tumor_removed), override = TRUE)
	UnregisterSignal(receiver, list(COMSIG_PULSATING_TUMOR_ADDED, COMSIG_LIVING_LIFE)) // In case there's a tumor transplant between Hemophages.

	return TRUE


/**
 * Handles unregistering the signals that were registered on the `loser` from
 * having this organ in their body.
 */
/datum/component/organ_corruption/proc/unregister_signals_from_organ_loser(obj/item/organ/target, mob/living/carbon/loser)
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE)

	if(target != parent)
		return FALSE

	UnregisterSignal(loser, COMSIG_LIVING_LIFE)

	if(organ_is_corrupted())
		RegisterSignal(loser, COMSIG_PULSATING_TUMOR_ADDED, PROC_REF(on_tumor_reinserted), override = TRUE)

	return TRUE


/**
 * Handles either deleting the corruption in case the organ didn't get corrupted
 * yet, or starting the process of the organ degrading because the tumor isn't
 * there to sustain it anymore.
 */
/datum/component/organ_corruption/proc/on_tumor_removed(mob/living/carbon/tumorless)
	SIGNAL_HANDLER

	if(organ_is_corrupted())
		RegisterSignal(tumorless, COMSIG_LIVING_LIFE, PROC_REF(decay_corrupted_organ))
		currently_tumorless = TRUE
		return

	qdel(src)


/datum/component/organ_corruption/proc/on_tumor_reinserted(mob/living/carbon/tumorful)
	SIGNAL_HANDLER

	UnregisterSignal(tumorful, COMSIG_LIVING_LIFE)
	currently_tumorless = FALSE


/**
 * Handles damaging the corrupted organ when the tumor is no longer present in the body.
 */
/datum/component/organ_corruption/proc/decay_corrupted_organ(mob/living/carbon/tumorless, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	var/obj/item/organ/corrupted_organ = parent

	if(!currently_tumorless && corrupted_organ.owner)
		UnregisterSignal(corrupted_organ.owner, COMSIG_LIVING_LIFE)

	corrupted_organ.apply_organ_damage(CORRUPTED_ORGAN_DAMAGE_TUMORLESS * seconds_per_tick, required_organ_flag = ORGAN_TUMOR_CORRUPTED)

	if(corrupted_organ.organ_flags & ORGAN_FAILING && corrupted_organ.owner)
		UnregisterSignal(corrupted_organ.owner, COMSIG_LIVING_LIFE)



#undef BASE_TIME_BEFORE_CORRUPTION
#undef GENERIC_CORRUPTED_ORGAN_COLOR
#undef CORRUPTED_ORGAN_DAMAGE_TUMORLESS

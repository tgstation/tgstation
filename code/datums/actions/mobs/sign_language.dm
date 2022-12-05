/**
 * Allows a Carbon to toggle sign language on/off. The button is invisible for mute Carbons.
 * Theory of Operation:
 * A. If TRAIT_SIGN_LANG is added/removed, and the button is visible, then update the button.
 * B. React to presence of trait TRAIT_MUTE for quality/convenience purposes:
 * C. If TRAIT_MUTE is added, then activate and hide the Action.
 * D. If TRAIT_MUTE is then removed, then show the Action.
 *
 * * Credits:
 * - Action sprite created by @Wallemations (icons/hud/actions.dmi:sign_language)
*/
/datum/action/innate/sign_language
	name = "Sign Language"
	button_icon = 'icons/hud/actions.dmi'
	button_icon_state = "sign_language"
	desc = "Allows you to communicate via sign language."
	owner_has_control = FALSE

/datum/action/innate/sign_language/is_action_active(atom/movable/screen/movable/action_button/current_button)
	return HAS_TRAIT(owner, TRAIT_SIGN_LANG)

/datum/action/innate/sign_language/Grant(mob/living/carbon/grant_to)
	. = ..()
	if(!owner)
		return

	if (HAS_TRAIT(grant_to, TRAIT_MUTE))
		RegisterSignal(grant_to, SIGNAL_REMOVETRAIT(TRAIT_MUTE), PROC_REF(on_unmuted))
		// Convenience. Mute Carbons can only speak with sign language.
		if (!active)
			Activate()
	else
		RegisterSignal(grant_to, SIGNAL_ADDTRAIT(TRAIT_MUTE), PROC_REF(on_muted))
		// Convenience. Only display action if the Carbon isn't mute.
		show_action()

/datum/action/innate/sign_language/Remove(mob/living/carbon/grant_to)
	. = ..()
	UnregisterSignal(grant_to, list(
		SIGNAL_ADDTRAIT(TRAIT_SIGN_LANG),
		SIGNAL_REMOVETRAIT(TRAIT_SIGN_LANG),
		SIGNAL_ADDTRAIT(TRAIT_MUTE),
		SIGNAL_REMOVETRAIT(TRAIT_MUTE)
	))
	REMOVE_TRAIT(grant_to, TRAIT_SIGN_LANG, TRAIT_GENERIC)

/datum/action/innate/sign_language/Activate()
	active = TRUE
	ADD_TRAIT(owner, TRAIT_SIGN_LANG, TRAIT_GENERIC)
	to_chat(owner, span_green("You are now communicating with sign language."))

/datum/action/innate/sign_language/Deactivate()
	active = FALSE
	REMOVE_TRAIT(owner, TRAIT_SIGN_LANG, TRAIT_GENERIC)
	to_chat(owner, span_green("You have stopped using sign language."))

/// Shows the linked action to the owner Carbon.
/datum/action/innate/sign_language/proc/show_action()
	owner_has_control = TRUE
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_SIGN_LANG), PROC_REF(update_status_on_signal))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_SIGN_LANG), PROC_REF(update_status_on_signal))
	GiveAction(owner)

/// Hides the linked action from the owner Carbon.
/datum/action/innate/sign_language/proc/hide_action()
	owner_has_control = FALSE
	UnregisterSignal(owner, list(
		SIGNAL_ADDTRAIT(TRAIT_SIGN_LANG),
		SIGNAL_REMOVETRAIT(TRAIT_SIGN_LANG)
	))
	HideFrom(owner)

/// Signal handler for SIGNAL_ADDTRAIT(TRAIT_MUTE)
/// Hides the action if the signing Carbon gains TRAIT_MUTE.
/datum/action/innate/sign_language/proc/on_muted()
	SIGNAL_HANDLER

	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_MUTE), PROC_REF(on_unmuted))
	hide_action()
	// Enable sign language if the Carbon knows it and just gained TRAIT_MUTE
	if (!HAS_TRAIT(owner, TRAIT_SIGN_LANG))
		Activate()

/// Signal handler for SIGNAL_REMOVETRAIT(TRAIT_MUTE)
/// Re-shows the action if the signing Carbon loses TRAIT_MUTE.
/datum/action/innate/sign_language/proc/on_unmuted()
	SIGNAL_HANDLER

	show_action()

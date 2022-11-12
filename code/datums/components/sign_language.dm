/// Defines used to determine whether a sign language user can sign or not, and if not, why they cannot.
#define SIGN_OKAY 0
#define SIGN_ONE_HAND 1
#define SIGN_HANDS_FULL 2
#define SIGN_ARMLESS 3
#define SIGN_ARMS_DISABLED 4
#define SIGN_TRAIT_BLOCKED 5
#define SIGN_CUFFED 6

/// Sign Language component for Carbons. Adds a button to the HUD which toggles.
/datum/component/sign_language
	/// The tonal indicator shown when sign language users finish sending a message. If it's empty, none appears.
	var/tonal_indicator = null
	/// The timerid for our sign language tonal indicator.
	var/tonal_timerid
	/// The action for toggling sign language.
	var/datum/action/innate/sign_language/linked_action

/datum/component/sign_language/Initialize()
	// Non-Carbon mobs can't use sign language.
	linked_action = new /datum/action/innate/sign_language(src)
	if (!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE

/// Signal proc for [COMSIG_SIGNLANGUAGE_REMOVE]
/// A convenient shortcut for removing the component.
/// The qdel here eventually calls Destroy() and UnregisterFromParent()
/datum/component/sign_language/proc/qdel_self()
	SIGNAL_HANDLER

	qdel(src)

/datum/component/sign_language/RegisterWithParent()
	// Sign language Action is granted/removed via adding/removing TRAIT_CAN_SIGN_LANG.
	RegisterSignal(parent, SIGNAL_ADDTRAIT(TRAIT_CAN_SIGN_LANG), .proc/learn_sign_language)
	RegisterSignal(parent, SIGNAL_REMOVETRAIT(TRAIT_CAN_SIGN_LANG), .proc/forget_sign_language)
	// Sign language is toggled on/off via adding/removing TRAIT_SIGN_LANG.
	RegisterSignal(parent, SIGNAL_ADDTRAIT(TRAIT_SIGN_LANG), .proc/enable_sign_language)
	RegisterSignal(parent, SIGNAL_REMOVETRAIT(TRAIT_SIGN_LANG), .proc/disable_sign_language)

/// Deletes the sign language action and disables signing.
/datum/component/sign_language/UnregisterFromParent()
	disable_sign_language()
	if (linked_action.owner)
		linked_action.Remove(parent)
	UnregisterSignal(parent, list(
		SIGNAL_ADDTRAIT(TRAIT_CAN_SIGN_LANG),
		SIGNAL_REMOVETRAIT(TRAIT_CAN_SIGN_LANG),
		SIGNAL_ADDTRAIT(TRAIT_SIGN_LANG),
		SIGNAL_REMOVETRAIT(TRAIT_SIGN_LANG),
		SIGNAL_ADDTRAIT(TRAIT_MUTE),
		SIGNAL_REMOVETRAIT(TRAIT_MUTE)
	))

/// Signal handler for [removetrait mute]
/// Adds the linked toggle action to the parent Carbon.
/datum/component/sign_language/proc/learn_sign_language()
	SIGNAL_HANDLER

	ADD_TRAIT(parent, TRAIT_CAN_SIGN_LANG, TRAIT_GENERIC)
	// Enable by default if the Carbon has TRAIT_MUTE, for convenience.
	if (HAS_TRAIT(parent, TRAIT_MUTE))
		ADD_TRAIT(parent, TRAIT_SIGN_LANG, TRAIT_GENERIC)
	else
		// Only allow toggling if the Carbon does NOT have TRAIT_MUTE.
		add_action()

/// Signal handler for [addtrait mute]
/// Removes the linked toggle action from the parent Carbon.
/datum/component/sign_language/proc/forget_sign_language()
	SIGNAL_HANDLER

	REMOVE_TRAIT(parent, TRAIT_CAN_SIGN_LANG, TRAIT_GENERIC)
	remove_action()

/// Adds the linked toggle action to the parent Carbon.
/datum/component/sign_language/proc/add_action()
		SIGNAL_HANDLER
		linked_action.Grant(parent)
		// Removes the toggle action if the Carbon gains TRAIT_MUTE.
		RegisterSignal(parent, SIGNAL_ADDTRAIT(TRAIT_MUTE), .proc/remove_action)

/// Removes the linked toggle action from the parent Carbon.
/datum/component/sign_language/proc/remove_action()
	SIGNAL_HANDLER

	linked_action.Remove(parent)
	if (HAS_TRAIT(parent, TRAIT_CAN_SIGN_LANG) && HAS_TRAIT(parent, TRAIT_MUTE))
		// Enable sign language if the Carbon knows it and just gained TRAIT_MUTE
		ADD_TRAIT(parent, TRAIT_SIGN_LANG, TRAIT_GENERIC)
		// Re-adds the toggle action if the signing Carbon loses TRAIT_MUTE.
		RegisterSignal(parent, SIGNAL_REMOVETRAIT(TRAIT_MUTE), .proc/add_action)

/// Innate Action which allows a Carbon to toggle sign language on/off.
/datum/action/innate/sign_language
	name = "Sign Language"
	icon_icon = 'icons/obj/fluff.dmi'
	button_icon_state = "painting3"
	desc = "Allows you to communicate via sign language."

/datum/action/innate/sign_language/Activate()
	ADD_TRAIT(owner, TRAIT_SIGN_LANG, TRAIT_GENERIC)
	to_chat(owner, span_green("You are now communicating with sign language."))
	active = TRUE
	UpdateButtons()

/datum/action/innate/sign_language/Deactivate()
	REMOVE_TRAIT(owner, TRAIT_SIGN_LANG, TRAIT_GENERIC)
	to_chat(owner, span_green("You have stopped using sign language."))
	active = FALSE
	UpdateButtons()

/datum/action/innate/sign_language/UpdateButton(atom/movable/screen/movable/action_button/button, status_only = FALSE, force)
	. = ..()
	if(!. || !button) // no button available
		return
	if(HAS_TRAIT(owner, TRAIT_SIGN_LANG))
		button.icon_state = "template_active"
	else
		button.icon_state = "template"

/// Signal handler for [COMSIG_SIGNLANGUAGE_ENABLE]
/// Enables signing for the parent Carbon, stopping them from speaking vocally.
/// This proc is only called directly after TRAIT_SIGN_LANG is added to the Carbon.
/datum/component/sign_language/proc/enable_sign_language()
	SIGNAL_HANDLER

	var/mob/living/carbon/carbon_parent = parent
	carbon_parent.dna?.species.say_mod = "signs"
	carbon_parent.verb_ask = "signs"
	carbon_parent.verb_exclaim = "signs"
	carbon_parent.verb_whisper = "subtly signs"
	carbon_parent.verb_sing = "rythmically signs"
	carbon_parent.verb_yell = "emphatically signs"
	carbon_parent.bubble_icon = "signlang"
	RegisterSignal(carbon_parent, COMSIG_LIVING_TRY_SPEECH, .proc/on_try_speech)
	RegisterSignal(carbon_parent, COMSIG_LIVING_TREAT_MESSAGE, .proc/on_treat_living_message)
	RegisterSignal(carbon_parent, COMSIG_MOVABLE_TREAT_MESSAGE, .proc/on_treat_message)
	RegisterSignal(carbon_parent, COMSIG_MOVABLE_USING_RADIO, .proc/on_using_radio)
	RegisterSignal(carbon_parent, COMSIG_MOVABLE_SAY_QUOTE, .proc/on_say_quote)
	RegisterSignal(carbon_parent, COMSIG_MOB_SAY, .proc/on_say)
	return TRUE

/// Signal handler for [COMSIG_SIGNLANGUAGE_DISABLE]
/// Disables signing for the parent Carbon, allowing them to speak vocally.
/// This proc is only called directly after TRAIT_SIGN_LANG is removed from the Carbon.
/datum/component/sign_language/proc/disable_sign_language()
	SIGNAL_HANDLER

	var/mob/living/carbon/carbon_parent = parent
	carbon_parent.dna?.species.say_mod = initial(carbon_parent.dna.species.say_mod)
	carbon_parent.verb_ask = initial(carbon_parent.verb_ask)
	carbon_parent.verb_exclaim = initial(carbon_parent.verb_exclaim)
	carbon_parent.verb_whisper = initial(carbon_parent.verb_whisper)
	carbon_parent.verb_sing = initial(carbon_parent.verb_sing)
	carbon_parent.verb_yell = initial(carbon_parent.verb_yell)
	carbon_parent.bubble_icon = initial(carbon_parent.bubble_icon)
	UnregisterSignal(carbon_parent, list(
		COMSIG_LIVING_TRY_SPEECH,
		COMSIG_LIVING_TREAT_MESSAGE,
		COMSIG_MOVABLE_TREAT_MESSAGE,
		COMSIG_MOVABLE_USING_RADIO,
		COMSIG_MOVABLE_SAY_QUOTE,
		COMSIG_MOB_SAY
	))
	return TRUE

/// Signal proc for [COMSIG_LIVING_TRY_SPEECH]
/// Sign languagers can always speak regardless of they're mute (as long as they're not mimes)
/datum/component/sign_language/proc/on_try_speech(mob/living/source, message, ignore_spam, forced)
	SIGNAL_HANDLER

	var/mob/living/carbon/carbon_parent = parent
	if(carbon_parent.mind?.miming)
		to_chat(carbon_parent, span_green("You stop yourself from signing in favor of the artform of mimery!"))
		return COMPONENT_CANNOT_SPEAK

	switch(check_signables_state())
		if(SIGN_HANDS_FULL) // Full hands
			carbon_parent.visible_message("tries to sign, but can't with [carbon_parent.p_their()] hands full!", visible_message_flags = EMOTE_MESSAGE)
			return COMPONENT_CANNOT_SPEAK

		if(SIGN_CUFFED) // Restrained
			carbon_parent.visible_message("tries to sign, but can't with [carbon_parent.p_their()] hands bound!", visible_message_flags = EMOTE_MESSAGE)
			return COMPONENT_CANNOT_SPEAK

		if(SIGN_ARMLESS) // No arms
			to_chat(carbon_parent, span_warning("You can't sign with no hands!"))
			return COMPONENT_CANNOT_SPEAK

		if(SIGN_ARMS_DISABLED) // Arms but they're disabled
			to_chat(carbon_parent, span_warning("You can't sign with your hands right now!"))
			return COMPONENT_CANNOT_SPEAK

		if(SIGN_TRAIT_BLOCKED) // Hands blocked or emote mute
			to_chat(carbon_parent, span_warning("You can't sign at the moment!"))
			return COMPONENT_CANNOT_SPEAK

	// Assuming none of the above fail, sign language users can speak
	// regardless of being muzzled or mute toxin'd or whatever.
	return COMPONENT_CAN_ALWAYS_SPEAK

/// Checks to see what state this person is in and if they are able to sign or not.
/datum/component/sign_language/proc/check_signables_state()
	var/mob/living/carbon/carbon_parent = parent
	// See how many hands we can actually use (this counts disabled / missing limbs for us)
	var/total_hands = carbon_parent.usable_hands
	// Look ma, no hands!
	if(total_hands <= 0)
		// Either our hands are still attached (just disabled) or they're gone entirely
		return carbon_parent.num_hands > 0 ? SIGN_ARMS_DISABLED : SIGN_ARMLESS

	// Now let's see how many of our hands is holding something
	var/busy_hands = 0
	// Yes held_items can contain null values, which represents empty hands,
	// I'm just saving myself a variable cast by using as anything
	for(var/obj/item/held_item as anything in carbon_parent.held_items)
		// items like slappers/zombie claws/etc. should be ignored
		if(isnull(held_item) || held_item.item_flags & HAND_ITEM)
			continue

		busy_hands++

	// Handcuffed or otherwise restrained - can't talk
	if(HAS_TRAIT(src, TRAIT_RESTRAINED))
		return SIGN_CUFFED
	// Some other trait preventing us from using our hands now
	else if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED) || HAS_TRAIT(src, TRAIT_EMOTEMUTE))
		return SIGN_TRAIT_BLOCKED

	// Okay let's compare the total hands to the number of busy hands
	// to see how many we have left to use for signing right now
	var/actually_usable_hands = total_hands - busy_hands
	if(actually_usable_hands <= 0)
		return SIGN_HANDS_FULL
	if(actually_usable_hands == 1)
		return SIGN_ONE_HAND

	return SIGN_OKAY

/datum/component/sign_language/proc/sanitize_message(input)
	return replacetext(replacetext(input, "!", "."), "?", ".")

/// Signal proc for [COMSIG_LIVING_TREAT_MESSAGE]
/// Stars out our message if we only have 1 hand free.
/datum/component/sign_language/proc/on_treat_living_message(atom/movable/source, list/message_args)
	SIGNAL_HANDLER

	if(check_signables_state() == SIGN_ONE_HAND)
		message_args[TREAT_MESSAGE_MESSAGE] = stars(message_args[TREAT_MESSAGE_MESSAGE])

/// Signal proc for [COMSIG_MOVABLE_SAY_QUOTE]
/// Removes exclamation/question marks.
/datum/component/sign_language/proc/on_say_quote(atom/movable/source, list/message_args)
	SIGNAL_HANDLER

	message_args[MOVABLE_SAY_QUOTE_MESSAGE] = sanitize_message(message_args[MOVABLE_SAY_QUOTE_MESSAGE])

/// Signal proc for [COMSIG_MOVABLE_TREAT_MESSAGE]
/// Removes exclamation/question marks if /atom/movable/proc/say_quote() isn't going to run.
/datum/component/sign_language/proc/on_treat_message(atom/movable/source, list/message_args)
	SIGNAL_HANDLER

	if (message_args[MOVABLE_TREAT_MESSAGE_NOQUOTE])
		message_args[MOVABLE_TREAT_MESSAGE_MESSAGE] = sanitize_message(message_args[MOVABLE_TREAT_MESSAGE_MESSAGE])

/// Signal proc for [COMSIG_MOVABLE_USING_RADIO]
/// Disallows us from speaking on comms if we don't have the special trait.
/// Being unable to sign, or having our message be starred out, is handled by the above two signal procs.
/datum/component/sign_language/proc/on_using_radio(atom/movable/source, obj/item/radio/radio)
	SIGNAL_HANDLER

	return HAS_TRAIT(source, TRAIT_CAN_SIGN_ON_COMMS) ? NONE : COMPONENT_CANNOT_USE_RADIO

/// Replaces emphatic punctuation with periods. Changes tonal indicator and emotes eyebrow movement based on what is typed.
/datum/component/sign_language/proc/on_say(mob/living/carbon/carbon_parent, list/speech_args)
	SIGNAL_HANDLER

	// The original message
	var/message = speech_args[SPEECH_MESSAGE]
	// Is there a !
	var/exclamation_found = findtext(message, "!")
	// Is there a ?
	var/question_found = findtext(message, "?")

	// Cut our last overlay before we replace it
	if(timeleft(tonal_timerid) > 0)
		remove_tonal_indicator()
		deltimer(tonal_timerid)
	// Prioritize questions
	if(question_found)
		tonal_indicator = mutable_appearance('icons/mob/effects/talk.dmi', "signlang1", TYPING_LAYER)
		carbon_parent.visible_message(span_notice("[carbon_parent] lowers [carbon_parent.p_their()] eyebrows."))
	else if(exclamation_found)
		tonal_indicator = mutable_appearance('icons/mob/effects/talk.dmi', "signlang2", TYPING_LAYER)
		carbon_parent.visible_message(span_notice("[carbon_parent] raises [carbon_parent.p_their()] eyebrows."))
	// If either an exclamation or question are found
	if(!isnull(tonal_indicator) && carbon_parent.client?.typing_indicators)
		carbon_parent.add_overlay(tonal_indicator)
		tonal_timerid = addtimer(CALLBACK(src, .proc/remove_tonal_indicator), 2.5 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE | TIMER_DELETE_ME)
	else // If we're not gonna use it, just be sure we get rid of it
		tonal_indicator = null

/// Removes the tonal indicator overlay completely
/datum/component/sign_language/proc/remove_tonal_indicator()
	if(isnull(tonal_indicator))
		return
	var/mob/living/carbon/carbon_parent = parent
	carbon_parent.cut_overlay(tonal_indicator)
	tonal_indicator = null

#undef SIGN_OKAY
#undef SIGN_ONE_HAND
#undef SIGN_HANDS_FULL
#undef SIGN_ARMLESS
#undef SIGN_ARMS_DISABLED
#undef SIGN_TRAIT_BLOCKED
#undef SIGN_CUFFED

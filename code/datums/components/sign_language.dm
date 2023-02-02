/// Defines used to determine whether a sign language user can sign or not, and if not, why they cannot.
#define SIGN_OKAY 0
#define SIGN_ONE_HAND 1
#define SIGN_HANDS_FULL 2
#define SIGN_ARMLESS 3
#define SIGN_ARMS_DISABLED 4
#define SIGN_TRAIT_BLOCKED 5
#define SIGN_CUFFED 6

/**
* Reactive Sign Language Component for Carbons. Allows Carbons to speak with sign language if they have the relevant traits.
* Implements sign language by incrementally overriding several critical functions, variables, and argument lists.
*
* High-Level Theory of Operation:
*  1. Component is added to a Carbon via AddComponent.
*  2. Component grants sign language action to its parent, which adds and removes TRAIT_SIGN_LANG.
*  3. Component reacts to addition and removal of TRAIT_SIGN_LANG in parent:
*  4. If TRAIT_SIGN_LANG is added, then enable sign language. Listen for speech signals and modify the mob's speech, say_mod verbs, and typing indicator.
*  5. If TRAIT_SIGN_LANG is removed, then disable sign language. Unregister from speech signals and reset the mob's speech, say_mob verbs, and typing indicator.
*
* * Credits:
* - Original Tongue Tied created by @Wallemations (https://github.com/tgstation/tgstation/pull/52907)
* - Action sprite created by @Wallemations (icons/hud/actions.dmi:sign_language)
*/
/datum/component/sign_language
	/// The tonal indicator shown when sign language users finish sending a message. If it's empty, none appears.
	var/tonal_indicator = null
	/// The timerid for our sign language tonal indicator.
	var/tonal_timerid
	/// Any symbols to sanitize from signed messages.
	var/regex/omissions = new ("\[!?\]", "g")
	/// The action for toggling sign language.
	var/datum/action/innate/sign_language/linked_action

/// Replace specific characters in the input string with periods.
/datum/component/sign_language/proc/sanitize_message(input)
	return replacetext(input, omissions, ".")

/datum/component/sign_language/Initialize()
	// Non-Carbon mobs can't use sign language.
	if (!iscarbon(parent))
		stack_trace("Sign Language component added to [parent] ([parent?.type]) which is not a /mob/living/carbon subtype.")
		return COMPONENT_INCOMPATIBLE
	linked_action = new(src)

/datum/component/sign_language/Destroy()
	QDEL_NULL(linked_action)
	return ..()

/datum/component/sign_language/RegisterWithParent()
	// Sign language is toggled on/off via adding/removing TRAIT_SIGN_LANG.
	RegisterSignal(parent, SIGNAL_ADDTRAIT(TRAIT_SIGN_LANG), PROC_REF(enable_sign_language))
	RegisterSignal(parent, SIGNAL_REMOVETRAIT(TRAIT_SIGN_LANG), PROC_REF(disable_sign_language))
	linked_action.Grant(parent)

/datum/component/sign_language/UnregisterFromParent()
	disable_sign_language()
	UnregisterSignal(parent, list(
		SIGNAL_ADDTRAIT(TRAIT_SIGN_LANG),
		SIGNAL_REMOVETRAIT(TRAIT_SIGN_LANG)
	))

/// Signal handler for [COMSIG_SIGNLANGUAGE_ENABLE]
/// Enables signing for the parent Carbon, stopping them from speaking vocally.
/// This proc is only called directly after TRAIT_SIGN_LANG is added to the Carbon.
/datum/component/sign_language/proc/enable_sign_language()
	SIGNAL_HANDLER

	var/mob/living/carbon/carbon_parent = parent
	var/obj/item/organ/internal/tongue/tongue = carbon_parent.getorganslot(ORGAN_SLOT_TONGUE)
	if(tongue)
		tongue.temp_say_mod = "signs"
	//this speech relies on hands, which we have our own way of garbling speech when they're occupied, so we can have this always on
	ADD_TRAIT(carbon_parent, TRAIT_SPEAKS_CLEARLY, SPEAKING_FROM_HANDS)
	carbon_parent.verb_ask = "signs"
	carbon_parent.verb_exclaim = "signs"
	carbon_parent.verb_whisper = "subtly signs"
	carbon_parent.verb_sing = "rythmically signs"
	carbon_parent.verb_yell = "emphatically signs"
	carbon_parent.bubble_icon = "signlang"
	RegisterSignal(carbon_parent, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(on_added_organ))
	RegisterSignal(carbon_parent, COMSIG_LIVING_TRY_SPEECH, PROC_REF(on_try_speech))
	RegisterSignal(carbon_parent, COMSIG_LIVING_TREAT_MESSAGE, PROC_REF(on_treat_living_message))
	RegisterSignal(carbon_parent, COMSIG_MOVABLE_USING_RADIO, PROC_REF(on_using_radio))
	RegisterSignal(carbon_parent, COMSIG_MOVABLE_SAY_QUOTE, PROC_REF(on_say_quote))
	RegisterSignal(carbon_parent, COMSIG_MOB_SAY, PROC_REF(on_say))
	return TRUE

/// Signal handler for [COMSIG_SIGNLANGUAGE_DISABLE]
/// Disables signing for the parent Carbon, allowing them to speak vocally.
/// This proc is only called directly after TRAIT_SIGN_LANG is removed from the Carbon.
/datum/component/sign_language/proc/disable_sign_language()
	SIGNAL_HANDLER

	var/mob/living/carbon/carbon_parent = parent
	var/obj/item/organ/internal/tongue/tongue = carbon_parent.getorganslot(ORGAN_SLOT_TONGUE)
	if(tongue)
		tongue.temp_say_mod = ""
	REMOVE_TRAIT(carbon_parent, TRAIT_SPEAKS_CLEARLY, SPEAKING_FROM_HANDS)
	carbon_parent.verb_ask = initial(carbon_parent.verb_ask)
	carbon_parent.verb_exclaim = initial(carbon_parent.verb_exclaim)
	carbon_parent.verb_whisper = initial(carbon_parent.verb_whisper)
	carbon_parent.verb_sing = initial(carbon_parent.verb_sing)
	carbon_parent.verb_yell = initial(carbon_parent.verb_yell)
	carbon_parent.bubble_icon = initial(carbon_parent.bubble_icon)
	UnregisterSignal(carbon_parent, list(
		COMSIG_CARBON_GAIN_ORGAN,
		COMSIG_LIVING_TRY_SPEECH,
		COMSIG_LIVING_TREAT_MESSAGE,
		COMSIG_MOVABLE_USING_RADIO,
		COMSIG_MOVABLE_SAY_QUOTE,
		COMSIG_MOB_SAY
	))
	return TRUE

///Signal proc for [COMSIG_CARBON_GAIN_ORGAN]
///Applies the new say mod to any tongues that have appeared!
/datum/component/sign_language/proc/on_added_organ(mob/living/source, obj/item/organ/new_organ)
	SIGNAL_HANDLER

	if(!istype(new_organ, /obj/item/organ/internal/tongue))
		return
	var/obj/item/organ/internal/tongue/new_tongue = new_organ
	new_tongue.temp_say_mod = "signs"

/// Signal proc for [COMSIG_LIVING_TRY_SPEECH]
/// Sign languagers can always speak regardless of they're mute (as long as they're not mimes)
/datum/component/sign_language/proc/on_try_speech(mob/living/source, message, ignore_spam, forced)
	SIGNAL_HANDLER

	var/mob/living/carbon/carbon_parent = parent
	if(HAS_TRAIT(carbon_parent, TRAIT_MIMING))
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

/// Signal proc for [COMSIG_MOVABLE_USING_RADIO]
/// Disallows us from speaking on comms if we don't have the special trait.
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
		tonal_timerid = addtimer(CALLBACK(src, PROC_REF(remove_tonal_indicator)), 2.5 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE | TIMER_DELETE_ME)
	else // If we're not gonna use it, just be sure we get rid of it
		tonal_indicator = null

	// remove the ! and ? symbols from message at the end
	message = sanitize_message(message)
	speech_args[SPEECH_MESSAGE] = message

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

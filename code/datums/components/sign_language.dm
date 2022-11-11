/// UI location of sign language button.
#define ui_sign_language "EAST-4:-10,SOUTH:21"
/// Defines used to determine whether a sign language user can sign or not, and if not, why they cannot.
#define SIGN_OKAY 0
#define SIGN_ONE_HAND 1
#define SIGN_HANDS_FULL 2
#define SIGN_ARMLESS 3
#define SIGN_ARMS_DISABLED 4
#define SIGN_TRAIT_BLOCKED 5
#define SIGN_CUFFED 6

/// Sign Language component for Humans. Adds a button to the HUD which toggles.
/datum/component/sign_language
	/// The tonal indicator shown when sign language users finish sending a message. If it's empty, none appears.
	var/tonal_indicator = null
	/// The timerid for our sign language tonal indicator.
	var/tonal_timerid
	/// The toggling UI button that is displayed to the mob.
	var/atom/movable/screen/toggle_button

/datum/component/sign_language/Initialize()
	// Non-Human mobs can't use sign language. Sorry, cyborgs!
	if (!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/sign_language/RegisterWithParent()
	var/mob/living/carbon/human/human_parent = parent
	if(!human_parent.hud_used)
		// HUD isn't ready yet. The Mob might still be initializing!
		RegisterSignal(human_parent, COMSIG_MOB_HUD_CREATED, .proc/add_hud_button)
	else
		add_hud_button(caught_signal = FALSE)

/// Deletes the sign language HUD button and disables signing.
/datum/component/sign_language/UnregisterFromParent()
	var/mob/living/carbon/human/human_parent = parent
	UnregisterSignal(human_parent, COMSIG_MOB_HUD_CREATED)
	if (HAS_TRAIT(human_parent, TRAIT_SIGN_LANG))
		disable_sign_language()
	if(human_parent.hud_used)
		human_parent.hud_used.static_inventory -= toggle_button
		human_parent.client.screen -= toggle_button
	qdel(toggle_button)
	toggle_button = null

/// Signal proc for [COMSIG_MOB_HUD_CREATED]
/// Adds a button to the HUD which toggles sign language on/off.
/datum/component/sign_language/proc/add_hud_button(caught_signal = TRUE)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/human_parent = parent
	if (caught_signal)
		UnregisterSignal(human_parent, COMSIG_MOB_HUD_CREATED)
	toggle_button = new /atom/movable/screen/sign_language(src)
	toggle_button.add_atom_colour("#92b8e4", FIXED_COLOUR_PRIORITY)
	toggle_button.icon = human_parent.hud_used.ui_style
	toggle_button.hud = human_parent.hud_used
	human_parent.hud_used.static_inventory += toggle_button
	human_parent.client.screen += toggle_button

/atom/movable/screen/sign_language
	name = "toggle sign language"
	icon = 'icons/hud/screen_midnight.dmi'
	icon_state = "speak_vocal"
	screen_loc = ui_sign_language
	var/datum/component/sign_language/linked_component

/atom/movable/screen/sign_language/New(component)
	. = ..()
	linked_component = component

/atom/movable/screen/sign_language/Destroy()
	linked_component = null
	return ..()

/atom/movable/screen/sign_language/Click()
	if(!isliving(usr))
		return TRUE

	var/mob/living/carbon/human/human_user = usr
	if (human_user.has_trauma_type(/datum/brain_trauma/severe/mute))
		to_chat(human_user, span_warning("You can't stop signing, you can only communicate via sign language!"))
		return TRUE

	if(HAS_TRAIT(human_user, TRAIT_SIGN_LANG))
		icon_state = "speak_vocal"
		to_chat(human_user, span_green("You are no longer communicating with sign language."))
	else
		icon_state = "speak_sign"
		to_chat(human_user, span_green("You are now communicating with sign language."))

	linked_component.toggle_sign_language()

/// Signal proc for [COMSIG_TOGGLE_SIGNLANGUAGE]
/// Toggles sign language on/off for the parent Human. Only returns TRUE upon enabling.
/datum/component/sign_language/proc/toggle_sign_language(toggle_off = FALSE)
	SIGNAL_HANDLER

	if (toggle_off || HAS_TRAIT(parent, TRAIT_SIGN_LANG))
		disable_sign_language()
	else if (!toggle_off)
		enable_sign_language()
		return TRUE

/// Enables signing for the parent Human, stopping them from speaking vocally.
/datum/component/sign_language/proc/enable_sign_language()
	var/mob/living/carbon/human/human_parent = parent
	ADD_TRAIT(human_parent, TRAIT_SIGN_LANG, TRAIT_GENERIC)
	human_parent.dna.species.say_mod = "signs"
	human_parent.verb_ask = "signs"
	human_parent.verb_exclaim = "signs"
	human_parent.verb_whisper = "subtly signs"
	human_parent.verb_sing = "rythmically signs"
	human_parent.verb_yell = "emphatically signs"
	human_parent.bubble_icon = "signlang"
	RegisterSignal(human_parent, COMSIG_LIVING_TRY_SPEECH, .proc/on_try_speech)
	RegisterSignal(human_parent, COMSIG_LIVING_TREAT_MESSAGE, .proc/on_treat_living_message)
	RegisterSignal(human_parent, COMSIG_MOVABLE_TREAT_MESSAGE, .proc/on_treat_message)
	RegisterSignal(human_parent, COMSIG_MOVABLE_USING_RADIO, .proc/on_using_radio)
	RegisterSignal(human_parent, COMSIG_MOVABLE_SAY_QUOTE, .proc/on_say_quote)
	RegisterSignal(human_parent, COMSIG_MOB_SAY, .proc/on_say)

/// Disables signing for the parent Human, allowing them to speak vocally.
/datum/component/sign_language/proc/disable_sign_language()
	var/mob/living/carbon/human/human_parent = parent
	REMOVE_TRAIT(human_parent, TRAIT_SIGN_LANG, TRAIT_GENERIC)
	human_parent.dna.species.say_mod = initial(human_parent.dna.species.say_mod)
	human_parent.verb_ask = initial(human_parent.verb_ask)
	human_parent.verb_exclaim = initial(human_parent.verb_exclaim)
	human_parent.verb_whisper = initial(human_parent.verb_whisper)
	human_parent.verb_sing = initial(human_parent.verb_sing)
	human_parent.verb_yell = initial(human_parent.verb_yell)
	human_parent.bubble_icon = initial(human_parent.bubble_icon)
	UnregisterSignal(human_parent, list(
		COMSIG_LIVING_TRY_SPEECH,
		COMSIG_LIVING_TREAT_MESSAGE,
		COMSIG_MOVABLE_TREAT_MESSAGE,
		COMSIG_MOVABLE_USING_RADIO,
		COMSIG_MOVABLE_SAY_QUOTE,
		COMSIG_MOB_SAY
	))

/// Signal proc for [COMSIG_LIVING_TRY_SPEECH]
/// Sign languagers can always speak regardless of they're mute (as long as they're not mimes)
/datum/component/sign_language/proc/on_try_speech(mob/living/source, message, ignore_spam, forced)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/human_parent = parent
	if(human_parent.mind?.miming)
		to_chat(human_parent, span_green("You stop yourself from signing in favor of the artform of mimery!"))
		return COMPONENT_CANNOT_SPEAK

	switch(check_signables_state())
		if(SIGN_HANDS_FULL) // Full hands
			human_parent.visible_message("tries to sign, but can't with [human_parent.p_their()] hands full!", visible_message_flags = EMOTE_MESSAGE)
			return COMPONENT_CANNOT_SPEAK

		if(SIGN_CUFFED) // Restrained
			human_parent.visible_message("tries to sign, but can't with [human_parent.p_their()] hands bound!", visible_message_flags = EMOTE_MESSAGE)
			return COMPONENT_CANNOT_SPEAK

		if(SIGN_ARMLESS) // No arms
			to_chat(human_parent, span_warning("You can't sign with no hands!"))
			return COMPONENT_CANNOT_SPEAK

		if(SIGN_ARMS_DISABLED) // Arms but they're disabled
			to_chat(human_parent, span_warning("You can't sign with your hands right now!"))
			return COMPONENT_CANNOT_SPEAK

		if(SIGN_TRAIT_BLOCKED) // Hands blocked or emote mute
			to_chat(human_parent, span_warning("You can't sign at the moment!"))
			return COMPONENT_CANNOT_SPEAK

	// Assuming none of the above fail, sign language users can speak
	// regardless of being muzzled or mute toxin'd or whatever.
	return COMPONENT_CAN_ALWAYS_SPEAK

/// Checks to see what state this person is in and if they are able to sign or not.
/datum/component/sign_language/proc/check_signables_state()
	var/mob/living/carbon/human/human_parent = parent
	// See how many hands we can actually use (this counts disabled / missing limbs for us)
	var/total_hands = human_parent.usable_hands
	// Look ma, no hands!
	if(total_hands <= 0)
		// Either our hands are still attached (just disabled) or they're gone entirely
		return human_parent.num_hands > 0 ? SIGN_ARMS_DISABLED : SIGN_ARMLESS

	// Now let's see how many of our hands is holding something
	var/busy_hands = 0
	// Yes held_items can contain null values, which represents empty hands,
	// I'm just saving myself a variable cast by using as anything
	for(var/obj/item/held_item as anything in human_parent.held_items)
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
/datum/component/sign_language/proc/on_say(mob/living/carbon/human/human_parent, list/speech_args)
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
		human_parent.visible_message(span_notice("[human_parent] lowers [human_parent.p_their()] eyebrows."))
	else if(exclamation_found)
		tonal_indicator = mutable_appearance('icons/mob/effects/talk.dmi', "signlang2", TYPING_LAYER)
		human_parent.visible_message(span_notice("[human_parent] raises [human_parent.p_their()] eyebrows."))
	// If either an exclamation or question are found
	if(!isnull(tonal_indicator) && human_parent.client?.typing_indicators)
		human_parent.add_overlay(tonal_indicator)
		tonal_timerid = addtimer(CALLBACK(src, .proc/remove_tonal_indicator), 2.5 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE | TIMER_DELETE_ME)
	else // If we're not gonna use it, just be sure we get rid of it
		tonal_indicator = null

/// Removes the tonal indicator overlay completely
/datum/component/sign_language/proc/remove_tonal_indicator()
	if(isnull(tonal_indicator))
		return
	var/mob/living/carbon/human/human_parent = parent
	human_parent.cut_overlay(tonal_indicator)
	tonal_indicator = null

#undef SIGN_OKAY
#undef SIGN_ONE_HAND
#undef SIGN_HANDS_FULL
#undef SIGN_ARMLESS
#undef SIGN_ARMS_DISABLED
#undef SIGN_TRAIT_BLOCKED
#undef SIGN_CUFFED

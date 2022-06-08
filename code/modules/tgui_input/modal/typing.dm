/// Thinking
GLOBAL_DATUM_INIT(thinking_indicator, /mutable_appearance, mutable_appearance('icons/mob/talk.dmi', "default3", -TYPING_LAYER))
/// Typing
GLOBAL_DATUM_INIT(typing_indicator, /mutable_appearance, mutable_appearance('icons/mob/talk.dmi', "default0", -TYPING_LAYER))


/mob/proc/create_thinking_indicator()
	return

/mob/proc/remove_thinking_indicator()
	return

/mob/proc/create_typing_indicator()
	return

/mob/proc/remove_typing_indicator()
	return

/mob/set_stat(new_stat)
	. = ..()
	if(.)
		remove_typing_indicator()
		remove_thinking_indicator()

/mob/Logout()
	remove_typing_indicator()
	remove_thinking_indicator()
	return ..()

/// Whether or not to show a typing indicator when speaking. Defaults to on.
/datum/preference/toggle/typing_indicator
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "typingIndicator"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/typing_indicator/apply_to_client(client/client, value)
	client?.typing_indicators = value

/// Shows the thinking indicator - player has window open
/mob/verb/start_thinking()
	set name = ".start_thinking"
	set hidden = TRUE
	create_thinking_indicator()
	remove_typing_indicator()

/// Hides all typing/thinking indicators
/mob/verb/cancel_thinking()
	set name = ".cancel_thinking"
	set hidden = TRUE
	remove_thinking_indicator()
	remove_typing_indicator()

/// Show the typing indicator - player is typing into the window
/mob/verb/start_typing()
	set name = ".start_typing"
	set hidden = TRUE
	remove_thinking_indicator()
	create_typing_indicator()

/// Hide the typing indicator.
/mob/verb/cancel_typing()
	set name = ".cancel_typing"
	set hidden = TRUE
	remove_typing_indicator()
	create_thinking_indicator()

/**
 * Handles the user typing. After a brief period of inactivity,
 * signals the client mob to revert to the "thinking" icon.
 */
/datum/tgui_modal/proc/init_typing()
	addtimer(CALLBACK(src, .proc/stop_typing), 6 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE)
	if(client.mob)
		client.mob.start_typing()

/** Signals the mob to return to "thinking" state */
/datum/tgui_modal/proc/stop_typing()
	if(!client || !client.mob)
		stack_trace(("[usr] has no client or mob but was typing?"))
		return FALSE
	if(window_open)
		client.mob.cancel_typing()
	else
		client.mob.cancel_thinking()


/mob/living/create_thinking_indicator()
	if(!client || !client.typing_indicators) // If they've got typing indicators shut off, don't show the thinking indicator
		return
	if(!thinking_indicator && stat == CONSCIOUS) //Prevents sticky overlays and typing while in any state besides conscious
		add_overlay(GLOB.thinking_indicator)
		thinking_indicator = TRUE

/mob/living/remove_thinking_indicator()
	if(thinking_indicator)
		cut_overlay(GLOB.thinking_indicator)
		thinking_indicator = FALSE

/mob/living/create_typing_indicator()
	if(!client || !client.typing_indicators) // If they've got typing indicators shut off, don't show the typing indicator
		return
	if(!typing_indicator && stat == CONSCIOUS)
		add_overlay(GLOB.typing_indicator)
		typing_indicator = TRUE

/mob/living/remove_typing_indicator()
	if(typing_indicator)
		cut_overlay(GLOB.typing_indicator)
		typing_indicator = FALSE

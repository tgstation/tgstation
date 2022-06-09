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

/**
 * Modulates the visibility of thinking indicators
 *
 * Arguments:
 ** enabled - boolean whether thinking indicator is to be displayed.
 */
/datum/tgui_modal/proc/is_thinking(enabled = TRUE)
	if(!client || !client.mob) // If they've got typing indicators shut off, don't show the thinking indicator
		stack_trace(("[usr] has no client or mob but was thinking?"))
		return FALSE
	if(enabled)
		client.mob.create_thinking_indicator()
		client.mob.thinking_IC = TRUE
	else
		client.mob.remove_thinking_indicator()
		client.mob.remove_typing_indicator()
		client.mob.thinking_IC = FALSE

/**
 * Handles the user typing. After a brief period of inactivity,
 * signals the client mob to revert to the "thinking" icon.
 */
/datum/tgui_modal/proc/is_typing()
	if(!client || !client.mob)
		stack_trace(("[usr] has no client or mob but was typing?"))
		return FALSE
	addtimer(CALLBACK(src, .proc/stop_typing), 6 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE)
	client.mob.remove_thinking_indicator()
	if(client.mob.thinking_IC)
		client.mob.create_typing_indicator()

/**
 * Signals the mob to return to "thinking" state
 * if they were previously thinking IC.
 */
/datum/tgui_modal/proc/stop_typing()
	if(!client || !client.mob)
		stack_trace(("[usr] has no client or mob but was typing?"))
		return FALSE
	client.mob.remove_typing_indicator()
	if(client.mob.thinking_IC)
		client.mob.create_thinking_indicator()

/** Overrides for overlay creation */
/mob/living/create_thinking_indicator()
	if(!client || !client.typing_indicators || !client.tgui_modal.window_open)
		return
	if(!thinking_indicator && stat == CONSCIOUS) //Prevents sticky overlays and typing while in any state besides conscious
		add_overlay(GLOB.thinking_indicator)
		thinking_indicator = TRUE

/mob/living/remove_thinking_indicator()
	if(thinking_indicator)
		cut_overlay(GLOB.thinking_indicator)
		thinking_indicator = FALSE

/mob/living/create_typing_indicator()
	if(!client || !client.typing_indicators || !client.tgui_modal.window_open)
		return
	if(!typing_indicator && stat == CONSCIOUS)
		add_overlay(GLOB.typing_indicator)
		typing_indicator = TRUE

/mob/living/remove_typing_indicator()
	if(typing_indicator)
		cut_overlay(GLOB.typing_indicator)
		typing_indicator = FALSE

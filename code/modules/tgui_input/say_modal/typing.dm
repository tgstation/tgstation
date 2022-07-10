#define THINKING 0
#define TYPING 1
#define TONE_QUESTION 2
#define TONE_YELL 3
#define TONE_NORMAL 4
#define TONE_INDECISIVE 5

/** Creates a thinking indicator over the mob. */
/mob/proc/create_thinking_indicator()
	return

/** Removes the thinking indicator over the mob. */
/mob/proc/remove_thinking_indicator()
	return

/** Creates a typing indicator over the mob. */
/mob/proc/create_typing_indicator()
	return

/** Removes the typing indicator over the mob. */
/mob/proc/remove_typing_indicator()
	return

/** Removes any indicators and marks the mob as not speaking IC. */
/mob/proc/remove_all_indicators()
	return

/mob/set_stat(new_stat)
	. = ..()
	if(.)
		remove_all_indicators()

/mob/Logout()
	remove_all_indicators()
	return ..()

/// Whether or not to show a typing indicator when speaking. Defaults to on.
/datum/preference/toggle/typing_indicator
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "typingIndicator"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/typing_indicator/apply_to_client(client/client, value)
	client?.typing_indicators = value

/** Sets the mob as "thinking" - with indicator and variable thinking_IC */
/datum/tgui_say/proc/start_thinking()
	if(!window_open || !client.typing_indicators)
		return FALSE
	/// Special exemptions
	if(isabductor(client.mob))
		return FALSE
	client.mob.thinking_IC = TRUE
	client.mob.create_thinking_indicator()

/** Removes typing/thinking indicators and flags the mob as not thinking */
/datum/tgui_say/proc/stop_thinking()
	client.mob?.remove_all_indicators()

/**
 * Handles the user typing. After a brief period of inactivity,
 * signals the client mob to revert to the "thinking" icon.
 */
/datum/tgui_say/proc/start_typing()
	client.mob.remove_thinking_indicator()
	if(!window_open || !client.typing_indicators || !client.mob.thinking_IC)
		return FALSE
	client.mob.create_typing_indicator()
	stop_typing_timer = addtimer(CALLBACK(src, .proc/stop_typing), 5 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE)

/**
 * Callback to remove the typing indicator after a brief period of inactivity.
 * If the user was typing IC, the thinking indicator is shown.
 */
/datum/tgui_say/proc/stop_typing()
	if(!client?.mob)
		return FALSE
	client.mob.remove_typing_indicator()
	if(!window_open || !client.typing_indicators || !client.mob.thinking_IC)
		return FALSE
	client.mob.create_thinking_indicator()

/**
 * Displays a new indicator that completes the sentence.
 * Adds a timer to clear the fading bubble after a couple seconds.
 */
/datum/tgui_say/proc/finish_speaking(message)
	if(!window_open || !client.typing_indicators || !client.mob.thinking_IC)
		return FALSE
	client.mob.remove_typing_indicator()
	client.mob.remove_thinking_indicator()
	client.mob.thinking_IC = FALSE
	var/tone
	switch(message)
		if(null)
			tone = TONE_INDECISIVE
		if("?")
			tone = TONE_QUESTION
		if("!")
			tone = TONE_YELL
		else
			tone = TONE_NORMAL
	client.mob.create_tonal_indicator(tone)
	deltimer(stop_typing_timer)
	addtimer(CALLBACK(src, .proc/finished), 2 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE)
	return TRUE

/// Overrides for overlay creation
/mob/living/create_thinking_indicator()
	if(active_thinking_indicator || active_typing_indicator || !thinking_IC || stat != CONSCIOUS )
		return FALSE
	active_thinking_indicator = mutable_appearance('icons/mob/talk.dmi', "[bubble_icon][THINKING]", TYPING_LAYER)
	add_overlay(active_thinking_indicator)

/mob/living/remove_thinking_indicator()
	if(!active_thinking_indicator)
		return FALSE
	cut_overlay(active_thinking_indicator)
	active_thinking_indicator = null

/mob/living/create_typing_indicator()
	if(active_typing_indicator || active_thinking_indicator || !thinking_IC || stat != CONSCIOUS)
		return FALSE
	active_typing_indicator = mutable_appearance('icons/mob/talk.dmi', "[bubble_icon][TYPING]", TYPING_LAYER)
	add_overlay(active_typing_indicator)

/mob/living/remove_typing_indicator()
	if(!active_typing_indicator)
		return FALSE
	cut_overlay(active_typing_indicator)
	active_typing_indicator = null

/mob/living/create_tonal_indicator(tone)
	if(active_thinking_indicator || active_typing_indicator || !thinking_IC || stat != CONSCIOUS)
		return FALSE
	active_tonal_indicator = mutable_appearance('icons/mob/talk.dmi', "[bubble_icon][tone]", TYPING_LAYER)
	add_overlay(active_tonal_indicator)

/mob/living/remove_tonal_indicator()
	if(!active_tonal_indicator)
		return FALSE
	cut_overlay(active_tonal_indicator)
	active_tonal_indicator = null

/mob/living/remove_all_indicators()
	thinking_IC = FALSE
	remove_thinking_indicator()
	remove_typing_indicator()
	remove_tonal_indicator()

#undef TONE_INDECISIVE
#undef TONE_NORMAL
#undef TONE_QUESTION
#undef TONE_YELL

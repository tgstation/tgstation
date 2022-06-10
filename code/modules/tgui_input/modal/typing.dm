/// Thinking
GLOBAL_DATUM_INIT(thinking_indicator, /mutable_appearance, mutable_appearance('icons/mob/talk.dmi', "default3", -TYPING_LAYER))
/// Typing
GLOBAL_DATUM_INIT(typing_indicator, /mutable_appearance, mutable_appearance('icons/mob/talk.dmi', "default0", -TYPING_LAYER))


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
/datum/tgui_modal/proc/start_thinking()
	if(!client || !client.mob)
		CRASH("Started tgui modal thinking on a null client or mob")
	if(!window_open || !client.typing_indicators)
		return FALSE
	client.mob.create_thinking_indicator()
	client.mob.thinking_IC = TRUE

/** Removes typing/thinking indicators and flags the mob as not thinking */
/datum/tgui_modal/proc/stop_thinking()
	if(!client || !client.mob)
		CRASH("Stopped tgui modal thinking on a null client or mob")
	client.mob.remove_all_indicators()

/**
 * Handles the user typing. After a brief period of inactivity,
 * signals the client mob to revert to the "thinking" icon.
 */
/datum/tgui_modal/proc/start_typing()
	if(!client || !client.mob)
		CRASH("Started tgui modal typing on a null client or mob")
	client.mob.remove_thinking_indicator()
	if(client.mob.thinking_IC && window_open && client.typing_indicators)
		client.mob.create_typing_indicator()
		addtimer(CALLBACK(src, .proc/stop_typing), 6 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE)

/**
 * Callback to remove the typing indicator after a brief period of inactivity.
 * If the user was typing IC, the thinking indicator is shown.
 */
/datum/tgui_modal/proc/stop_typing()
	if(!client || !client.mob)
		CRASH("Stopped tgui modal typing on a null client or mob")
	client.mob.remove_typing_indicator()
	if(client.mob.thinking_IC && window_open && client.typing_indicators)
		client.mob.create_thinking_indicator()

/// Overrides for overlay creation
/mob/living/create_thinking_indicator()
	if(!thinking_indicator && stat == CONSCIOUS)
		add_overlay(GLOB.thinking_indicator)
		thinking_indicator = TRUE

/mob/living/remove_thinking_indicator()
	if(thinking_indicator)
		cut_overlay(GLOB.thinking_indicator)
		thinking_indicator = FALSE

/mob/living/create_typing_indicator()
	if(!typing_indicator && stat == CONSCIOUS)
		add_overlay(GLOB.typing_indicator)
		typing_indicator = TRUE

/mob/living/remove_typing_indicator()
	if(typing_indicator)
		cut_overlay(GLOB.typing_indicator)
		typing_indicator = FALSE

/mob/living/remove_all_indicators()
	remove_thinking_indicator()
	remove_typing_indicator()
	thinking_IC = FALSE

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

/** Sets the mob as "thinking" - with indicator and the TRAIT_THINKING_IN_CHARACTER trait */
/datum/tgui_say/proc/start_thinking()
	if(!window_open || !client.typing_indicators)
		return FALSE
	/// Special exemptions
	if(isabductor(client.mob))
		return FALSE
	ADD_TRAIT(client.mob, TRAIT_THINKING_IN_CHARACTER, CURRENTLY_TYPING_TRAIT)
	client.mob.create_thinking_indicator()

/** Removes typing/thinking indicators and flags the mob as not thinking */
/datum/tgui_say/proc/stop_thinking()
	client.mob?.remove_all_indicators()

/**
 * Handles the user typing. After a brief period of inactivity,
 * signals the client mob to revert to the "thinking" icon.
 */
/datum/tgui_say/proc/start_typing()
	var/mob/client_mob = client.mob
	client_mob.remove_thinking_indicator()
	if(!window_open || !client.typing_indicators || !HAS_TRAIT(client_mob, TRAIT_THINKING_IN_CHARACTER))
		return FALSE
	client_mob.create_typing_indicator()
	addtimer(CALLBACK(src, PROC_REF(stop_typing)), 5 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE | TIMER_STOPPABLE)

/**
 * Callback to remove the typing indicator after a brief period of inactivity.
 * If the user was typing IC, the thinking indicator is shown.
 */
/datum/tgui_say/proc/stop_typing()
	if(isnull(client?.mob))
		return FALSE
	var/mob/client_mob = client.mob
	client_mob.remove_typing_indicator()
	if(!window_open || !client.typing_indicators || !HAS_TRAIT(client_mob, TRAIT_THINKING_IN_CHARACTER))
		return FALSE
	client_mob.create_thinking_indicator()

/// Overrides for overlay creation
/mob/living/create_thinking_indicator()
	if(active_thinking_indicator || active_typing_indicator || stat != CONSCIOUS || !HAS_TRAIT(src, TRAIT_THINKING_IN_CHARACTER))
		return FALSE
	active_thinking_indicator = mutable_appearance('icons/mob/effects/talk.dmi', "[bubble_icon]3", TYPING_LAYER)
	add_overlay(active_thinking_indicator)
	play_fov_effect(src, 6, "talk", ignore_self = TRUE)

/mob/living/remove_thinking_indicator()
	if(!active_thinking_indicator)
		return FALSE
	cut_overlay(active_thinking_indicator)
	active_thinking_indicator = null

/mob/living/create_typing_indicator()
	if(active_typing_indicator || active_thinking_indicator || stat != CONSCIOUS || !HAS_TRAIT(src, TRAIT_THINKING_IN_CHARACTER))
		return FALSE
	active_typing_indicator = mutable_appearance('icons/mob/effects/talk.dmi', "[bubble_icon]0", TYPING_LAYER)
	add_overlay(active_typing_indicator)
	play_fov_effect(src, 6, "talk", ignore_self = TRUE)

/mob/living/remove_typing_indicator()
	if(!active_typing_indicator)
		return FALSE
	cut_overlay(active_typing_indicator)
	active_typing_indicator = null

/mob/living/remove_all_indicators()
	REMOVE_TRAIT(src, TRAIT_THINKING_IN_CHARACTER, CURRENTLY_TYPING_TRAIT)
	remove_thinking_indicator()
	remove_typing_indicator()


#define EMOTE_VISIBLE 1
#define EMOTE_AUDIBLE 2

/**
 * # Emote
 *
 * Most of the text that's not someone talking is based off of this.
 *
 * Yes, the displayed message is stored on the datum, it would cause problems
 * for emotes with a message that can vary, but that's handled differently in
 * run_emote(), so be sure to use can_message_change if you plan to have
 * different displayed messages from player to player.
 *
 */
/datum/emote
	/// What calls the emote.
	var/key = ""
	/// This will also call the emote.
	var/key_third_person = ""
	/// Message displayed when emote is used.
	var/message = ""
	/// Message displayed if the user is a mime.
	var/message_mime = ""
	/// Message displayed if the user is a grown alien.
	var/message_alien = ""
	/// Message displayed if the user is an alien larva.
	var/message_larva = ""
	/// Message displayed if the user is a robot.
	var/message_robot = ""
	/// Message displayed if the user is an AI.
	var/message_AI = ""
	/// Message displayed if the user is a monkey.
	var/message_monkey = ""
	/// Message to display if the user is a simple_animal.
	var/message_simple = ""
	/// Message with %t at the end to allow adding params to the message, like for mobs doing an emote relatively to something else.
	var/message_param = ""
	/// Whether the emote is visible or audible.
	var/emote_type = EMOTE_VISIBLE
	/// Checks if the mob can use its hands before performing the emote.
	var/hands_use_check = FALSE
	/// Will only work if the emote is EMOTE_AUDIBLE.
	var/muzzle_ignore = FALSE
	/// Types that are allowed to use that emote.
	var/list/mob_type_allowed_typecache = /mob
	/// Types that are NOT allowed to use that emote.
	var/list/mob_type_blacklist_typecache
	/// Types that can use this emote regardless of their state.
	var/list/mob_type_ignore_stat_typecache
	/// In which state can you use this emote? (Check stat.dm for a full list of them)
	var/stat_allowed = CONSCIOUS
	/// Sound to play when emote is called.
	var/sound
	/// Used for the honk borg emote.
	var/vary = FALSE
	/// Can only code call this event instead of the player.
	var/only_forced_audio = FALSE
	/// The cooldown between the uses of the emote.
	var/cooldown = 0.8 SECONDS
	/// Does this message have a message that can be modified by the user?
	var/can_message_change = FALSE
	/// How long is the cooldown on the audio of the emote, if it has one?
	var/audio_cooldown = 2 SECONDS

/datum/emote/New()
	if (ispath(mob_type_allowed_typecache))
		switch (mob_type_allowed_typecache)
			if (/mob)
				mob_type_allowed_typecache = GLOB.typecache_mob
			if (/mob/living)
				mob_type_allowed_typecache = GLOB.typecache_living
			else
				mob_type_allowed_typecache = typecacheof(mob_type_allowed_typecache)
	else
		mob_type_allowed_typecache = typecacheof(mob_type_allowed_typecache)
	mob_type_blacklist_typecache = typecacheof(mob_type_blacklist_typecache)
	mob_type_ignore_stat_typecache = typecacheof(mob_type_ignore_stat_typecache)

/**
 * Handles the modifications and execution of emotes.
 *
 * Arguments:
 * * user - Person that is trying to send the emote.
 * * params - Parameters added after the emote.
 * * type_override - Override to the current emote_type.
 * * intentional - Bool that says whether the emote was forced (FALSE) or not (TRUE).
 *
 * Returns TRUE if it was able to run the emote, FALSE otherwise.
 */
/datum/emote/proc/run_emote(mob/user, params, type_override, intentional = FALSE)
	. = TRUE
	if(!can_run_emote(user, TRUE, intentional))
		return FALSE
	var/msg = select_message_type(user, message, intentional)
	if(params && message_param)
		msg = select_param(user, params)

	msg = replace_pronoun(user, msg)

	if(!msg)
		return

	user.log_message(msg, LOG_EMOTE)
	var/dchatmsg = "<b>[user]</b> [msg]"

	var/tmp_sound = get_sound(user)
	if(tmp_sound && should_play_sound(user, intentional) && !TIMER_COOLDOWN_CHECK(user, type))
		TIMER_COOLDOWN_START(user, type, audio_cooldown)
		playsound(user, tmp_sound, 50, vary)

	var/user_turf = get_turf(user)
	if (user.client)
		for(var/mob/ghost as anything in GLOB.dead_mob_list)
			if(!ghost.client || isnewplayer(ghost))
				continue
			if(ghost.client.prefs.chat_toggles & CHAT_GHOSTSIGHT && !(ghost in viewers(user_turf, null)))
				ghost.show_message("<span class='emote'>[FOLLOW_LINK(ghost, user)] [dchatmsg]</span>")

	if(emote_type == EMOTE_AUDIBLE)
		user.audible_message(msg, deaf_message = "<span class='emote'>You see how <b>[user]</b> [msg]</span>", audible_message_flags = EMOTE_MESSAGE)
	else
		user.visible_message(msg, blind_message = "<span class='emote'>You hear how <b>[user]</b> [msg]</span>", visible_message_flags = EMOTE_MESSAGE)

	SEND_SIGNAL(user, COMSIG_MOB_EMOTED(key))

/**
 * For handling emote cooldown, return true to allow the emote to happen.
 *
 * Arguments:
 * * user - Person that is trying to send the emote.
 * * intentional - Bool that says whether the emote was forced (FALSE) or not (TRUE).
 *
 * Returns FALSE if the cooldown is not over, TRUE if the cooldown is over.
 */
/datum/emote/proc/check_cooldown(mob/user, intentional)
	if(!intentional)
		return TRUE
	if(user.emotes_used && user.emotes_used[src] + cooldown > world.time)
		var/datum/emote/default_emote = /datum/emote
		if(cooldown > initial(default_emote.cooldown)) // only worry about longer-than-normal emotes
			to_chat(user, span_danger("You must wait another [DisplayTimeText(user.emotes_used[src] - world.time + cooldown)] before using that emote."))
		return FALSE
	if(!user.emotes_used)
		user.emotes_used = list()
	user.emotes_used[src] = world.time
	return TRUE

/**
 * To get the sound that the emote plays, for special sound interactions depending on the mob.
 *
 * Arguments:
 * * user - Person that is trying to send the emote.
 *
 * Returns the sound that will be made while sending the emote.
 */
/datum/emote/proc/get_sound(mob/living/user)
	return sound //by default just return this var.

/**
 * To replace pronouns in the inputed string with the user's proper pronouns.
 *
 * Arguments:
 * * user - Person that is trying to send the emote.
 * * msg - The string to modify.
 *
 * Returns the modified msg string.
 */
/datum/emote/proc/replace_pronoun(mob/user, msg)
	if(findtext(msg, "their"))
		msg = replacetext(msg, "their", user.p_their())
	if(findtext(msg, "them"))
		msg = replacetext(msg, "them", user.p_them())
	if(findtext(msg, "they"))
		msg = replacetext(msg, "they", user.p_they())
	if(findtext(msg, "%s"))
		msg = replacetext(msg, "%s", user.p_s())
	return msg

/**
 * Selects the message type to override the message with.
 *
 * Arguments:
 * * user - Person that is trying to send the emote.
 * * msg - The string to modify.
 * * intentional - Bool that says whether the emote was forced (FALSE) or not (TRUE).
 *
 * Returns the new message, or msg directly, if no change was needed.
 */
/datum/emote/proc/select_message_type(mob/user, msg, intentional)
	// Basically, we don't care that the others can use datum variables, because they're never going to change.
	. = msg
	if(!muzzle_ignore && user.is_muzzled() && emote_type == EMOTE_AUDIBLE)
		return "makes a [pick("strong ", "weak ", "")]noise."
	if(user.mind && user.mind.miming && message_mime)
		. = message_mime
	if(isalienadult(user) && message_alien)
		. = message_alien
	else if(islarva(user) && message_larva)
		. = message_larva
	else if(iscyborg(user) && message_robot)
		. = message_robot
	else if(isAI(user) && message_AI)
		. = message_AI
	else if(ismonkey(user) && message_monkey)
		. = message_monkey
	else if(isanimal(user) && message_simple)
		. = message_simple

/**
 * Replaces the %t in the message in message_param by params.
 *
 * Arguments:
 * * user - Person that is trying to send the emote.
 * * params - Parameters added after the emote.
 *
 * Returns the modified string.
 */
/datum/emote/proc/select_param(mob/user, params)
	return replacetext(message_param, "%t", params)

/**
 * Check to see if the user is allowed to run the emote.
 *
 * Arguments:
 * * user - Person that is trying to send the emote.
 * * status_check - Bool that says whether we should check their stat or not.
 * * intentional - Bool that says whether the emote was forced (FALSE) or not (TRUE).
 *
 * Returns a bool about whether or not the user can run the emote.
 */
/datum/emote/proc/can_run_emote(mob/user, status_check = TRUE, intentional = FALSE)
	. = TRUE
	if(!is_type_in_typecache(user, mob_type_allowed_typecache))
		return FALSE
	if(is_type_in_typecache(user, mob_type_blacklist_typecache))
		return FALSE
	if(status_check && !is_type_in_typecache(user, mob_type_ignore_stat_typecache))
		if(user.stat > stat_allowed)
			if(!intentional)
				return FALSE
			switch(user.stat)
				if(SOFT_CRIT)
					to_chat(user, span_warning("You cannot [key] while in a critical condition!"))
				if(UNCONSCIOUS, HARD_CRIT)
					to_chat(user, span_warning("You cannot [key] while unconscious!"))
				if(DEAD)
					to_chat(user, span_warning("You cannot [key] while dead!"))
			return FALSE
		if(hands_use_check && HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
			if(!intentional)
				return FALSE
			to_chat(user, span_warning("You cannot use your hands to [key] right now!"))
			return FALSE

	if(isliving(user))
		var/mob/living/sender = user
		if(HAS_TRAIT(sender, TRAIT_EMOTEMUTE))
			return FALSE

/**
 * Check to see if the user should play a sound when performing the emote.
 *
 * Arguments:
 * * user - Person that is doing the emote.
 * * intentional - Bool that says whether the emote was forced (FALSE) or not (TRUE).
 *
 * Returns a bool about whether or not the user should play a sound when performing the emote.
 */
/datum/emote/proc/should_play_sound(mob/user, intentional = FALSE)
	if(only_forced_audio && intentional)
		return FALSE
	return TRUE

/**
* Allows the intrepid coder to send a basic emote
* Takes text as input, sends it out to those who need to know after some light parsing
* If you need something more complex, make it into a datum emote
* Arguments:
* * text - The text to send out
*
* Returns TRUE if it was able to run the emote, FALSE otherwise.
*/
/mob/proc/manual_emote(text) //Just override the song and dance
	. = TRUE
	if(stat != CONSCIOUS)
		return

	if(!text)
		CRASH("Someone passed nothing to manual_emote(), fix it")

	log_message(text, LOG_EMOTE)

	var/ghost_text = "<b>[src]</b> [text]"

	var/origin_turf = get_turf(src)
	if(client)
		for(var/mob/ghost as anything in GLOB.dead_mob_list)
			if(!ghost.client || isnewplayer(ghost))
				continue
			if(ghost.client.prefs.chat_toggles & CHAT_GHOSTSIGHT && !(ghost in viewers(origin_turf, null)))
				ghost.show_message("[FOLLOW_LINK(ghost, src)] [ghost_text]")

	visible_message(text, visible_message_flags = EMOTE_MESSAGE)

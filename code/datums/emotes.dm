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
	/// Needed for more user-friendly emote names, so emotes with keys like "aflap" will show as "flap angry". Defaulted to key.
	var/name = ""
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
	/// Message to display if the user is a simple_animal or basic mob.
	var/message_animal_or_basic = ""
	/// Message with %t at the end to allow adding params to the message, like for mobs doing an emote relatively to something else.
	var/message_param = ""
	/// Whether the emote is visible and/or audible bitflag
	var/emote_type = EMOTE_VISIBLE
	/// Checks if the mob can use its hands before performing the emote.
	var/hands_use_check = FALSE
	/// Types that are allowed to use that emote.
	var/list/mob_type_allowed_typecache = /mob
	/// Types that are NOT allowed to use that emote.
	var/list/mob_type_blacklist_typecache
	/// Types that can use this emote regardless of their state.
	var/list/mob_type_ignore_stat_typecache
	/// Trait that is required to use this emote.
	var/trait_required
	/// In which state can you use this emote? (Check stat.dm for a full list of them)
	var/stat_allowed = CONSCIOUS
	/// Sound to play when emote is called.
	var/sound
	/// Does this emote vary in pitch?
	var/vary = FALSE
	/// If this emote's sound is affected by TTS pitch
	var/affected_by_pitch = TRUE
	/// Can only code call this event instead of the player.
	var/only_forced_audio = FALSE
	/// The cooldown between the uses of the emote.
	var/cooldown = 0.8 SECONDS
	/// Does this message have a message that can be modified by the user?
	var/can_message_change = FALSE
	/// How long is the shared emote cooldown triggered by this emote?
	var/general_emote_audio_cooldown = 2 SECONDS
	/// How long is the specific emote cooldown triggered by this emote?
	var/specific_emote_audio_cooldown = 5 SECONDS
	/// Does this emote's sound ignore walls?
	var/sound_wall_ignore = FALSE

/datum/emote/New()
	switch(mob_type_allowed_typecache)
		if(/mob)
			mob_type_allowed_typecache = GLOB.typecache_mob
		if(/mob/living)
			mob_type_allowed_typecache = GLOB.typecache_living
		else
			mob_type_allowed_typecache = typecacheof(mob_type_allowed_typecache)

	mob_type_blacklist_typecache = typecacheof(mob_type_blacklist_typecache)
	mob_type_ignore_stat_typecache = typecacheof(mob_type_ignore_stat_typecache)

	if(!name)
		name = key

/**
 * Handles the modifications and execution of emotes.
 *
 * Arguments:
 * * user - Person that is trying to send the emote.
 * * params - Parameters added after the emote.
 * * type_override - Override to the current emote_type.
 * * intentional - Bool that says whether the emote was forced (FALSE) or not (TRUE).
 *
 */
/datum/emote/proc/run_emote(mob/user, params, type_override, intentional = FALSE)
	var/msg = select_message_type(user, message, intentional)
	if(params && message_param)
		msg = select_param(user, params)

	msg = replace_pronoun(user, msg)
	if(!msg)
		return

	user.log_message(msg, LOG_EMOTE)

	var/tmp_sound = get_sound(user)
	if(tmp_sound && should_play_sound(user, intentional) && TIMER_COOLDOWN_FINISHED(user, "general_emote_audio_cooldown") && TIMER_COOLDOWN_FINISHED(user, type))
		TIMER_COOLDOWN_START(user, type, specific_emote_audio_cooldown)
		TIMER_COOLDOWN_START(user, "general_emote_audio_cooldown", general_emote_audio_cooldown)
		var/frequency = null
		if (affected_by_pitch && SStts.tts_enabled && SStts.pitch_enabled)
			frequency = rand(MIN_EMOTE_PITCH, MAX_EMOTE_PITCH) * (1 + sqrt(abs(user.pitch)) * SIGN(user.pitch) * EMOTE_TTS_PITCH_MULTIPLIER)
		else if(vary)
			frequency = rand(MIN_EMOTE_PITCH, MAX_EMOTE_PITCH)
		playsound(source = user,soundin = tmp_sound,vol = 50, vary = FALSE, ignore_walls = sound_wall_ignore, frequency = frequency)


	var/is_important = emote_type & EMOTE_IMPORTANT
	var/is_visual = emote_type & EMOTE_VISIBLE
	var/is_audible = emote_type & EMOTE_AUDIBLE
	var/additional_message_flags = get_message_flags(intentional)
	var/space = should_have_space_before_emote(html_decode(msg)[1]) ? " " : "" // DOPPLER EDIT ADDITION

	// Emote doesn't get printed to chat, runechat only
	if(emote_type & EMOTE_RUNECHAT)
		for(var/mob/viewer as anything in viewers(user))
			if(isnull(viewer.client))
				continue
			if(!is_important && viewer != user && (!is_visual || !is_audible))
				if(is_audible && !viewer.can_hear())
					continue
				if(is_visual && viewer.is_blind())
					continue
			if(user.runechat_prefs_check(viewer, EMOTE_MESSAGE))
				viewer.create_chat_message(
					speaker = user,
					raw_message = msg,
					runechat_flags = EMOTE_MESSAGE,
				)
			else if(is_important)
				to_chat(viewer, span_emote("<b>[user]</b> [msg]"))
			else if(is_audible && is_visual)
				viewer.show_message(
					span_emote("<b>[user]</b> [msg]"), MSG_AUDIBLE,
					span_emote("You see how <b>[user]</b> [msg]"), MSG_VISUAL,
				)
			else if(is_audible)
				viewer.show_message(span_emote("<b>[user]</b> [msg]"), MSG_AUDIBLE)
			else if(is_visual)
				viewer.show_message(span_emote("<b>[user]</b> [msg]"), MSG_VISUAL)
		return // Early exit so no dchat message

	// The emote has some important information, and should always be shown to the user
	else if(is_important)
		for(var/mob/viewer as anything in viewers(user))
			to_chat(viewer, span_emote("<b>[user]</b> [msg]"))
			if(user.runechat_prefs_check(viewer, EMOTE_MESSAGE))
				viewer.create_chat_message(
					speaker = user,
					raw_message = msg,
					runechat_flags = EMOTE_MESSAGE,
				)
	// Emotes has both an audible and visible component
	// Prioritize audible, and provide a visible message if the user is deaf
	else if(is_visual && is_audible)
		user.audible_message(
			message = msg,
			deaf_message = span_emote("You see how <b>[user]</b> [msg]"),
			self_message = msg,
			audible_message_flags = EMOTE_MESSAGE|ALWAYS_SHOW_SELF_MESSAGE|additional_message_flags,
			separation = space, // DOPPLER EDIT ADDITION
		)
	// Emote is entirely audible, no visible component
	else if(is_audible)
		user.audible_message(
			message = msg,
			self_message = msg,
			audible_message_flags = EMOTE_MESSAGE|additional_message_flags,
			separation = space, // DOPPLER EDIT ADDITION
		)
	// Emote is entirely visible, no audible component
	else if(is_visual)
		user.visible_message(
			message = msg,
			self_message = msg,
			visible_message_flags = EMOTE_MESSAGE|ALWAYS_SHOW_SELF_MESSAGE|additional_message_flags,
			separation = space, // DOPPLER EDIT ADDITION
		)
	else
		CRASH("Emote [type] has no valid emote type set!")

	// DOPPLER EDIT ADDITION START - AI QOL - RELAY EMOTES OVER HOLOPADS
	var/obj/effect/overlay/holo_pad_hologram/hologram = GLOB.hologram_impersonators[user]
	if(hologram)
		if(is_important)
			for(var/mob/living/viewer in viewers(world.view, hologram))
				to_chat(viewer, msg)
		else if(is_visual && is_audible)
			hologram.audible_message(
				message = msg,
				deaf_message = "<span class='emote'>You see how <b>[user]</b> [msg]</span>",
				self_message = msg,
				audible_message_flags = EMOTE_MESSAGE|ALWAYS_SHOW_SELF_MESSAGE,
				separation = space,
			)
		else if(is_audible)
			hologram.audible_message(
				message = msg,
				self_message = msg,
				audible_message_flags = EMOTE_MESSAGE,
				separation = space,
			)
		else if(is_visual)
			hologram.visible_message(
				message = msg,
				self_message = msg,
				visible_message_flags = EMOTE_MESSAGE|ALWAYS_SHOW_SELF_MESSAGE,
				separation = space,
			)
	// DOPPLER EDIT ADDITION END

	if(!isnull(user.client))
		var/dchatmsg = "<b>[user]</b> [msg]"
		for(var/mob/ghost as anything in GLOB.dead_mob_list - viewers(get_turf(user)))
			if(isnull(ghost.client) || isnewplayer(ghost))
				continue
			if(!(get_chat_toggles(ghost.client) & CHAT_GHOSTSIGHT))
				continue
			to_chat(ghost, span_emote("[FOLLOW_LINK(ghost, user)] [dchatmsg]"))

	return



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

	if(SEND_SIGNAL(user, COMSIG_MOB_EMOTE_COOLDOWN_CHECK, src.key, intentional) & COMPONENT_EMOTE_COOLDOWN_BYPASS)
		intentional = FALSE

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
 * To get the flags visible/audible messages for ran by the emote.
 *
 * Arguments:
 * * intentional - Bool that says whether the emote was forced (FALSE) or not (TRUE).
 *
 * Returns the additional message flags we should be using, if any.
 */
/datum/emote/proc/get_message_flags(intentional)
	// If we did it, we most often already know what's in it, so we try to avoid highlight clutter.
	return intentional ? BLOCK_SELF_HIGHLIGHT_MESSAGE : NONE

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
	if(!isliving(user))
		return .
	var/mob/living/living_user = user

	if(HAS_MIND_TRAIT(user, TRAIT_MIMING) && message_mime)
		. = message_mime
	if(isalienadult(user) && message_alien)
		. = message_alien
	else if(islarva(user) && message_larva)
		. = message_larva
	else if(isAI(user) && message_AI)
		. = message_AI
	else if(ismonkey(user) && message_monkey)
		. = message_monkey
	else if((iscyborg(user) || (living_user.mob_biotypes & MOB_ROBOTIC)) && message_robot)
		. = message_robot
	else if(isanimal_or_basicmob(user) && message_animal_or_basic)
		. = message_animal_or_basic

	return .

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
 * * params - Parameters added after the emote.
 *
 * Returns a bool about whether or not the user can run the emote.
 */
/datum/emote/proc/can_run_emote(mob/user, status_check = TRUE, intentional = FALSE, params)
	if(trait_required && !HAS_TRAIT(user, trait_required))
		return FALSE
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

	if(HAS_TRAIT(user, TRAIT_EMOTEMUTE))
		return FALSE

	return TRUE

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
	if(emote_type & EMOTE_AUDIBLE && !hands_use_check)
		if(HAS_TRAIT(user, TRAIT_MUTE))
			return FALSE
		if(ishuman(user))
			var/mob/living/carbon/human/loud_mouth = user
			if(HAS_MIND_TRAIT(loud_mouth, TRAIT_MIMING)) // vow of silence prevents outloud noises
				return FALSE
			if(!loud_mouth.get_organ_slot(ORGAN_SLOT_TONGUE))
				return FALSE

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
/atom/proc/manual_emote(text)
	if(!text)
		CRASH("Someone passed nothing to manual_emote(), fix it")

	log_message(text, LOG_EMOTE)
	visible_message(text, visible_message_flags = EMOTE_MESSAGE)
	return TRUE

/mob/manual_emote(text)
	if (stat != CONSCIOUS)
		return FALSE
	. = ..()
	if (!.)
		return FALSE
	if (!client)
		return TRUE
	var/ghost_text = "<b>[src]</b> [text]"
	var/origin_turf = get_turf(src)
	for(var/mob/ghost as anything in GLOB.dead_mob_list)
		if(!ghost.client || isnewplayer(ghost))
			continue
		if(get_chat_toggles(ghost.client) & CHAT_GHOSTSIGHT && !(ghost in viewers(origin_turf, null)))
			ghost.show_message("[FOLLOW_LINK(ghost, src)] [ghost_text]")
	return TRUE

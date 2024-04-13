/datum/status_effect/speech
	id = null
	alert_type = null
	remove_on_fullheal = TRUE
	tick_interval = -1
	/// If TRUE, TTS will say the original message rather than what we changed it to
	var/make_tts_message_original = FALSE
	/// If set, this will be appended to the TTS filter of the message
	var/tts_filter = ""

/datum/status_effect/speech/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/speech/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_TREAT_MESSAGE, PROC_REF(handle_message))
	return TRUE

/datum/status_effect/speech/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_TREAT_MESSAGE)

/**
 * Signal proc for [COMSIG_LIVING_TREAT_MESSAGE]
 *
 * Iterates over all of the characters in the passed message
 * and calls apply_speech() on each.
 */
/datum/status_effect/speech/proc/handle_message(datum/source, list/message_args)
	SIGNAL_HANDLER

	var/phrase = html_decode(message_args[TREAT_MESSAGE_ARG])
	if(!length(phrase))
		return

	var/final_phrase = ""
	var/original_char = ""

	for(var/i = 1, i <= length(phrase), i += length(original_char))
		original_char = phrase[i]
		final_phrase += apply_speech(original_char)

	if(final_phrase == phrase)
		return // No change was done, whatever

	if(length(tts_filter) > 0)
		message_args[TREAT_TTS_FILTER_ARG] += tts_filter
	if(make_tts_message_original)
		message_args[TREAT_TTS_MESSAGE_ARG] = message_args[TREAT_MESSAGE_ARG]

	message_args[TREAT_MESSAGE_ARG] = sanitize(final_phrase)

/**
 * Applies the speech effects on the past character, changing
 * the original_char into the modified_char.
 *
 * Return the modified_char to be reapplied to the message.
 */
/datum/status_effect/speech/proc/apply_speech(original_char)
	stack_trace("[type] didn't implement apply_speech.")
	return original_char

/datum/status_effect/speech/stutter
	id = "stutter"
	make_tts_message_original = TRUE
	tts_filter = "tremolo=f=10:d=0.8,rubberband=tempo=0.5"

	/// The probability of adding a stutter to any character
	var/stutter_prob = 80
	/// The chance of a four character stutter
	var/four_char_chance = 10
	/// The chance of a three character stutter
	var/three_char_chance = 20
	/// The chance of a two character stutter
	var/two_char_chance = 95
	/// Regex of characters we won't apply a stutter to
	var/static/regex/no_stutter

/datum/status_effect/speech/stutter/on_creation(mob/living/new_owner, ...)
	. = ..()
	if(!.)
		return
	if(!no_stutter)
		no_stutter = regex(@@[aeiouAEIOU ""''()[\]{}.!?,:;_`~-]@)

/datum/status_effect/speech/stutter/apply_speech(original_char)
	if(prob(stutter_prob) && !no_stutter.Find(original_char))
		if(prob(four_char_chance))
			return "[original_char]-[original_char]-[original_char]-[original_char]"
		if(prob(three_char_chance))
			return "[original_char]-[original_char]-[original_char]"
		if(prob(two_char_chance))
			return "[original_char]-[original_char]"

	return original_char

/datum/status_effect/speech/stutter/anxiety
	id = "anxiety_stutter"
	stutter_prob = 5
	four_char_chance = 4
	three_char_chance = 10
	two_char_chance = 100
	remove_on_fullheal = FALSE

/datum/status_effect/speech/stutter/anxiety/handle_message(datum/source, list/message_args)
	if(HAS_TRAIT(owner, TRAIT_FEARLESS) || HAS_TRAIT(owner, TRAIT_SIGN_LANG))
		stutter_prob = 0
	else
		var/datum/quirk/social_anxiety/host_quirk = owner.get_quirk(/datum/quirk/social_anxiety)
		stutter_prob = clamp(host_quirk?.calculate_mood_mod() * 0.5, 5, 50)
	return ..()

/datum/status_effect/speech/stutter/derpspeech
	id = "derp_stutter"
	/// The probability of making our message entirely uppercase + adding exclamations
	var/capitalize_prob = 50
	/// The probability of adding a stutter to the entire message, if we're not already stuttering
	var/message_stutter_prob = 15

/datum/status_effect/speech/stutter/derpspeech/handle_message(datum/source, list/message_args)

	var/message = html_decode(message_args[TREAT_MESSAGE_ARG])

	message = replacetext(message, " am ", " ")
	message = replacetext(message, " is ", " ")
	message = replacetext(message, " are ", " ")
	message = replacetext(message, "you", "u")
	message = replacetext(message, "help", "halp")
	message = replacetext(message, "grief", "grife")
	message = replacetext(message, "space", "spess")
	message = replacetext(message, "carp", "crap")
	message = replacetext(message, "reason", "raisin")

	if(prob(capitalize_prob))
		var/exclamation = pick("!", "!!", "!!!")
		message = uppertext(message)
		message += "[apply_speech(exclamation, exclamation)]"

	message_args[TREAT_MESSAGE_ARG] = message

	var/mob/living/living_source = source
	if(!isliving(source) || living_source.has_status_effect(/datum/status_effect/speech/stutter))
		return

	// If we're not stuttering, we have a chance of calling parent here, adding stutter effects
	if(prob(message_stutter_prob))
		return ..()

	// Otherwise just return and don't call parent, we already modified our speech
	return

/datum/status_effect/speech/slurring
	/// The chance that any given character in a message will be replaced with a common character
	var/common_prob = 25
	/// The chance that any given character in a message will be replaced with an uncommon character
	var/uncommon_prob = 10
	/// The chance that any given character will be entirely replaced with a new string / will have a string appended onto it
	var/replacement_prob = 5
	/// The chance that any given character will be doubled, or even tripled
	var/doubletext_prob = 0

	/// The file we pull text modifications from
	var/text_modification_file = ""

	/// Common replacements for characters - populated in on_creation
	var/list/common_replacements
	/// Uncommon replacements for characters - populated in on_creation
	var/list/uncommon_replacements
	/// Strings that fully replace a character - populated in on_creation
	var/list/string_replacements
	/// Strings that are appended to a character - populated in on_creation
	var/list/string_additions

/datum/status_effect/speech/slurring/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	. = ..()
	if(!.)
		return

	if(!text_modification_file)
		CRASH("[type] was created without a text modification file.")

	var/list/speech_changes = strings(text_modification_file, "replacements")
	common_replacements = speech_changes["characters"]["common"]
	uncommon_replacements = speech_changes["characters"]["uncommon"]
	string_replacements = speech_changes["string_replacements"]
	string_additions = speech_changes["string_additions"]

/datum/status_effect/speech/slurring/apply_speech(original_char)

	var/modified_char = original_char
	var/lower_char = LOWER_TEXT(modified_char)
	if(prob(common_prob) && (lower_char in common_replacements))
		var/to_replace = common_replacements[lower_char]
		if(islist(to_replace))
			modified_char = pick(to_replace)
		else
			modified_char = to_replace

	if(prob(uncommon_prob) && (modified_char in uncommon_replacements))
		var/to_replace = uncommon_replacements[modified_char]
		if(islist(to_replace))
			modified_char = pick(to_replace)
		else
			modified_char = to_replace

	if(prob(replacement_prob))
		var/replacements_len = length(string_replacements)
		var/additions_len = length(string_additions)
		if(replacements_len && additions_len)
			// Calculate the probability of grabbing a replacement vs an addition
			var/weight = (replacements_len + additions_len) / replacements_len * 100
			if(prob(weight))
				modified_char = pick(string_replacements)
			else
				modified_char += pick(string_additions)

		else if(replacements_len)
			modified_char = pick(string_replacements)

		else if(additions_len)
			modified_char += pick(string_additions)

	if(prob(doubletext_prob))
		if(prob(50))
			modified_char += "[modified_char]"
		else
			modified_char += "[modified_char][modified_char]"

	return modified_char

/datum/status_effect/speech/slurring/generic
	id = "generic_slurring"
	common_prob = 33
	uncommon_prob = 0
	replacement_prob = 5
	doubletext_prob = 10
	text_modification_file = "slurring_drunk_text.json"

/datum/status_effect/speech/slurring/drunk
	id = "drunk_slurring"
	// These defaults are updated when speech event occur.
	common_prob = -1
	uncommon_prob = -1
	replacement_prob = -1
	doubletext_prob = -1
	text_modification_file = "slurring_drunk_text.json"

/datum/status_effect/speech/slurring/drunk/handle_message(datum/source, list/message_args)
	var/current_drunkness = owner.get_drunk_amount()
	// These numbers are arbitarily picked
	// Common replacements start at about 20, and maxes out at about 85
	common_prob = clamp((current_drunkness * 0.8) - 16, 0, 50)
	// Uncommon replacements (burping) start at 50 and max out at 110 (when you are dying)
	uncommon_prob = clamp((current_drunkness * 0.2) - 10, 0, 12)
	// Replacements start at 20 and max out at about 60
	replacement_prob = clamp((current_drunkness * 0.4) - 8, 0, 12)
	// Double texting start out at about 25 and max out at about 60
	doubletext_prob = clamp((current_drunkness * 0.5) - 12, 0, 20)
	return ..()

/datum/status_effect/speech/slurring/cult
	id = "cult_slurring"
	common_prob = 50
	uncommon_prob = 25
	replacement_prob = 33
	doubletext_prob = 0
	text_modification_file = "slurring_cult_text.json"

	tts_filter = "rubberband=pitch=0.5,vibrato=5"

/datum/status_effect/speech/slurring/heretic
	id = "heretic_slurring"
	common_prob = 50
	uncommon_prob = 20
	replacement_prob = 30
	doubletext_prob = 5
	text_modification_file = "slurring_heretic_text.json"

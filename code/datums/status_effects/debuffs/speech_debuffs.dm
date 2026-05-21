/datum/status_effect/speech
	id = STATUS_EFFECT_ID_ABSTRACT
	alert_type = null
	remove_on_fullheal = TRUE
	tick_interval = STATUS_EFFECT_NO_TICK
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
	var/list/words = splittext(phrase, " ")
	var/list/new_words = list()
	for(var/i in 1 to length(words))
		new_words += apply_speech(words[i], i)
	final_phrase = jointext(new_words, " ")

	if(final_phrase == phrase)
		return // No change was done, whatever

	if(length(tts_filter) > 0)
		message_args[TREAT_TTS_FILTER_ARG] += tts_filter
	if(make_tts_message_original)
		message_args[TREAT_TTS_MESSAGE_ARG] = message_args[TREAT_MESSAGE_ARG]

	message_args[TREAT_MESSAGE_ARG] = sanitize(final_phrase)

/**
 * Applies the speech effects on the past character, changing
 * the original_word into some modified_word
 *
 * Return the newly modified word
 */
/datum/status_effect/speech/proc/apply_speech(original_word, index)
	stack_trace("[type] didn't implement apply_speech.")
	return original_word

/datum/status_effect/speech/stutter
	id = "stutter"
	make_tts_message_original = TRUE
	tts_filter = "tremolo=f=10:d=0.8,rubberband=tempo=0.5"

	/// The probability of adding a stutter to any character
	var/stutter_prob = 75
	/// The chance of a four character stutter
	var/four_char_chance = 10
	/// The chance of a three character stutter
	var/three_char_chance = 20
	/// The chance of a two character stutter
	var/two_char_chance = 90
	/// Regex to apply generically to stuttered words
	/// * 1st capture group is any leading invalid characters (can be empty)
	/// * 2nd capture group is either a digraph (th, qu, ch) or a consonant
	/// * 3rd capture group is the rest of the word (can be empty)
	VAR_FINAL/static/regex/stutter_regex

/datum/status_effect/speech/stutter/on_creation(mob/living/new_owner, ...)
	stutter_regex ||= regex(@@^([\s"'()[\]{}.!?,:;_`~-]*\b)([^aeoiuh\d]h|qu|[^\d])(.*)@, "i")
	return ..()

/datum/status_effect/speech/stutter/apply_speech(original_word, index)
	if(!prob(stutter_prob))
		return original_word

	if(stutter_regex.Find(original_word))
		return "[stutter_regex.group[1]][stutter_char(stutter_regex.group[2])][stutter_regex.group[3]]"

	return original_word // i give up

/datum/status_effect/speech/stutter/proc/stutter_char(some_char)
	if(prob(four_char_chance))
		return "[some_char]-[some_char]-[some_char]-[some_char]"
	if(prob(three_char_chance))
		return "[some_char]-[some_char]-[some_char]"
	if(prob(two_char_chance))
		return "[some_char]-[some_char]"

	return some_char

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
		message += "[stutter_char(exclamation)]"

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

	/// Regex for characters we won't apply any slurring to
	var/static/regex/no_slur

	/// If the last character we processed was a replacement, don't do another replacement right after it
	VAR_PRIVATE/replacement_dupe_check = FALSE

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

	no_slur ||= regex(@@[ "'()[\]{}.!?,:;_`~-]@)

/datum/status_effect/speech/slurring/apply_speech(original_word, index)
	var/original_char = ""
	var/modified_word = ""
	for(var/i = 1, i <= length(original_word), i += length(original_char))
		original_char = original_word[i]
		modified_word += slur_character(original_char, i)
	return modified_word

/datum/status_effect/speech/slurring/proc/slur_character(original_char, index)
	var/modified_char = original_char
	var/allow_slurring = index != 1 && !no_slur.Find(modified_char)
	var/lower_char = LOWER_TEXT(modified_char)
	if(prob(common_prob) && (lower_char in common_replacements))
		var/to_replace = common_replacements[lower_char]
		modified_char = islist(to_replace) ? pick(to_replace) : to_replace
		replacement_dupe_check = FALSE

	else if(prob(uncommon_prob) && (modified_char in uncommon_replacements))
		var/to_replace = uncommon_replacements[modified_char]
		modified_char = islist(to_replace) ? pick(to_replace) : to_replace
		replacement_dupe_check = FALSE

	else if(allow_slurring) // Don't do replacements on the first character, or punctuation
		if(!replacement_dupe_check && prob(replacement_prob))
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
			replacement_dupe_check = TRUE

		else if(prob(doubletext_prob))
			modified_char += "[modified_char][prob(50) ? "" : modified_char]"
			replacement_dupe_check = FALSE

	else
		// If we don't allow replacements we don't want the next character to be a replacement either
		// This makes some more coherent speech by disallowing structures like "Y'''e"
		replacement_dupe_check = TRUE

	return modified_char

/datum/status_effect/speech/slurring/generic
	id = "generic_slurring"
	common_prob = 33
	uncommon_prob = 0
	replacement_prob = 24
	doubletext_prob = 40
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
	common_prob = clamp((current_drunkness * 0.8) - 16, 4, 50)
	// Uncommon replacements (burping) start at 50 and max out at 110 (when you are dying)
	uncommon_prob = clamp((current_drunkness * 0.3) - 10, 0, 12)
	// Replacements start at 20 and max out at about 60
	replacement_prob = clamp((current_drunkness * 0.6) - 8, 0, 12)
	// Double texting start out at about 25 and max out at about 60
	doubletext_prob = clamp((current_drunkness * 0.8) - 8, 2, 50)
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

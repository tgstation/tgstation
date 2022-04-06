/datum/status_effect/speech


/datum/status_effect/speech/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	return ..()

/datum/status_effect/speech/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_TREAT_MESSAGE, .proc/handle_message)
	return TRUE

/datum/status_effect/speech/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_TREAT_MESSAGE)

/datum/status_effect/speech/proc/handle_message(datum/source, list/message_args)
	SIGNAL_HANDLER

	var/phrase = html_decode(message_args["message"])
	if(!length(phrase))
		return

	var/final_phrase = ""

	for(var/i = 1, i <= length(phrase), i += length(original_char))
		var/original_char = phrase[i]
		var/modified_char = original_char

		final_phrase += apply_speech(original_char, modified_char)

	message_args["message"] = sanitize(final_phrase)

/datum/status_effect/speech/proc/apply_speech(original_char, modified_char)
	stack_trace("[type] didn't implement apply_speech.")
	return original_char

/datum/status_effect/speech/stutter
	id = "stutter"
	/// The probability of adding a stutter to any character
	var/stutter_prob = 80
	/// Regex of characters we won't apply a stutter to
	var/static/regex/no_stutter

/datum/status_effect/speech/stutter/on_creation(mob/living/new_owner, ...)
	. = ..()
	if(!.)
		return
	if(!no_stutter)
		no_stutter = regex(@@[aeiouAEIOU ""''()[\]{}.!?,:;_`~-]@)

/datum/status_effect/speech/stutter/apply_speech(original_char, modified_char)
	if(prob(stutter_prob) && !no_stutter.Find(original_char))
		if(prob(10))
			modified_char = "[modified_char]-[modified_char]-[modified_char]-[modified_char]"
		else if(prob(20))
			modified_char = "[modified_char]-[modified_char]-[modified_char]"
		else if (prob(95))
			modified_char = "[modified_char]-[modified_char]"
		else
			modified_char = ""

	return modified_char

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
	var/text_modification_file = "slurring_text.json"

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

	var/list/speech_changes = strings(text_modification_file)
	common_replacements = speech_changes["characters"]["common"]
	uncommon_replacements = speech_changes["characters"]["uncommon"]
	string_replacements = speech_changes["string_replacements"]
	string_additions = speech_changes["string_additions"]

/datum/status_effect/speech/slurring/apply_speech(original_char, modified_char)
	if(prob(common_prob) && (modified_char in common_replacements))
		var/to_replace = common_replacements[modified_char]
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
			var/weight = (length(string_replacements) + length(string_additions)) / length(string_replacements) * 100
			if(prob(weight))
				modified_char = pick(string_replacements)
			else
				modified_char += pick(string_additions)

		else if(replacements_len)
			modified_char = pick(string_replacements)

		else if(string_additions)
			modified_char += pick(string_additions)

	if(prob(doubletext_prob))
		if(prob(50))
			modified_char += "[modified_char]"
		else
			modified_char += "[modified_char][modified_char]"

	return modified_char

/datum/status_effect/speech/slurring/normal
	id = "slurring"
	common_prob = 33
	uncommon_prob = 5
	replacement_prob = 5
	doubletext_prob = 10
	text_modification_file = "slurring_text.json"

/datum/status_effect/speech/slurring/cult
	id = "cult_slurring"
	common_prob = 50
	uncommon_prob = 25
	replacement_prob = 33
	doubletext_prob = 0
	text_modification_file = "slurring_cult_text.json"

/datum/status_effect/speech/slurring/heretic
	id = "heretic_slurring"

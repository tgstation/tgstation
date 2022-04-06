/datum/status_effect/slurring
	/// The chance that any given character in a message will be replaced with a common character
	var/common_prob = 33
	/// The chance that any given character in a message will be replaced with an uncommon character
	var/uncommon_prob = 5
	/// The chance that any given character will be entirely replaced with a new string / will have a string appended onto it
	var/replacement_prob = 5
	/// The chance that any given character will be doubled, or even tripled
	var/doubletext_prob = 10

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

/datum/status_effect/slurring/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration

	. = ..()
	if(!.)
		return

	var/list/speech_changes = strings(text_modification_file)
	common_replacements = speech_changes["characters"]["common"]
	uncommon_replacements = speech_changes["characters"]["uncommon"]
	string_replacements = speech_changes["string_replacements"]
	string_additions = speech_changes["string_additions"]

/datum/status_effect/slurring/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_TREAT_MESSAGE, .proc/handle_message)
	return TRUE

/datum/status_effect/slurring/on_remove()
	UnregisterSignal(owner, COMSIG_LIVING_TREAT_MESSAGE)

/datum/status_effect/slurring/proc/handle_message(datum/source, list/message_args)
	SIGNAL_HANDLER

	message_args["message"] = slur(message_args["message"])

/datum/status_effect/slurring/proc/slur(phrase)
	var/final_phrase = ""

	phrase = html_decode(phrase)
	var/original_char = ""
	var/modified_char = ""

	for(var/i = 1, i <= length(phrase), i += length(rawchar))
		original_char = phrase[i]
		modified_char = original_char

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
			var/additions_len = len(string_additions)
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

		final_phrase += modified_char

	return sanitize(final_phrase)

/datum/status_effect/slurring/normal
	id = "slurring"
	common_prob = 33
	uncommon_prob = 5
	replacement_prob = 5
	doubletext_prob = 10
	text_modification_file = "slurring_text.json"

/datum/status_effect/slurring/cult
	id = "cult_slurring"
	common_prob = 50
	uncommon_prob = 25
	replacement_prob = 33
	doubletext_prob = 0
	text_modification_file = "slurring_cult_text.json"

/datum/status_effect/slurring/heretic
	id = "heretic_slurring"

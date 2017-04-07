#define SCRAMBLE_CACHE_LEN 20

/*
	Datum based languages. Easily editable and modular.
*/

/datum/language
	var/name = "an unknown language"  // Fluff name of language if any.
	var/desc = "A language."          // Short description for 'Check Languages'.
	var/speech_verb = "says"          // 'says', 'hisses', 'farts'.
	var/ask_verb = "asks"             // Used when sentence ends in a ?
	var/exclaim_verb = "exclaims"     // Used when sentence ends in a !
	var/whisper_verb = "whispers"     // Optional. When not specified speech_verb + quietly/softly is used instead.
	var/list/signlang_verb = list("signs", "gestures") // list of emotes that might be displayed if this language has NONVERBAL or SIGNLANG flags
	var/key = "x"                     // Character used to speak in language
	var/flags                         // Various language flags.
	var/list/syllables                // Used when scrambling text for a non-speaker.
	var/list/sentence_chance = 5      // Likelihood of making a new sentence after each syllable.
	var/list/space_chance = 55        // Likelihood of getting a space in the random scramble string
	var/list/spans = list()
	var/static/list/scramble_cache = list()
	var/default_priority = 0          // the language that an atom knows with the highest "default_priority" is selected by default.

/datum/language/proc/get_random_name(gender, name_count=2, syllable_count=4, syllable_divisor=2)
	if(!syllables || !syllables.len)
		if(gender==FEMALE)
			return capitalize(pick(first_names_female)) + " " + capitalize(pick(last_names))
		else
			return capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))

	var/full_name = ""
	var/new_name = ""

	for(var/i in 0 to name_count)
		new_name = ""
		var/Y = rand(Floor(syllable_count/syllable_divisor), syllable_count)
		for(var/x in Y to 0)
			new_name += pick(syllables)
		full_name += " [capitalize(lowertext(new_name))]"

	return "[trim(full_name)]"

/datum/language/proc/scramble(input)

	if(!syllables || !syllables.len)
		return stars(input)

	// If the input is cached already, move it to the end of the cache and return it
	var/lookup = scramble_cache[input]
	if(lookup)
		scramble_cache -= input
		scramble_cache[input] = lookup
		return lookup

	var/input_size = length(input)
	var/scrambled_text = ""
	var/capitalize = TRUE

	while(length(scrambled_text) < input_size)
		var/next = pick(syllables)
		if(capitalize)
			next = capitalize(next)
			capitalize = FALSE
		scrambled_text += next
		var/chance = rand(100)
		if(chance <= sentence_chance)
			scrambled_text += ". "
			capitalize = TRUE
		else if(chance > sentence_chance && chance <= space_chance)
			scrambled_text += " "

	scrambled_text = trim(scrambled_text)
	var/ending = copytext(scrambled_text, length(scrambled_text))
	if(ending == ".")
		scrambled_text = copytext(scrambled_text,1,length(scrambled_text)-1)
	var/input_ending = copytext(input, input_size)
	if(input_ending in list("!","?","."))
		scrambled_text += input_ending

	// Add it to cache, cutting old entries if the list is too long
	scramble_cache[input] = scrambled_text
	if(scramble_cache.len > SCRAMBLE_CACHE_LEN)
		scramble_cache.Cut(1, scramble_cache.len-SCRAMBLE_CACHE_LEN-1)

	return scrambled_text

/datum/language/proc/get_spoken_verb(msg_end)
	switch(msg_end)
		if("!")
			return exclaim_verb
		if("?")
			return ask_verb
	return speech_verb

#undef SCRAMBLE_CACHE_LEN

//These are all minor mutations that affect your speech somehow.
//Individual ones aren't commented since their functions should be evident at a glance
// no they arent bro

#define ALPHABET list("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z")
#define VOWELS list("a", "e", "i", "o", "u")
#define CONSONANTS (ALPHABET - VOWELS)

/datum/mutation/human/nervousness
	name = "Nervousness"
	desc = "Causes the holder to stutter."
	instability = NEGATIVE_STABILITY_MINI
	quality = MINOR_NEGATIVE
	text_gain_indication = span_danger("You feel nervous.")

/datum/mutation/human/nervousness/on_life(seconds_per_tick, times_fired)
	if(SPT_PROB(5, seconds_per_tick))
		owner.set_stutter_if_lower(20 SECONDS)

/datum/mutation/human/wacky
	name = "Wacky"
	desc = "You are not a clown. You are the entire circus."
	instability = NEGATIVE_STABILITY_MINI
	quality = MINOR_NEGATIVE
	text_gain_indication = span_sans(span_notice("You feel an off sensation in your voicebox."))
	text_lose_indication = span_notice("The off sensation passes.")

/datum/mutation/human/wacky/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/human/wacky/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/human/wacky/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	speech_args[SPEECH_SPANS] |= SPAN_SANS

/datum/mutation/human/heckacious
	name = "heckacious larincks"
	desc = "duge what is WISH your words man..........."
	quality = MINOR_NEGATIVE
	text_gain_indication = span_sans("aw SHIT man. your throat feels like FUCKASS.")
	text_lose_indication = span_notice("The demonic entity possessing your larynx has finally released its grasp.")
	locked = TRUE

/datum/mutation/human/heckacious/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	RegisterSignal(owner, COMSIG_LIVING_TREAT_MESSAGE, PROC_REF(handle_caps))
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/human/heckacious/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	UnregisterSignal(owner, list(COMSIG_LIVING_TREAT_MESSAGE, COMSIG_MOB_SAY))

/datum/mutation/human/heckacious/proc/handle_caps(atom/movable/source, list/message_args)
	SIGNAL_HANDLER
	message_args[TREAT_CAPITALIZE_MESSAGE] = FALSE

/datum/mutation/human/heckacious/proc/handle_speech(datum/source, list/speech_args)

	var/message = speech_args[SPEECH_MESSAGE]
	if(!message)
		return
	// Split for swapping purposes
	message = " [message] "

	// Splitting up each word in the text to manually apply our intended changes
	var/list/message_words = splittext(message, " ")
	// What we use in the end
	var/list/edited_message_words

	for(var/editing_word in message_words)
		if(editing_word == " " || editing_word == "" )
			continue
		// Used to replace the original later
		var/og_word = editing_word
		// Iterating through each replaceable-string in the .json
		var/list/static/super_wacky_words = strings("heckacious.json", "heckacious")

		// If the word doesn't get replaced we might do something with it later
		var/word_edited
		for(var/key in super_wacky_words)
			var/value = super_wacky_words[key]
			// If list, pick one value from said list
			if(islist(value))
				value = pick(value)
			editing_word = replacetextEx(editing_word, "[uppertext(key)]", "[uppertext(value)]")
			editing_word = replacetextEx(editing_word, "[capitalize(key)]", "[capitalize(value)]")
			editing_word = replacetextEx(editing_word, "[key]", "[value]")
			// Enable if we actually found something to change
			if(editing_word != og_word)
				word_edited = TRUE

		// Random caps
		if(prob(10))
			editing_word = prob(85) ? uppertext(editing_word) : LOWER_TEXT(editing_word)
		// some times....... we add DOTS...
		if(prob(10))
			for(var/dotnum in 1 to rand(2, 8))
				editing_word += "."
		// change for bold/italics/underline as well!
		if(prob(10))
			var/extra_emphasis = pick("+", "_", "|")
			editing_word = extra_emphasis + editing_word + extra_emphasis

		// If no replacement we do it manually
		if(!word_edited)
			if(prob(65))
				editing_word = replacetext(editing_word, pick(VOWELS), pick(VOWELS))
			// Many more consonants, double it!
			for(var/i in 1 to rand(1, 2))
				editing_word = replacetext(editing_word, pick(CONSONANTS), pick(CONSONANTS))
			// rarely, lettter is DOUBBLED...
			var/patchword = ""
			for(var/letter in 1 to length(editing_word))
				if(prob(92))
					patchword += editing_word[letter]
					continue
				patchword += replacetext(editing_word[letter], "", editing_word[letter] + editing_word[letter])
			editing_word = patchword

		LAZYADD(edited_message_words, editing_word)

	var/edited_message = jointext(edited_message_words, " ")

	message = trim(edited_message)

	speech_args[SPEECH_MESSAGE] = message

/datum/mutation/human/mute
	name = "Mute"
	desc = "Completely inhibits the vocal section of the brain."
	instability = NEGATIVE_STABILITY_MAJOR
	quality = NEGATIVE
	text_gain_indication = span_danger("You feel unable to express yourself at all.")
	text_lose_indication = span_danger("You feel able to speak freely again.")

/datum/mutation/human/mute/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_MUTE, GENETIC_MUTATION)

/datum/mutation/human/mute/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_MUTE, GENETIC_MUTATION)

/datum/mutation/human/unintelligible
	name = "Unintelligible"
	desc = "Partially inhibits the vocal center of the brain, severely distorting speech."
	instability = NEGATIVE_STABILITY_MODERATE
	quality = NEGATIVE
	text_gain_indication = span_danger("You can't seem to form any coherent thoughts!")
	text_lose_indication = span_danger("Your mind feels more clear.")

/datum/mutation/human/unintelligible/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_UNINTELLIGIBLE_SPEECH, GENETIC_MUTATION)

/datum/mutation/human/unintelligible/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_UNINTELLIGIBLE_SPEECH, GENETIC_MUTATION)

/datum/mutation/human/swedish
	name = "Swedish"
	desc = "A horrible mutation originating from the distant past. Thought to be eradicated after the incident in 2037."
	instability = NEGATIVE_STABILITY_MINI
	quality = MINOR_NEGATIVE
	text_gain_indication = span_notice("You feel Swedish, however that works.")
	text_lose_indication = span_notice("The feeling of Swedishness passes.")
	var/static/list/language_mutilation = list("w" = "v", "j" = "y", "bo" = "bjo", "a" = list("å","ä","æ","a"), "o" = list("ö","ø","o"))

/datum/mutation/human/swedish/New(class, timer, datum/mutation/human/copymut)
	. = ..()
	AddComponent(/datum/component/speechmod, replacements = language_mutilation, end_string = list("",", bork",", bork, bork"), end_string_chance = 30)

/datum/mutation/human/chav
	name = "Chav"
	desc = "Unknown"
	instability = NEGATIVE_STABILITY_MINI
	quality = MINOR_NEGATIVE
	text_gain_indication = span_notice("Ye feel like a reet prat like, innit?")
	text_lose_indication = span_notice("You no longer feel like being rude and sassy.")

/datum/mutation/human/chav/New(class, timer, datum/mutation/human/copymut)
	. = ..()
	AddComponent(/datum/component/speechmod, replacements = strings("chav_replacement.json", "chav"), end_string = ", mate", end_string_chance = 30)

/datum/mutation/human/elvis
	name = "Elvis"
	desc = "A terrifying mutation named after its 'patient-zero'."
	instability = NEGATIVE_STABILITY_MINI
	quality = MINOR_NEGATIVE
	text_gain_indication = span_notice("You feel pretty good, honeydoll.")
	text_lose_indication = span_notice("You feel a little less conversation would be great.")

/datum/mutation/human/chav/New(class, timer, datum/mutation/human/copymut)
	. = ..()
	AddComponent(/datum/component/speechmod, replacements = strings("elvis_replacement.json", "elvis"))

/datum/mutation/human/elvis/on_life(seconds_per_tick, times_fired)
	switch(pick(1,2))
		if(1)
			if(SPT_PROB(7.5, seconds_per_tick))
				var/list/dancetypes = list("swinging", "fancy", "stylish", "20'th century", "jivin'", "rock and roller", "cool", "salacious", "bashing", "smashing")
				var/dancemoves = pick(dancetypes)
				owner.visible_message("<b>[owner]</b> busts out some [dancemoves] moves!")
		if(2)
			if(SPT_PROB(7.5, seconds_per_tick))
				owner.visible_message("<b>[owner]</b> [pick("jiggles their hips", "rotates their hips", "gyrates their hips", "taps their foot", "dances to an imaginary song", "jiggles their legs", "snaps their fingers")]!")

/datum/mutation/human/stoner
	name = "Stoner"
	desc = "A common mutation that severely decreases intelligence."
	quality = NEGATIVE
	text_gain_indication = span_notice("You feel...totally chill, man!")
	text_lose_indication = span_notice("You feel like you have a better sense of time.")

/datum/mutation/human/stoner/on_acquiring(mob/living/carbon/human/owner)
	..()
	owner.grant_language(/datum/language/beachbum, source = LANGUAGE_STONER)
	owner.add_blocked_language(subtypesof(/datum/language) - /datum/language/beachbum, LANGUAGE_STONER)

/datum/mutation/human/stoner/on_losing(mob/living/carbon/human/owner)
	..()
	owner.remove_language(/datum/language/beachbum, source = LANGUAGE_STONER)
	owner.remove_blocked_language(subtypesof(/datum/language) - /datum/language/beachbum, LANGUAGE_STONER)

/datum/mutation/human/medieval
	name = "Medieval"
	desc = "A horrible mutation originating from the distant past, thought to have once been a common gene in all of old world Europe."
	instability = NEGATIVE_STABILITY_MINI
	quality = MINOR_NEGATIVE
	text_gain_indication = span_notice("You feel like seeking the holy grail!")
	text_lose_indication = span_notice("You no longer feel like seeking anything.")

/datum/mutation/human/medieval/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/human/medieval/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/human/medieval/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message)
		message = " [message] "
		var/list/medieval_words = strings("medieval_replacement.json", "medieval")
		var/list/startings = strings("medieval_replacement.json", "startings")
		for(var/key in medieval_words)
			var/value = medieval_words[key]
			if(islist(value))
				value = pick(value)
			if(uppertext(key) == key)
				value = uppertext(value)
			if(capitalize(key) == key)
				value = capitalize(value)
			message = replacetextEx(message,regex("\b[REGEX_QUOTE(key)]\b","ig"), value)
		message = trim(message)
		var/chosen_starting = pick(startings)
		message = "[chosen_starting] [message]"

		speech_args[SPEECH_MESSAGE] = message

/datum/mutation/human/piglatin
	name = "Pig Latin"
	desc = "Historians say back in the 2020's humanity spoke entirely in this mystical language."
	instability = NEGATIVE_STABILITY_MINI
	quality = MINOR_NEGATIVE
	text_gain_indication = span_notice("Omethingsay eelsfay offyay.")
	text_lose_indication = span_notice("The off sensation passes.")

/datum/mutation/human/piglatin/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/human/piglatin/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/human/piglatin/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/spoken_message = speech_args[SPEECH_MESSAGE]
	spoken_message = piglatin_sentence(spoken_message)
	speech_args[SPEECH_MESSAGE] = spoken_message

#undef ALPHABET
#undef VOWELS
#undef CONSONANTS

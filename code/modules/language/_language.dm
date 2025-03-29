/// Last 50 spoken (uncommon) words will be cached before we start cycling them out (re-randomizing them)
#define SCRAMBLE_CACHE_LEN 50
/// Last 20 spoken sentences will be cached before we start cycling them out (re-randomizing them)
#define SENTENCE_CACHE_LEN 20

/// Datum based languages. Easily editable and modular.
/datum/language
	/// Fluff name of language if any.
	var/name = "an unknown language"
	/// Short description for 'Check Languages'.
	var/desc = "A language."
	/// Character used to speak in language
	/// If key is null, then the language isn't real or learnable.
	var/key
	/// Various language flags.
	var/flags = NONE
	/// Used when scrambling text for a non-speaker.
	var/list/syllables
	/// List of characters that will randomly be inserted between syllables.
	var/list/special_characters

	// These modify how syllables are combined.
	/// Likelihood of making a new sentence after each syllable.
	var/sentence_chance = 2
	/// Likelihood of making a new sentence after each word.
	var/between_word_sentence_chance = 0
	/// Likelihood of adding a space between syllables.
	var/space_chance = 20
	/// Likelyhood of adding a space between words.
	var/between_word_space_chance = 100
	/// Scramble word interprets the word as this much longer than it really is (low end)
	/// You can set this to an arbitarily large negative number to make all words only one syllable.
	var/additional_syllable_low = -1
	/// Scramble word interprets the word as this much longer than it really is (high end)
	/// You can set this to an arbitarily large negative number to make all words only one syllable.
	var/additional_syllable_high = 3

	/// Spans to apply from this language
	var/list/spans
	/**
	 * Cache of recently scrambled text
	 * This allows commonly reused words to not require a full re-scramble every time.
	 * Is limited to the last SCRAMBLE_CACHE_LEN words spoken. After surpassing this limit,
	 * the oldest word will be removed from the cache and rescrambled if spoken again.
	 *
	 * Case insensitive, punctuation insensitive.
	 */
	VAR_PRIVATE/list/scramble_cache = list()
	/**
	 * Scramble cache, but for the 1000 most common words in the English language.
	 * These are never rescrambled, so they will consistently be the same thing.
	 *
	 * Case insensitive, punctuation insensitive.
	 */
	VAR_PRIVATE/list/most_common_cache = list()
	/**
	 * Cache of recently spoken sentences
	 * So if one person speaks over the radio, everyone hears the same thing.
	 *
	 * This is an assoc list [sentence] = [key, scrambled_text]
	 * Where key is a string that is used to determine context about the listener (like what languages they know)
	 *
	 * Case sensitive, punctuation sensitive.
	 */
	VAR_PRIVATE/list/last_sentence_cache = list()

	/// The language that an atom knows with the highest "default_priority" is selected by default.
	var/default_priority = 0
	/// If TRUE, when generating names, we will always use the default human namelist, even if we have syllables set.
	/// This is to be used for languages with very outlandish syllable lists (like pirates).
	var/always_use_default_namelist = FALSE
	/// Icon displayed in the chat window when speaking this language.
	/// if you are seeing someone speak popcorn language, then something is wrong.
	var/icon = 'icons/ui/chat/language.dmi'
	/// Icon state displayed in the chat window when speaking this language.
	var/icon_state = "unknown"

	/// By default, random names picks this many names
	var/default_name_count = 2
	/// By default, random names picks this many syllables (min)
	var/default_name_syllable_min = 2
	/// By default, random names picks this many syllables (max)
	var/default_name_syllable_max = 4
	/// What char to place in between randomly generated names
	var/random_name_spacer = " "

	/**
	 * Assoc Lazylist of other language types that would have a degree of mutual understanding with this language.
	 * For example, you could do `list(/datum/language/common = 50)` to say that this language has a 50% chance to understand common words
	 * And yeah if you give a 100% chance, they can basically just understand the language.
	 * Not sure why you would do that though.
	 */
	var/list/mutual_understanding

// Primarily for debugging, allows for easy iteration and testing of languages.
/datum/language/vv_edit_var(var_name, var_value)
	. = ..()
	var/list/delete_cache = list(
		NAMEOF(src, additional_syllable_high),
		NAMEOF(src, additional_syllable_low),
		NAMEOF(src, between_word_sentence_chance),
		NAMEOF(src, between_word_space_chance),
		NAMEOF(src, sentence_chance),
		NAMEOF(src, space_chance),
		NAMEOF(src, special_characters),
		NAMEOF(src, syllables),
	)
	if(var_name in delete_cache)
		scramble_cache.Cut()
		most_common_cache.Cut()
		last_sentence_cache.Cut()

/// Checks whether we should display the language icon to the passed hearer.
/datum/language/proc/display_icon(atom/movable/hearer)
	var/understands = hearer.has_language(src.type)
	if((flags & LANGUAGE_HIDE_ICON_IF_UNDERSTOOD) && understands)
		return FALSE
	if((flags & LANGUAGE_HIDE_ICON_IF_NOT_UNDERSTOOD) && !understands)
		return FALSE
	return TRUE

/// Returns the icon to display in the chat window when speaking this language.
/datum/language/proc/get_icon()
	var/datum/asset/spritesheet_batched/sheet = get_asset_datum(/datum/asset/spritesheet_batched/chat)
	return sheet.icon_tag("language-[icon_state]")

/// Simple helper for getting a default firstname lastname
/datum/language/proc/default_name(gender = NEUTER)
	if(gender != MALE && gender != FEMALE)
		gender = pick(MALE, FEMALE)
	if(gender == FEMALE)
		return capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))
	return capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))


/**
 * Generates a random name this language would use.
 *
 * * gender: What gender to generate from, if neuter / plural coin flips between male and female
 * * name_count: How many names to generate in, by default 2, for firstname lastname
 * * syllable_count: How many syllables to generate in each name, min
 * * syllable_max: How many syllables to generate in each name, max
 * * force_use_syllables: If the name should be generated from the syllables list.
 * Only used for subtypes which implement custom name lists. Also requires the language has syllables set.
 */
/datum/language/proc/get_random_name(
	gender = NEUTER,
	name_count = default_name_count,
	syllable_min = default_name_syllable_min,
	syllable_max = default_name_syllable_max,
	force_use_syllables = FALSE,
)
	if(gender != MALE && gender != FEMALE)
		gender = pick(MALE, FEMALE)
	if(!length(syllables) || always_use_default_namelist)
		return default_name(gender)

	var/list/full_name = list()
	for(var/i in 1 to name_count)
		var/new_name = ""
		for(var/j in 1 to rand(default_name_syllable_min, default_name_syllable_max))
			new_name += pick_weight_recursive(syllables)
		full_name += capitalize(LOWER_TEXT(new_name))

	return jointext(full_name, random_name_spacer)

/// Generates a random name, and attempts to ensure it is unique (IE, no other mob in the world has it)
/datum/language/proc/get_random_unique_name(...)
	var/result = get_random_name(arglist(args))
	for(var/i in 1 to 10)
		if(!findname(result))
			break
		result = get_random_name(arglist(args))

	return result

/// Checks the word cache for a word
/datum/language/proc/read_word_cache(input)
	SHOULD_NOT_OVERRIDE(TRUE)
	// we generally want "The" and "the" to translate to the same thing.
	// so we lowercase everything, making it case insensitive.
	var/lowertext_input = LOWER_TEXT(input)
	if(most_common_cache[lowertext_input])
		return most_common_cache[lowertext_input]

	. = scramble_cache[lowertext_input]
	if(. && scramble_cache[1] != lowertext_input)
		// bumps it to the top of the cache
		scramble_cache -= lowertext_input
		scramble_cache[lowertext_input] = .
	return .

/// Adds a word to the cache
/datum/language/proc/write_word_cache(input, scrambled_text)
	SHOULD_NOT_OVERRIDE(TRUE)
	var/lowertext_input = LOWER_TEXT(input)
	// The most common words are always cached
	if(GLOB.most_common_words[lowertext_input])
		most_common_cache[lowertext_input] = scrambled_text
		return
	// Add it to cache, cutting old entries if the list is too long
	scramble_cache[lowertext_input] = scrambled_text
	if(length(scramble_cache) > SCRAMBLE_CACHE_LEN)
		scramble_cache.Cut(1, scramble_cache.len - SCRAMBLE_CACHE_LEN + 1)

/// Checks the sentence cache for a sentence
/datum/language/proc/read_sentence_cache(input)
	SHOULD_NOT_OVERRIDE(TRUE)
	// the only handling we do is capitalizing the first word, as say auto-capitalizes the first word anyway
	// the actual structure of the sentence is otherwise case sensitive so it's preserved
	var/input_capitalized = capitalize(input)
	. = last_sentence_cache[input_capitalized]
	if(. && last_sentence_cache[1] != input_capitalized)
		// bumps it to the top of the cache (don't anticipate this happening often)
		last_sentence_cache -= input_capitalized
		last_sentence_cache[input_capitalized] = .
	return .

/// Adds a sentence to the cache, though the sentence should be modified with a key
/datum/language/proc/write_sentence_cache(input, key, result_scramble)
	SHOULD_NOT_OVERRIDE(TRUE)
	var/input_capitalized = capitalize(input)
	// Add to the cache (the cache being an assoc list of assoc lists), cutting old entries if the list is too long
	LAZYSET(last_sentence_cache[input_capitalized], key, result_scramble)
	if(length(last_sentence_cache) > SENTENCE_CACHE_LEN)
		last_sentence_cache.Cut(1, last_sentence_cache.len - SENTENCE_CACHE_LEN + 1)

/**
 * Scrambles a sentence in this language.
 *
 * Takes into account any languages the hearer knows that has mutual understanding with this language.
 */
/datum/language/proc/scramble_sentence(input, list/mutual_languages)
	var/cache_key = "[mutual_languages?[type] || 0]-understanding"
	var/list/cache = read_sentence_cache(cache_key)
	if(cache?[cache_key])
		return cache[cache_key]

	var/list/real_words = splittext(input, " ")
	var/list/scrambled_words = list()
	for(var/word in real_words)
		var/translate_prob = mutual_languages?[type] || 0
		var/base_word = strip_outer_punctuation(word)
		if(translate_prob > 0)
			// the probability of managing to understand a word is based on how common it is
			// 1000 words in the list, so words outside the list are just treated as "the 1500th most common word"
			var/commonness = GLOB.most_common_words[LOWER_TEXT(base_word)] || 1500
			translate_prob += (translate_prob * 0.2 * (1 - (min(commonness, 1500) / 500)))
			if(prob(translate_prob))
				scrambled_words += base_word
				continue

		scrambled_words += scramble_word(base_word)

	// start building the new sentence. first word is capitalized and otherwise untouched
	var/sentence = capitalize(popleft(scrambled_words))
	for(var/word in scrambled_words)
		if(prob(between_word_sentence_chance))
			sentence += ". "
			word = capitalize(word)
		else if(prob(between_word_space_chance))
			sentence += " "

		sentence += word

	// scrambling the words will drop punctuation, so re-add it at the end
	sentence += find_last_punctuation(input)

	write_sentence_cache(input, cache_key, sentence)

	return sentence

/**
 * Scrambles a single word in this language.
 */
/datum/language/proc/scramble_word(input)
	// If the input is cached already, move it to the end of the cache and return it
	var/word = read_word_cache(input)
	if(word)
		return (is_uppercase(input) && length_char(input) >= 2) ? uppertext(word) : word

	if(!length(syllables))
		word = stars(input)

	else
		var/input_size = max(length_char(input) + rand(additional_syllable_low, additional_syllable_high), 1)
		var/add_space = FALSE
		var/add_period = FALSE
		word = ""
		while(length_char(word) < input_size)
			// add in the last syllable's period or space first
			if(add_period)
				word += ". "
			else if(add_space)
				word += " "
			// insert special chars if we're not at the start of the word
			else if(word && prob(1) && length(special_characters))
				word += pick(special_characters)
			// generate the next syllable (capitalize if we just added a period)
			var/next = pick_weight_recursive(syllables)
			word += add_period ? capitalize(next) : next
			// determine if the next syllable gets a period or space
			add_period = prob(sentence_chance)
			add_space = prob(space_chance)

	write_word_cache(input, word)

	// If they're shouting, we're shouting
	return (is_uppercase(input) && length_char(input) >= 2) ? uppertext(word) : word

#undef SCRAMBLE_CACHE_LEN

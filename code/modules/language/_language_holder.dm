/*!Language holders will either exist in an atom/movable. Creation of language holders happens
automatically when they are needed, for example when something tries to speak.
Where a mind is available, the mind language holder will be the one "in charge". The mind holder
will update its languages based on the atom holder, and will get updated as part of
transformations and other events that cause new languages to become available.

Every language holder has three lists of languages (and sources for each of them):
- understood_languages
- spoken_languages
- blocked_languages

Understood languages let you understand them, spoken languages lets you speak them
(if your tongue is compatible), and blocked languages will let you do neither no matter
what the source of the language is.

Language holders are designed to mostly only ever require the use the helpers in atom/movable
to achieve your goals, but it is also possible to work on them directly if needed. Any adding
and removing of languages and sources should only happen through the procs, as directly changing
these will mess something up somewhere down the line.

All atom movables have the initial_language_holder var which allows you to set the default language
holder to create. For example, /datum/language_holder/alien will give you xenocommon and a block for
galactic common. Human species also have a default language holder var that will be updated on
species change, initial_species_holder.

Key procs
* [grant_language](atom/movable.html#proc/grant_language)
* [remove_language](atom/movable.html#proc/remove_language)
* [add_blocked_language](atom/movable.html#proc/add_blocked_language)
* [remove_blocked_language](atom/movable.html#proc/remove_blocked_language)
* [grant_all_languages](atom/movable.html#proc/grant_all_languages)
* [remove_all_languages](atom/movable.html#proc/remove_all_languages)
* [has_language](atom/movable.html#proc/has_language)
* [can_speak_language](atom/movable.html#proc/can_speak_language)
* [get_selected_language](atom/movable.html#proc/get_selected_language)
*/

/datum/language_holder
	/// Lazyassoclist of all understood languages
	var/list/understood_languages
	/// Lazyassoclist of languages that can be spoken.
	/// Tongue organ may also set limits beyond this list.
	var/list/spoken_languages
	/// Lazyassoclist of blocked languages.
	/// Used to prevent understanding and speaking certain languages, ie for certain mobs, mutations etc.
	var/list/blocked_languages
	/// If true, overrides tongue aforementioned limitations.
	var/omnitongue = FALSE
	/// Handles displaying the language menu UI.
	VAR_FINAL/datum/language_menu/language_menu
	/// Currently spoken language
	var/selected_language
	/// Tracks the entity that owns the holder.
	VAR_FINAL/atom/movable/owner
	/// Lazyassoclist of all mutual understanding this holder has
	/// You generally don't want to access this, you want [best_mutual_languages] instead
	/// Format: list(language_type = list(source = % of understanding))
	VAR_PROTECTED/list/mutual_understanding
	/// Cached form of the mutual language list which only contains the best understanding available to each language
	VAR_FINAL/list/best_mutual_languages

/// Initializes, and copies in the languages from the current atom if available.
/datum/language_holder/New(atom/new_owner)
	if(new_owner)
		if(QDELETED(new_owner))
			CRASH("Language holder added to a qdeleting thing, what the fuck [text_ref(new_owner)]")
		if(!ismovable(new_owner))
			CRASH("Language holder being added to a non-movable thing, this is invalid (was: [new_owner] / [new_owner.type])")

	owner = new_owner

	// If we have an owner, we'll set a default selected language
	if(owner)
		get_selected_language()
	// Normally this is applied in grant_language, which we bypass
	for(var/language in understood_languages)
		gain_partial_understanding_from_language(language)

/datum/language_holder/Destroy()
	QDEL_NULL(language_menu)
	owner = null
	return ..()

/// Helper to get all the partial understanding from the passed language
/// Does effectively nothing if given a language already understood
/datum/language_holder/proc/gain_partial_understanding_from_language(language)
	PRIVATE_PROC(TRUE)

	var/datum/language/prototype = GLOB.language_datum_instances[language]
	for(var/other_language in prototype.mutual_understanding)
		grant_partial_language(other_language, prototype.mutual_understanding[other_language], language)

/// Helper to remove all the partial understanding from the passed language
/datum/language_holder/proc/lose_partial_understanding_from_language(language)
	PRIVATE_PROC(TRUE)

	var/datum/language/prototype = GLOB.language_datum_instances[language]
	for(var/other_language in prototype.mutual_understanding)
		remove_partial_language(other_language, language)

/// Calculates the "best mutual language list"
/datum/language_holder/proc/calculate_best_mutual_language()
	best_mutual_languages = list()
	for(var/language in mutual_understanding)
		for(var/source in mutual_understanding[language])
			// if this mutual understanding comes from a language, and that language is blocked, skip it
			if(LAZYACCESS(blocked_languages, source))
				continue
			if(!best_mutual_languages[language] || best_mutual_languages[language] < mutual_understanding[language][source])
				best_mutual_languages[language] = mutual_understanding[language][source]

/// Grants the supplied language.
/datum/language_holder/proc/grant_language(language, language_flags = ALL, source = LANGUAGE_MIND)
	if(language_flags & UNDERSTOOD_LANGUAGE)
		LAZYORASSOCLIST(understood_languages, language, source)
		gain_partial_understanding_from_language(language)
		. = TRUE
	if(language_flags & SPOKEN_LANGUAGE)
		LAZYORASSOCLIST(spoken_languages, language, source)
		. = TRUE

	return .

/// Grants every language to understood and spoken, and gives omnitongue.
/datum/language_holder/proc/grant_all_languages(language_flags = ALL, grant_omnitongue = TRUE, source = LANGUAGE_MIND)
	for(var/language in GLOB.all_languages)
		grant_language(language, language_flags, source)
	if(grant_omnitongue) // Overrides tongue limitations.
		omnitongue = TRUE
	return TRUE

/// Grants partial understanding of the passed language.
/// Giving 100 understanding is basically equivalent to knowning the language, just with butchered punctuation.
/datum/language_holder/proc/grant_partial_language(language, amount = 50, source = LANGUAGE_MIND)
	LAZYINITLIST(mutual_understanding)
	LAZYSET(mutual_understanding[language], source, amount)
	calculate_best_mutual_language()
	return TRUE

/// Removes a single language or source, removing all sources returns the pre-removal state of the language.
/datum/language_holder/proc/remove_language(language, language_flags = ALL, source = LANGUAGE_ALL)
	if(language_flags & UNDERSTOOD_LANGUAGE)
		if(source == LANGUAGE_ALL)
			LAZYREMOVE(understood_languages, language)
		else
			LAZYREMOVEASSOC(understood_languages, language, source)
		if(!LAZYACCESS(understood_languages, language))
			lose_partial_understanding_from_language(language)
		. = TRUE

	if(language_flags & SPOKEN_LANGUAGE)
		if(source == LANGUAGE_ALL)
			LAZYREMOVE(spoken_languages, language)
		else
			LAZYREMOVEASSOC(spoken_languages, language, source)
		. = TRUE

	return .

/// Removes every language and optionally sets omnitongue false. If a non default source is supplied, only removes that source.
/datum/language_holder/proc/remove_all_languages(source = LANGUAGE_ALL, remove_omnitongue = FALSE)
	for(var/language in GLOB.all_languages)
		remove_language(language, ALL, source)
	if(remove_omnitongue)
		omnitongue = FALSE
	return TRUE

/// Removes partial understanding of the passed language.
/datum/language_holder/proc/remove_partial_language(language, source = LANGUAGE_MIND)
	. = FALSE
	if(source == LANGUAGE_ALL)
		for(var/other_source in mutual_understanding[language])
			if(ispath(other_source, /datum/language))
				continue
			. = remove_partial_language(language, other_source) || .
	else if(LAZYACCESSASSOC(mutual_understanding, language, source))
		LAZYREMOVE(mutual_understanding[language], source)
		ASSOC_UNSETEMPTY(mutual_understanding, language)
		UNSETEMPTY(mutual_understanding)
		. = TRUE

	if(.)
		calculate_best_mutual_language()
	return .

/// Removes all partial understandings of all languages.
/datum/language_holder/proc/remove_all_partial_languages(source = LANGUAGE_MIND)
	for(var/language in mutual_understanding)
		remove_partial_language(language, source)
	return TRUE

/// Adds a single language or list of languages to the blocked language list.
/datum/language_holder/proc/add_blocked_language(languages, source = LANGUAGE_MIND)
	if(!islist(languages))
		languages = list(languages)

	for(var/language in languages)
		LAZYORASSOCLIST(blocked_languages, language, source)
	calculate_best_mutual_language()
	return TRUE

/// Removes a single language or list of languages from the blocked language list.
/datum/language_holder/proc/remove_blocked_language(languages, source = LANGUAGE_MIND)
	if(!islist(languages))
		languages = list(languages)

	for(var/language in languages)
		if(source == LANGUAGE_ALL)
			LAZYREMOVE(blocked_languages, language)
		else
			LAZYREMOVEASSOC(blocked_languages, language, source)
	calculate_best_mutual_language()
	return TRUE

/// Checks if you have the language passed.
/datum/language_holder/proc/has_language(language, flag_to_check = UNDERSTOOD_LANGUAGE)
	if(language in blocked_languages)
		return FALSE

	var/list/langs_to_check = list()
	if(flag_to_check & SPOKEN_LANGUAGE)
		langs_to_check |= spoken_languages
	if(flag_to_check & UNDERSTOOD_LANGUAGE)
		langs_to_check |= understood_languages

	return language in langs_to_check

/// Checks if you can speak the language. Tongue limitations should be supplied as an argument.
/datum/language_holder/proc/can_speak_language(language)
	var/can_speak_language_path = omnitongue || owner.could_speak_language(language)
	return (can_speak_language_path && has_language(language, SPOKEN_LANGUAGE))

/// Returns selected language if it can be spoken, or decides, sets and returns a new selected language if possible.
/datum/language_holder/proc/get_selected_language()
	if(selected_language && can_speak_language(selected_language))
		return selected_language
	selected_language = null
	var/highest_priority
	for(var/lang in spoken_languages)
		var/datum/language/language = lang
		var/priority = initial(language.default_priority)
		if((!highest_priority || (priority > highest_priority)) && !(language in blocked_languages))
			if(can_speak_language(language))
				selected_language = language
				highest_priority = priority
	return selected_language

/// Gets a random understood language, useful for hallucinations and such.
/datum/language_holder/proc/get_random_understood_language()
	return pick(understood_languages)

/// Gets a random spoken language, useful for forced speech and such.
/datum/language_holder/proc/get_random_spoken_language()
	return pick(spoken_languages)

/// Gets a random spoken language, trying to get a non-common language.
/datum/language_holder/proc/get_random_spoken_uncommon_language()
	var/list/languages_minus_common = assoc_to_keys(spoken_languages) - /datum/language/common

	// They have a language other than common
	if(length(languages_minus_common))
		return pick(languages_minus_common)

	// They can only speak common, oh well.
	else
		return /datum/language/common

/// Opens a language menu reading from the language holder.
/datum/language_holder/proc/open_language_menu(mob/user)
	if(!language_menu)
		language_menu = new (src)
	language_menu.ui_interact(user)

/// Copies all languages from the supplied atom/language holder. Source should be overridden when you
/// do not want the language overwritten by later atom updates or want to avoid blocked languages.
/datum/language_holder/proc/copy_languages(datum/language_holder/from_holder, source_override)
	if(source_override) //No blocked languages here, for now only used by ling absorb.
		for(var/language in from_holder.understood_languages)
			grant_language(language, UNDERSTOOD_LANGUAGE, source_override)
		for(var/language in from_holder.spoken_languages)
			grant_language(language, SPOKEN_LANGUAGE, source_override)
	else
		for(var/language in from_holder.understood_languages)
			grant_language(language, UNDERSTOOD_LANGUAGE, from_holder.understood_languages[language])
		for(var/language in from_holder.spoken_languages)
			grant_language(language, SPOKEN_LANGUAGE, from_holder.spoken_languages[language])
		for(var/language in from_holder.blocked_languages)
			add_blocked_language(language, from_holder.blocked_languages[language])
	return TRUE

/// Transfers all mind languages to the supplied language holder.
/datum/language_holder/proc/transfer_mind_languages(datum/language_holder/to_holder)
	for(var/language in understood_languages)
		if(LANGUAGE_MIND in understood_languages[language])
			remove_language(language, UNDERSTOOD_LANGUAGE, LANGUAGE_MIND)
			to_holder.grant_language(language, UNDERSTOOD_LANGUAGE, LANGUAGE_MIND)
	for(var/language in spoken_languages)
		if(LANGUAGE_MIND in spoken_languages[language])
			remove_language(language, SPOKEN_LANGUAGE, LANGUAGE_MIND)
			to_holder.grant_language(language, SPOKEN_LANGUAGE, LANGUAGE_MIND)
	for(var/language in blocked_languages)
		if(LANGUAGE_MIND in blocked_languages[language])
			remove_blocked_language(language, LANGUAGE_MIND)
			to_holder.add_blocked_language(language, LANGUAGE_MIND)
	for(var/language in mutual_understanding)
		var/mind_understanding = mutual_understanding[language][LANGUAGE_MIND]
		if(mind_understanding > 0)
			remove_partial_language(language, LANGUAGE_MIND)
			to_holder.grant_partial_language(language, mind_understanding, LANGUAGE_MIND)

	if(owner)
		get_selected_language()
	if(to_holder.owner)
		to_holder.get_selected_language()

/// A global assoc list containing prototypes of all language holders
/// [Language holder typepath] to [language holder instance]
/// Used for easy reference of what can speak what without needing to constantly recreate language holders.
GLOBAL_LIST_INIT(prototype_language_holders, init_language_holder_prototypes())

/// Inits the global list of language holder prototypes.
/proc/init_language_holder_prototypes()
	var/list/prototypes = list()
	for(var/holdertype in typesof(/datum/language_holder))
		prototypes[holdertype] = new holdertype()

	return prototypes

/*
 * Specific language holders presets
 *
 * Prefer to use [LANGUGAE_ATOM]. Atom languages will stick through species changes but not mindswaps.
 */

/datum/language_holder/alien
	understood_languages = list(/datum/language/xenocommon = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/xenocommon = list(LANGUAGE_ATOM))
	blocked_languages = list(/datum/language/common = list(LANGUAGE_ATOM))

/datum/language_holder/construct
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/narsie = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/narsie = list(LANGUAGE_ATOM),
	)

/datum/language_holder/drone
	understood_languages = list(/datum/language/drone = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/drone = list(LANGUAGE_ATOM))
	blocked_languages = list(/datum/language/common = list(LANGUAGE_ATOM))

/datum/language_holder/drone/syndicate
	blocked_languages = null

/datum/language_holder/human_basic
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/common = list(LANGUAGE_ATOM))

/datum/language_holder/jelly
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/slime = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/slime = list(LANGUAGE_ATOM),
	)

/datum/language_holder/lightbringer
	understood_languages = list(/datum/language/slime = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/slime = list(LANGUAGE_ATOM))
	blocked_languages = list(/datum/language/common = list(LANGUAGE_ATOM))

/datum/language_holder/lizard
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/draconic = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/draconic = list(LANGUAGE_ATOM),
	)

/datum/language_holder/lizard/ash
	selected_language = /datum/language/draconic

/datum/language_holder/lizard/silver
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM), // yes we hear you, but we refuse to speak your peasant language
		/datum/language/uncommon = list(LANGUAGE_ATOM),
		/datum/language/draconic = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/uncommon = list(LANGUAGE_ATOM),
		/datum/language/draconic = list(LANGUAGE_ATOM),
	)
	selected_language = /datum/language/uncommon

/datum/language_holder/lizard/hear_common
	selected_language = /datum/language/draconic
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/draconic = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/draconic = list(LANGUAGE_ATOM),
	)

/datum/language_holder/monkey
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/monkey = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/monkey = list(LANGUAGE_ATOM),
	)

/datum/language_holder/mushroom
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/mushroom = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/mushroom = list(LANGUAGE_ATOM),
	)

/datum/language_holder/slime
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/slime = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(/datum/language/slime = list(LANGUAGE_ATOM))

/datum/language_holder/venus
	understood_languages = list(/datum/language/sylvan = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/sylvan = list(LANGUAGE_ATOM))
	blocked_languages = list(/datum/language/common = list(LANGUAGE_ATOM))

/datum/language_holder/spider
	understood_languages = list(/datum/language/buzzwords = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/buzzwords = list(LANGUAGE_ATOM))
	blocked_languages = list(/datum/language/common = list(LANGUAGE_ATOM))

/datum/language_holder/synthetic
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/uncommon = list(LANGUAGE_ATOM),
		/datum/language/machine = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/uncommon = list(LANGUAGE_ATOM),
		/datum/language/machine = list(LANGUAGE_ATOM),
	)

/// For intelligent synthetics like cyborgs and the AI, not for basic baby bots ran on a raspberry pi
/datum/language_holder/synthetic/silicon

/datum/language_holder/synthetic/silicon/New(atom/new_owner)
	. = ..()
	for(var/lang in GLOB.uncommon_roundstart_languages)
		grant_partial_language(lang, 66, LANGUAGE_ATOM)

/datum/language_holder/moth
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/moffic = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/moffic = list(LANGUAGE_ATOM),
	)

/datum/language_holder/skeleton
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/calcic = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/calcic = list(LANGUAGE_ATOM),
	)

/datum/language_holder/ethereal
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/voltaic = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/voltaic = list(LANGUAGE_ATOM),
	)

/datum/language_holder/golem
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/terrum = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/terrum = list(LANGUAGE_ATOM),
	)

/datum/language_holder/fly
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/buzzwords = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/buzzwords = list(LANGUAGE_ATOM),
	)

/datum/language_holder/plant
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/sylvan = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/sylvan = list(LANGUAGE_ATOM),
	)

/datum/language_holder/felinid
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/nekomimetic = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/nekomimetic = list(LANGUAGE_ATOM),
	)

/datum/language_holder/shadowpeople
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/shadowtongue = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/shadowtongue = list(LANGUAGE_ATOM),
	)

/datum/language_holder/clown
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/monkey = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/monkey = list(LANGUAGE_ATOM),
	)

/datum/language_holder/syndicate
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/codespeak = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/codespeak = list(LANGUAGE_ATOM),
	)

/datum/language_holder/beachbum
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/beachbum = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/beachbum = list(LANGUAGE_ATOM),
	)
	selected_language = /datum/language/beachbum

/datum/language_holder/spinwarder
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/spinwarder = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/spinwarder = list(LANGUAGE_ATOM),
	)
	selected_language = /datum/language/spinwarder

/datum/language_holder/spinwarder_exclusive
	understood_languages = list(
		/datum/language/spinwarder = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/spinwarder = list(LANGUAGE_ATOM),
	)
	selected_language = /datum/language/spinwarder

// Vending machines are extremely well-educated
/datum/language_holder/speaking_machine
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/uncommon = list(LANGUAGE_ATOM),
		/datum/language/machine = list(LANGUAGE_ATOM),
		/datum/language/draconic = list(LANGUAGE_ATOM),
		/datum/language/moffic = list(LANGUAGE_ATOM),
		/datum/language/calcic = list(LANGUAGE_ATOM),
		/datum/language/voltaic = list(LANGUAGE_ATOM),
		/datum/language/nekomimetic = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/uncommon = list(LANGUAGE_ATOM),
		/datum/language/machine = list(LANGUAGE_ATOM),
		/datum/language/draconic = list(LANGUAGE_ATOM),
		/datum/language/moffic = list(LANGUAGE_ATOM),
		/datum/language/calcic = list(LANGUAGE_ATOM),
		/datum/language/voltaic = list(LANGUAGE_ATOM),
		/datum/language/nekomimetic = list(LANGUAGE_ATOM),
	)

/datum/language_holder/carp
	selected_language = /datum/language/carptongue
	understood_languages = list(
		/datum/language/carptongue = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/carptongue = list(LANGUAGE_ATOM),
	)

/datum/language_holder/carp/dragon
	understood_languages = list(
		/datum/language/carptongue = list(LANGUAGE_ATOM),
		/datum/language/draconic = list(LANGUAGE_ATOM),
		/datum/language/common = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/carptongue = list(LANGUAGE_ATOM),
		/datum/language/draconic = list(LANGUAGE_ATOM),
	)

/datum/language_holder/carp/hear_common
	understood_languages = list(
		/datum/language/carptongue = list(LANGUAGE_ATOM),
		/datum/language/common = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/carptongue = list(LANGUAGE_ATOM),
	)

// Given to atoms by default
/datum/language_holder/atom_basic
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/common = list(LANGUAGE_ATOM))

// Explicitly empty one for readability
/datum/language_holder/empty

// Has all the languages known (via "mind")
/datum/language_holder/universal

/datum/language_holder/universal/New()
	. = ..()
	grant_all_languages(source = LANGUAGE_MIND)

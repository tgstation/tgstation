/* 	Language Holders
*	Language holders live in two places, either in atom movables (mobs, vending machines, etc) or in a mind.
*	Accessing and using language holders should be done through the atom procs where possible.
*	If a mind holder is available, the mob holder will never be used for anything but update the mind holder on transfers and initial creation.
*	If an atom does not have a mind or loses it for some reason, the local holder will be used.
*/

/datum/language_holder
	/// Non mob specific understood languages.
	var/list/permanent_languages = list(/datum/language/common)
	/// Mob specific understood languages.
	var/list/temporary_languages = list()
	/// A list of languages that can be spoken. Tongue organ may also set limits beyond this list.
	var/list/spoken_languages = list(/datum/language/common)
	/// If true, overrides spoken_languages and tongue limitations.
	var/omnitongue
	/// Handles displaying the language menu UI.
	var/datum/language_menu/language_menu
	/// Currently spoken language
	var/selected_language
	/// Tracks the entity that owns the holder.
	var/owner

/// Initializes, and copies in the languages from the current mob if available.
/datum/language_holder/New(_owner)
	owner = _owner
	if(istype(owner, /datum/mind))
		var/datum/mind/M = owner
		if(M.current)
			update_mob_languages(M.current)
	get_selected_language()

/datum/language_holder/Destroy()
	qdel(language_menu)
	qdel(temporary_languages)
	qdel(permanent_languages)
	qdel(spoken_languages)
	return ..()

/// Grants the supplied language and sets omnitongue true. Pass permanent = FALSE to tie language to current mob.
/datum/language_holder/proc/grant_language(language, permanent = TRUE, spoken = TRUE)
	if(permanent)
		permanent_languages += language
	else
		temporary_languages += language
	if(spoken)
		spoken_languages += language

/// Grants every language to permanent understood, and spoken.
/datum/language_holder/proc/grant_all_languages(spoken = FALSE)
	for(var/language in GLOB.all_languages)
		grant_language(language, TRUE, spoken)
	if(spoken)	// Overrides tongue limitations.
		omnitongue = TRUE

/// Removes a single language.
/datum/language_holder/proc/remove_language(language)
	temporary_languages -= language
	permanent_languages -= language
	spoken_languages -= language

/// Removes every language and sets omnitongue false.
/datum/language_holder/proc/remove_all_languages()
	temporary_languages.Cut()
	permanent_languages.Cut()
	spoken_languages.Cut()
	omnitongue = FALSE

/// Checks if you have the language. If spoken is true, only checks if you can speak the language.
/datum/language_holder/proc/has_language(language, spoken = FALSE)
	if(spoken)
		if(language in spoken_languages)
			return TRUE
		else
			return FALSE
	if(language in temporary_languages)
		return TRUE
	if(language in permanent_languages)
		return TRUE
	return FALSE

/// Checks if you can speak the language. Tongue limitations should be supplied as an argument.
/datum/language_holder/proc/can_speak_language(language, tongue = TRUE)
	if(omnitongue)
		return TRUE
	if(tongue && has_language(language, TRUE))
		return TRUE
	return FALSE

/// Returns selected language if it can be spoken, or finds, sets and returns a new selected language if possible.
/datum/language_holder/proc/get_selected_language()
	if(selected_language && can_speak_language(selected_language))
		return selected_language
	selected_language = null
	var/highest_priority
	var/list/spoken = spoken_languages.Copy()
	if(omnitongue)
		spoken |= GLOB.all_languages
	for(var/lang in spoken)
		var/datum/language/language = lang
		var/priority = initial(language.default_priority)
		if(!highest_priority || (priority > highest_priority))
			selected_language = language
			highest_priority = priority
	return selected_language

/// Gets a random understood language, useful for hallucinations and such.
/datum/language_holder/proc/get_random_understood_language()
	var/list/all_languages = list()
	all_languages |= permanent_languages
	all_languages |= temporary_languages
	return pick(all_languages)

/// Gets a random spoken language, useful for forced speech and such.
/datum/language_holder/proc/get_random_spoken_language()
	return pick(spoken_languages)

/// Opens a language menu reading from the language holder.
/datum/language_holder/proc/open_language_menu(mob/user)
	if(!language_menu)
		language_menu = new (src)
	language_menu.ui_interact(user)

/// Gets the atom, since we some times need to check if the tongue has limitations.
/datum/language_holder/proc/get_atom()
	if(owner)
		if(istype(owner, /datum/mind))
			var/datum/mind/M = owner
			return M.current

		else
			return owner

/// Empties out the mob specific languages and updates them according to the supplied atoms language holder.
/datum/language_holder/proc/update_mob_languages(atom/movable/thing)
	temporary_languages.Cut()
	spoken_languages.Cut()

	var/datum/language_holder/from_mob = thing.get_language_holder(FALSE)	// Gets the atoms language holder

	permanent_languages |= from_mob.permanent_languages
	temporary_languages |= from_mob.temporary_languages
	spoken_languages |= from_mob.spoken_languages
	if(!selected_language)
		get_selected_language()

/// Copies and replaces holder into the supplied language holder.
/datum/language_holder/proc/copy_holder(var/datum/language_holder/to_holder)
	to_holder.permanent_languages.Cut()
	to_holder.temporary_languages.Cut()
	to_holder.spoken_languages.Cut()
	to_holder.permanent_languages |= permanent_languages
	to_holder.temporary_languages |= temporary_languages
	to_holder.spoken_languages |= spoken_languages
	to_holder.omnitongue = omnitongue
	to_holder.selected_language = selected_language

/// Copies all languages into the supplied language holder
/datum/language_holder/proc/copy_languages(var/datum/language_holder/to_holder)
	to_holder.permanent_languages |= permanent_languages
	to_holder.temporary_languages |= temporary_languages
	to_holder.spoken_languages |= spoken_languages


/************************************************
*        Specific language holders              *
************************************************/

/datum/language_holder/alien
	permanent_languages = list()
	temporary_languages = list(/datum/language/xenocommon)
	spoken_languages = list(/datum/language/xenocommon)

/datum/language_holder/construct
	temporary_languages = list(/datum/language/narsie)
	spoken_languages = list(/datum/language/common, /datum/language/narsie)

/datum/language_holder/drone
	temporary_languages = list(/datum/language/drone, /datum/language/machine)
	spoken_languages = list(/datum/language/drone)

/datum/language_holder/jelly
	temporary_languages = list(/datum/language/common, /datum/language/slime)
	spoken_languages = list(/datum/language/common, /datum/language/slime)

/datum/language_holder/lightbringer
	permanent_languages = list()
	temporary_languages = list(/datum/language/slime)
	spoken_languages = list(/datum/language/slime)

/datum/language_holder/lizard
	temporary_languages = list(/datum/language/common, /datum/language/draconic)
	spoken_languages = list(/datum/language/common, /datum/language/draconic)

/datum/language_holder/monkey
	temporary_languages = list(/datum/language/monkey)
	spoken_languages = list(/datum/language/monkey)

/datum/language_holder/mushroom
	temporary_languages = list(/datum/language/common, /datum/language/mushroom)
	spoken_languages = list(/datum/language/common, /datum/language/mushroom)

/datum/language_holder/slime
	temporary_languages = list(/datum/language/slime)
	spoken_languages = list(/datum/language/slime)

/datum/language_holder/swarmer
	permanent_languages = list()
	temporary_languages = list(/datum/language/swarmer)
	spoken_languages = list(/datum/language/swarmer)

/datum/language_holder/drone/syndicate
	spoken_languages = list(/datum/language/drone, /datum/language/common)

/datum/language_holder/synthetic
	temporary_languages = list(/datum/language/common, /datum/language/machine, /datum/language/draconic)
	spoken_languages = list(/datum/language/common, /datum/language/machine, /datum/language/draconic)

/datum/language_holder/empty
	temporary_languages = list()
	permanent_languages = list()
	spoken_languages = list()

/datum/language_holder/universal/New()
	..()
	grant_all_languages(TRUE)

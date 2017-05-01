/datum/language_holder
	var/list/languages = list()
	var/list/initial_languages = list(/datum/language/common)
	var/only_speaks_language = null
	var/selected_default_language = null
	var/datum/language_menu/language_menu

	var/omnitongue = FALSE
	var/owner

/datum/language_holder/New(owner)
	src.owner = owner
	for(var/L in initial_languages)
		grant_language(L)

/datum/language_holder/Destroy()
	owner = null
	QDEL_NULL(language_menu)

/datum/language_holder/proc/grant_language(datum/language/dt)
	languages[dt] = TRUE

/datum/language_holder/proc/grant_all_languages(omnitongue=FALSE)
	for(var/la in subtypesof(/datum/language))
		grant_language(la)

	if(omnitongue)
		src.omnitongue = TRUE

/datum/language_holder/proc/get_random_understood_language()
	var/list/possible = list()
	for(var/dt in languages)
		possible += dt
	. = safepick(possible)

/datum/language_holder/proc/remove_language(datum/language/dt)
	languages -= dt

/datum/language_holder/proc/remove_all_languages()
	languages.Cut()

/datum/language_holder/proc/has_language(datum/language/dt)
	. = is_type_in_typecache(dt, languages)

/datum/language_holder/proc/open_language_menu(mob/user)
	if(!language_menu)
		language_menu = new(src)
	language_menu.ui_interact(user)

/datum/language_holder/proc/get_atom()
	if(istype(owner, /atom/movable))
		. = owner
	else if(istype(owner, /datum/mind))
		var/datum/mind/M = owner
		if(M.current)
			. = M.current

/datum/language_holder/alien
	initial_languages = list(/datum/language/xenocommon)

/datum/language_holder/monkey
	initial_languages = list(/datum/language/monkey)

/datum/language_holder/swarmer
	initial_languages = list(/datum/language/swarmer)

/datum/language_holder/clockmob
	initial_languages = list(/datum/language/common, /datum/language/ratvar)
	only_speaks_language = /datum/language/ratvar

/datum/language_holder/drone
	initial_languages = list(/datum/language/common, /datum/language/drone, /datum/language/machine)
	only_speaks_language = /datum/language/drone

/datum/language_holder/drone/syndicate
	only_speaks_language = null

/datum/language_holder/slime
	initial_languages = list(/datum/language/common, /datum/language/slime)

/datum/language_holder/lightbringer
	// TODO change to a lightbringer specific sign language
	initial_languages = list(/datum/language/slime)

/datum/language_holder/synthetic
	initial_languages = list(/datum/language/common, /datum/language/machine)

/datum/language_holder/universal/New()
	..()
	grant_all_languages(omnitongue=TRUE)

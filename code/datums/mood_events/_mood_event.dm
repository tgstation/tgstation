/datum/mood_event
	///For descriptions of the event, use the span classes bold nicegreen, nicegreen, none, warning and boldwarning in order from great to horrible.
	var/description
	///description held without spans, used for other things interacting with moods
	var/raw_description
	///how much this positively or negatively affects their mood
	var/mood_change = 0
	///when the event ends, 0 means FOREVER!!
	var/timeout = 0
	///An event not shown on examine
	var/hidden = FALSE
	///string of what category this mood was added in as
	var/category
	///if it isn't null, it will replace or add onto the mood icon with this (same file). see happiness drug for example
	var/special_screen_obj
	///if false, it will be an overlay instead
	var/special_screen_replace = TRUE
	///owner of the mood event, whomstve is experiencing
	var/mob/owner

/datum/mood_event/New(mob/M, ...)
	owner = M
	var/list/params = args.Copy(2)
	add_effects(arglist(params))
	build_spans()

/datum/mood_event/Destroy()
	remove_effects()
	owner = null
	return ..()

/datum/mood_event/proc/add_effects(param)
	return

/datum/mood_event/proc/build_spans(param)
	raw_description = description
	switch(mood_change)
		if(MOOD_EVENT_BOLDWARNING_THRESHOLD to -INFINITY)
			description = span_boldwarning(description)
		if(MOOD_EVENT_WARNING_THRESHOLD to MOOD_EVENT_BOLDWARNING_THRESHOLD - 1)
			description = span_warning(description)
		if(MOOD_EVENT_NEUTRAL_THRESHOLD)
			description = span_yellowteamradio(description)
		if(MOOD_EVENT_NICEGREEN_THRESHOLD to MOOD_EVENT_BOLDNICEGREEN_THRESHOLD - 1)
			description = span_nicegreen(description)
		if(MOOD_EVENT_BOLDNICEGREEN_THRESHOLD to INFINITY)
			description = span_boldnicegreen(description)

/datum/mood_event/proc/remove_effects()
	return

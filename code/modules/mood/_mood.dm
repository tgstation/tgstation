/datum/mood
	/// Weakref to the parent (living) mob
	var/datum/weakref/parent

	/// Mobs mood
	var/mood
	/// The displayed mood
	var/shown_mood
	/// Modifier to allow certain mobs to be less affected by moodlets
	var/mood_modifier = 1
	/// Used to track what stage of moodies they're on
	var/mood_level
	/// To track what stage of sanity they're on
	var/sanity_level = SANITY_LEVEL_NEUTRAL
	/// The screen object for the current mood level
	var/atom/movable/screen/mood/mood_screen_object

	/// List of mood events currently active on this datum
	var/list/datum/mood_event/mood_events

/datum/mood/New(mob/living/mob_to_make_moody)
	if (!istype(mob_to_make_moody))
		stack_trace("Tried to apply mood to a non-living atom!")
		qdel(src)
		return

	parent = WEAKREF(mob_to_make_moody)
	mood_events = list()

/datum/mood/proc/add_mood_event(category, type)
	if (!ispath(type, /datum/mood_event))
		return
	if (!istext(category))
		category = REF(category)



	var/datum/mood_event/the_event
	if (mood_events[category])
		the_event = mood_events[category]
		if (the_event.type != type)
			clear_mood_event(category)
		else
			if (the_event.timeout)
				addtimer(CALLBACK(src, .proc/clear_mood_event, category), the_event.timeout, (TIMER_UNIQUE|TIMER_OVERRIDE))
			return // Don't need to update the event.
	var/list/params = args.Copy(4)

	var/mob/living/parent_mob = parent?.resolve()
	if (!parent_mob)
		return
	params.Insert(1, parent_mob)
	the_event = new type(arglist(params))

	mood_events[category] = the_event
	the_event.category = category
	update_mood()

	if (the_event.timeout)
		addtimer(CALLBACK(src, .proc/clear_mood_event, category), the_event.timeout, (TIMER_UNIQUE|TIMER_OVERRIDE))

/datum/mood/proc/clear_mood_event(category)
	if (!istext(category))
		category = REF(category)

	var/datum/mood_event/event = mood_events[category]
	if (!event)
		return

	mood_events -= category
	qdel(event)
	update_mood()

/// Updates the mobs mood.
/// Called after mood events have been added/removed.
/datum/mood/proc/update_mood()
	mood = 0
	shown_mood = 0

	for(var/mood_event in mood_events)
		var/datum/mood_event/the_event = mood_events[mood_event]
		mood += the_event.mood_change
		if (!the_event.hidden)
			shown_mood += the_event.mood_change
	mood *= mood_modifier
	shown_mood *= mood_modifier

	switch(mood)
		if (-INFINITY to MOOD_LEVEL_SAD4)
			mood_level = 1
		if (MOOD_LEVEL_SAD4 to MOOD_LEVEL_SAD3)
			mood_level = 2
		if (MOOD_LEVEL_SAD3 to MOOD_LEVEL_SAD2)
			mood_level = 3
		if (MOOD_LEVEL_SAD2 to MOOD_LEVEL_SAD1)
			mood_level = 4
		if (MOOD_LEVEL_SAD1 to MOOD_LEVEL_HAPPY1)
			mood_level = 5
		if (MOOD_LEVEL_HAPPY1 to MOOD_LEVEL_HAPPY2)
			mood_level = 6
		if (MOOD_LEVEL_HAPPY2 to MOOD_LEVEL_HAPPY3)
			mood_level = 7
		if (MOOD_LEVEL_HAPPY3 to MOOD_LEVEL_HAPPY4)
			mood_level = 8
		if (MOOD_LEVEL_HAPPY4 to INFINITY)
			mood_level = 9

	update_mood_icon()

/// Updates the mob's mood icon
/datum/mood/proc/update_mood_icon()
	var/mob/living/parent_mob = parent?.resolve()
	if (!parent_mob)
		return

	if (!(parent_mob.client || parent_mob.hud_used))
		return

	mood_screen_object.cut_overlays()
	mood_screen_object.color = initial(mood_screen_object.color)

	// lets see if we have an special icons to show instead of the normal mood levels
	var/list/conflicting_moodies = list()
	var/highest_absolute_mood = 0
	for (var/mood_event in mood_events)
		var/datum/mood_event/the_event = mood_events[mood_event]
		if (!the_event.special_screen_obj)
			continue
		if (!the_event.special_screen_replace)
			mood_screen_object.add_overlay(the_event.special_screen_obj)
		else
			conflicting_moodies += the_event
			var/absmood = abs(the_event.mood_change)
			highest_absolute_mood = absmood > highest_absolute_mood ? absmood : highest_absolute_mood

	switch(sanity_level)
		if (SANITY_LEVEL_GREAT)
			mood_screen_object.color = "#2eeb9a"
		if (SANITY_LEVEL_NEUTRAL)
			mood_screen_object.color = "#86d656"
		if (SANITY_LEVEL_DISTURBED)
			mood_screen_object.color = "#4b96c4"
		if (SANITY_LEVEL_UNSTABLE)
			mood_screen_object.color = "#dfa65b"
		if (SANITY_LEVEL_CRAZY)
			mood_screen_object.color = "#f38943"
		if (SANITY_LEVEL_INSANE)
			mood_screen_object.color = "#f15d36"

	if (!conflicting_moodies.len) // theres no special icons, use the normal icon states
		mood_screen_object.icon_state = "mood[mood_level]"
		return

	for (var/datum/mood_event/conflicting_event as anything in conflicting_moodies)
		if (abs(conflicting_event.mood_change) == highest_absolute_mood)
			mood_screen_object.icon_state = "[conflicting_event.special_screen_obj]"
			break

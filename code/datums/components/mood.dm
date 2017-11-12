/datum/component/mood
	var/mood
	var/mood_level
	var/datum/mood_event/list/mood_events = list()
	var/mob/owner

/datum/component/mood/Initialize()
	if(!ismob(parent))
		. = COMPONENT_INCOMPATIBLE
		CRASH("Some good for nothing loser put a mood component on something that isn't even a mob.")
	START_PROCESSING(SSmood, src)
	owner = parent

/datum/component/mood/Destroy()
	STOP_PROCESSING(SSmood, src)
	return ..()

/datum/component/mood/proc/print_mood()
	var/msg = "<span class='info'>*---------*\n<EM>Your current mood</EM>\n"
	for(var/i in mood_events)
		var/datum/mood_event/event = mood_events[i]
		msg += event.description
	to_chat(owner, msg)

/datum/component/mood/proc/update_mood() //Called whenever a mood event is added or removed
	mood = 0
	for(var/i in mood_events)
		var/datum/mood_event/event = mood_events[i]
		mood += event.mood_change

	switch(mood)
		if(-INFINITY to MOOD_LEVEL_SAD4)
			mood_level = 1
		if(MOOD_LEVEL_SAD4 to MOOD_LEVEL_SAD3)
			mood_level = 2
		if(MOOD_LEVEL_SAD3 to MOOD_LEVEL_SAD2)
			mood_level = 3
		if(MOOD_LEVEL_SAD2 to MOOD_LEVEL_SAD1)
			mood_level = 4
		if(MOOD_LEVEL_SAD1 to MOOD_LEVEL_HAPPY1)
			mood_level = 5
		if(MOOD_LEVEL_HAPPY1 to MOOD_LEVEL_HAPPY2)
			mood_level = 6
		if(MOOD_LEVEL_HAPPY2 to MOOD_LEVEL_HAPPY3)
			mood_level = 7
		if(MOOD_LEVEL_HAPPY3 to MOOD_LEVEL_HAPPY4)
			mood_level = 8
		if(MOOD_LEVEL_HAPPY4 to INFINITY)
			mood_level = 9

	if(owner.client && owner.hud_used)
		owner.hud_used.mood.icon_state = "mood[mood_level]"

/datum/component/mood/process() //Called on SSmood process
	switch(mood)
		if(-INFINITY to MOOD_LEVEL_SAD4)
			owner.overlay_fullscreen("depression", /obj/screen/fullscreen/depression, 3)
		if(MOOD_LEVEL_SAD4 to MOOD_LEVEL_SAD3)
			owner.overlay_fullscreen("depression", /obj/screen/fullscreen/depression, 2)
		if(MOOD_LEVEL_SAD3 to MOOD_LEVEL_SAD2)
			owner.overlay_fullscreen("depression", /obj/screen/fullscreen/depression, 1)
		if(MOOD_LEVEL_SAD2 to INFINITY)
			owner.clear_fullscreen("depression")

/datum/component/mood/proc/add_event(category, type, param) //Category will override any events in the same category, should be unique unless the event is based on the same thing like hunger.
	var/datum/mood_event/the_event
	if(mood_events[category])
		the_event = mood_events[category]
		if(the_event.type != type)
			clear_event(category)
			return .()
		else
			return 0 //Don't have to update the event.
	else
		the_event = new type(src, param)

	mood_events[category] = the_event
	update_mood()

	if(the_event.timeout)
		addtimer(CALLBACK(src, .proc/clear_event, category), the_event.timeout)

/datum/component/mood/proc/clear_event(category)
	var/datum/mood_event/event = mood_events[category]
	if(!event)
		return 0

	mood_events -= category
	qdel(event)
	update_mood()

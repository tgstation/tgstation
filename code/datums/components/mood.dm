/datum/component/mood
	var/mood //Real happiness
	var/shown_mood //Shown happiness, this is what others can see when they try to examine you, prevents antag checking by noticing traitors are always very happy.
	var/mood_level //To track what stage of moodies they're on
	var/mood_modifier = 1 //Modifier to allow certain mobs to be less affected by moodlets
	var/datum/mood_event/list/mood_events = list()
	var/mob/living/owner

/datum/component/mood/Initialize()
	if(!isliving(parent))
		. = COMPONENT_INCOMPATIBLE
		CRASH("Some good for nothing loser put a mood component on something that isn't even a living mob.")
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
	shown_mood = 0
	for(var/i in mood_events)
		var/datum/mood_event/event = mood_events[i]
		mood += event.mood_change
		if(!event.hidden)
			shown_mood += event.mood_change
		mood *= mood_modifier
		shown_mood *= mood_modifier

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

	if(owner.has_trait(TRAIT_DEPRESSION))
		if(prob(0.1))
			add_event("depression", /datum/mood_event/depression)
			clear_event("jolly")
	if(owner.has_trait(TRAIT_JOLLY))
		if(prob(0.1))
			add_event("jolly", /datum/mood_event/jolly)
			clear_event("depression")

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

/datum/component/mood/proc/update_beauty(var/area/A)
	if(A.outdoors) //if we're outside, we don't care.
		clear_event("area_beauty")
		return FALSE
	switch(A.beauty)
		if(-INFINITY to BEAUTY_LEVEL_HORRID)
			add_event("area_beauty", /datum/mood_event/disgustingroom)
		if(BEAUTY_LEVEL_HORRID to BEAUTY_LEVEL_BAD)
			add_event("area_beauty", /datum/mood_event/grossroom)
		if(BEAUTY_LEVEL_BAD to BEAUTY_LEVEL_GOOD)
			clear_event("area_beauty")
		if(BEAUTY_LEVEL_GOOD to BEAUTY_LEVEL_GREAT)
			add_event("area_beauty", /datum/mood_event/niceroom)
		if(BEAUTY_LEVEL_GREAT to INFINITY)
			add_event("area_beauty", /datum/mood_event/greatroom)

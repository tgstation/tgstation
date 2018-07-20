#define MINOR_INSANITY_PEN 5
#define MAJOR_INSANITY_PEN 10

/datum/component/mood
	var/mood //Real happiness
	var/sanity = 100 //Current sanity
	var/shown_mood //Shown happiness, this is what others can see when they try to examine you, prevents antag checking by noticing traitors are always very happy.
	var/mood_level = 5 //To track what stage of moodies they're on
	var/mood_modifier = 1 //Modifier to allow certain mobs to be less affected by moodlets
	var/datum/mood_event/list/mood_events = list()
	var/mob/living/owner
	var/insanity_effect = 0 //is the owner being punished for low mood? If so, how much?
	var/holdmyinsanityeffect = 0 //before we edit our sanity lets take a look

/datum/component/mood/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	START_PROCESSING(SSmood, src)
	owner = parent
	RegisterSignal(parent, COMSIG_ADD_MOOD_EVENT, .proc/add_event)
	RegisterSignal(parent, COMSIG_CLEAR_MOOD_EVENT, .proc/clear_event)

/datum/component/mood/Destroy()
	STOP_PROCESSING(SSmood, src)
	return ..()

/datum/component/mood/proc/print_mood()
	var/msg = "<span class='info'>*---------*\n<EM>Your current mood</EM>\n"
	msg += "<span class='notice'>My mental status: </span>" //Long term
	switch(sanity)
		if(SANITY_GREAT to INFINITY)
			msg += "<span class='nicegreen'>My mind feels like a temple!<span>\n"
		if(SANITY_NEUTRAL to SANITY_GREAT)
			msg += "<span class='nicegreen'>I have been feeling great lately!<span>\n"
		if(SANITY_DISTURBED to SANITY_NEUTRAL)
			msg += "<span class='nicegreen'>I have felt quite decent lately.<span>\n"
		if(SANITY_UNSTABLE to SANITY_DISTURBED)
			msg += "<span class='warning'>I'm feeling a little bit unhinged...</span>\n"
		if(SANITY_CRAZY to SANITY_UNSTABLE)
			msg += "<span class='boldwarning'>I'm freaking out!!</span>\n"
		if(SANITY_INSANE to SANITY_CRAZY)
			msg += "<span class='boldwarning'>AHAHAHAHAHAHAHAHAHAH!!</span>\n"

	msg += "<span class='notice'>My current mood: </span>" //Short term
	switch(mood_level)
		if(1)
			msg += "<span class='boldwarning'>I wish I was dead!<span>\n"
		if(2)
			msg += "<span class='boldwarning'>I feel terrible...<span>\n"
		if(3)
			msg += "<span class='boldwarning'>I feel very upset.<span>\n"
		if(4)
			msg += "<span class='boldwarning'>I'm a bit sad.<span>\n"
		if(5)
			msg += "<span class='nicegreen'>I'm alright.<span>\n"
		if(6)
			msg += "<span class='nicegreen'>I feel pretty okay.<span>\n"
		if(7)
			msg += "<span class='nicegreen'>I feel pretty good.<span>\n"
		if(8)
			msg += "<span class='nicegreen'>I feel amazing!<span>\n"
		if(9)
			msg += "<span class='nicegreen'>I love life!<span>\n"

	msg += "<span class='notice'>Moodlets:\n</span>"//All moodlets
	if(mood_events.len)
		for(var/i in mood_events)
			var/datum/mood_event/event = mood_events[i]
			msg += event.description
	else
		msg += "<span class='nicegreen'>Nothing special has happened to me lately!<span>\n"
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
	update_mood_icon()


/datum/component/mood/proc/update_mood_icon()
	if(owner.client && owner.hud_used)
		if(sanity < 25)
			owner.hud_used.mood.icon_state = "mood_insane"
		else
			owner.hud_used.mood.icon_state = "mood[mood_level]"

/datum/component/mood/process() //Called on SSmood process
	switch(sanity)
		if(SANITY_INSANE to SANITY_CRAZY)
			owner.overlay_fullscreen("depression", /obj/screen/fullscreen/depression, 3)
			update_mood_icon()
		if(SANITY_INSANE to SANITY_UNSTABLE)
			owner.overlay_fullscreen("depression", /obj/screen/fullscreen/depression, 2)
		if(SANITY_UNSTABLE to SANITY_DISTURBED)
			owner.overlay_fullscreen("depression", /obj/screen/fullscreen/depression, 1)
		if(SANITY_DISTURBED to INFINITY)
			owner.clear_fullscreen("depression")

	switch(mood_level)
		if(1)
			DecreaseSanity(0.2)
		if(2)
			DecreaseSanity(0.125, SANITY_CRAZY)
		if(3)
			DecreaseSanity(0.075, SANITY_UNSTABLE)
		if(4)
			DecreaseSanity(0.025, SANITY_DISTURBED)
		if(5)
			IncreaseSanity(0.1)
		if(6)
			IncreaseSanity(0.15)
		if(7)
			IncreaseSanity(0.20)
		if(8)
			IncreaseSanity(0.25, SANITY_GREAT)
		if(9)
			IncreaseSanity(0.4, SANITY_GREAT)

	if(insanity_effect != holdmyinsanityeffect)
		if(insanity_effect > holdmyinsanityeffect)
			owner.crit_threshold += (insanity_effect - holdmyinsanityeffect)
		else
			owner.crit_threshold -= (holdmyinsanityeffect - insanity_effect)

	if(owner.has_trait(TRAIT_DEPRESSION))
		if(prob(0.05))
			add_event("depression", /datum/mood_event/depression)
			clear_event("jolly")
	if(owner.has_trait(TRAIT_JOLLY))
		if(prob(0.05))
			add_event("jolly", /datum/mood_event/jolly)
			clear_event("depression")

	holdmyinsanityeffect = insanity_effect

/datum/component/mood/proc/DecreaseSanity(amount, minimum = SANITY_INSANE)
	if(sanity < minimum) //This might make KevinZ stop fucking pinging me.
		IncreaseSanity(0.5)
	else
		sanity = max(minimum, sanity - amount)
		if(sanity < SANITY_UNSTABLE)
			if(sanity < SANITY_CRAZY)
				insanity_effect = (MAJOR_INSANITY_PEN)
			else
				insanity_effect = (MINOR_INSANITY_PEN)

/datum/component/mood/proc/IncreaseSanity(amount, maximum = SANITY_NEUTRAL)
	if(sanity > maximum)
		DecreaseSanity(0.5) //Removes some sanity to go back to our current limit.
	else
		sanity = min(maximum, sanity + amount)
		if(sanity > SANITY_CRAZY)
			if(sanity > SANITY_UNSTABLE)
				insanity_effect = 0
			else
				insanity_effect = MINOR_INSANITY_PEN

/datum/component/mood/proc/add_event(category, type, param) //Category will override any events in the same category, should be unique unless the event is based on the same thing like hunger.
	var/datum/mood_event/the_event
	if(mood_events[category])
		the_event = mood_events[category]
		if(the_event.type != type)
			clear_event(category)
		else
			return 0 //Don't have to update the event.
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

#undef MINOR_INSANITY_PEN
#undef MAJOR_INSANITY_PEN

/datum/mood_event
	var/description ///For descriptions, use the span classes bold nicegreen, nicegreen, none, warning and boldwarning in order from great to horrible.
	var/mood_change = 0
	var/timeout = 0
	var/hidden = FALSE//Not shown on examine
	var/category //string of what category this mood was added in as
	var/special_screen_obj //if it isn't null, it will replace or add onto the mood icon with this. see happiness drug for example
	var/special_screen_replace = TRUE //if false, it will be an overlay instead
	var/mob/owner

/datum/mood_event/New(mob/M, param)
	owner = M
	add_effects(param)
	if(special_screen_obj)
		add_icon()

/datum/mood_event/Destroy()
	remove_effects()
	if(special_screen_obj)
		remove_icon()
	return ..()

/datum/mood_event/proc/add_effects(param)
	return

/datum/mood_event/proc/add_icon() //does not replace the icon
	GET_COMPONENT_FROM(mood, /datum/component/mood, owner)
	if(special_screen_replace)//if it's replacing, lets make sure we're not replacing a more important (higher mood change) icon
		var/highest_absolute_mood = 0
		for(var/i in mood.mood_events)
			var/datum/mood_event/event = i
			if(!event.special_screen_obj || !special_screen_replace || event == src)
				continue
			var/absmood = abs(event.mood_change)
			if(absmood > highest_absolute_mood)
				highest_absolute_mood = absmood
		if(mood_change > highest_absolute_mood)//this mood is the highest change out of all the moods that have a conflicting icon
			mood.screen_obj.icon_state = special_screen_obj
	else
		mood.screen_obj.add_overlay(special_screen_obj)
	return

/datum/mood_event/proc/remove_icon()
	GET_COMPONENT_FROM(mood, /datum/component/mood, owner)
	if(special_screen_replace)//if it's removing, lets see whether we're going back to normal icons or using another special one
		var/list/moodies = list()
		var/highest_absolute_mood = 0
		for(var/i in mood.mood_events)
			var/datum/mood_event/event = i
			if(!event.special_screen_obj || !special_screen_replace || event == src)
				continue
			moodies += event
			var/absmood = abs(event.mood_change)
			if(absmood > highest_absolute_mood)
				highest_absolute_mood = absmood
		if(highest_absolute_mood == 0)//no other mood changes
			mood.screen_obj.icon_state = initial(mood.screen_obj.icon_state)
		else
			var/chosen_icon //i'm gonna come back to this and make it better than this shitcode
			for(var/i in mood.mood_events)
				var/datum/mood_event/event2 = i
				if(event2.mood_change == highest_absolute_mood)
					chosen_icon = event2.special_screen_obj
			mood.screen_obj.icon_state = chosen_icon
	else
		mood.screen_obj.add_overlay(special_screen_obj)
	return

/datum/mood_event/proc/remove_effects()
	return

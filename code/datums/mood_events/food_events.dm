/datum/mood_event/favorite_food
	description = "I really enjoyed eating that."
	mood_change = 5
	timeout = 4 MINUTES
	event_flags = MOOD_EVENT_FOOD

/datum/mood_event/gross_food
	description = "I really didn't like that food."
	mood_change = -2
	timeout = 4 MINUTES
	event_flags = MOOD_EVENT_FOOD

/datum/mood_event/disgusting_food
	description = "That food was disgusting!"
	mood_change = -6
	timeout = 4 MINUTES
	event_flags = MOOD_EVENT_FOOD

/datum/mood_event/allergic_food
	description = "My throat itches."
	mood_change = -2
	timeout = 4 MINUTES
	event_flags = MOOD_EVENT_FOOD

/datum/mood_event/breakfast
	description = "Nothing like a hearty breakfast to start the shift."
	mood_change = 2
	timeout = 10 MINUTES
	event_flags = MOOD_EVENT_FOOD

/datum/mood_event/food
	timeout = 5 MINUTES
	event_flags = MOOD_EVENT_FOOD

/datum/mood_event/food/add_effects(quality = FOOD_QUALITY_NORMAL, timeout_mod = 1)
	mood_change = calculate_mood_change(quality)
	timeout *= timeout_mod
	description = "That food was [GLOB.food_quality_description[quality]]."

/datum/mood_event/food/be_refreshed(datum/mood/home, quality, timeout_mod)
	var/old_mood = mood_change
	// updates timeout (which is handled in parent call) and mood
	timeout = max(timeout, initial(timeout) * timeout_mod)
	mood_change = max(mood_change, calculate_mood_change(quality))
	// if mood_change is the same, we don't need to update the description
	if(old_mood != mood_change)
		description = "That food was [GLOB.food_quality_description[quality]]."
	return ..()

/datum/mood_event/food/proc/calculate_mood_change(base_quality)
	var/quality = 1 + 1.5 * base_quality
	if(HAS_PERSONALITY(owner, /datum/personality/ascetic))
		quality *= 0.5
	if(HAS_PERSONALITY(owner, /datum/personality/gourmand))
		if(quality <= FOOD_QUALITY_GOOD)
			quality = FOOD_QUALITY_NORMAL
	return ceil(quality)

/datum/mood_event/pacifist_eating_fish_item
	description = "I shouldn't be eating living creatures..."
	mood_change = -1 //The disgusting food moodlet already has a pretty big negative value, this is just for context.
	timeout = 4 MINUTES
	event_flags = MOOD_EVENT_FOOD
